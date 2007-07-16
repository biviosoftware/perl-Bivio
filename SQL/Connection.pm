# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Connection;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::Die;
use Bivio::DieCode;
use Bivio::Ext::DBI;
use Bivio::IO::Alert;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;
use Bivio::Type::DateTime;

# C<Bivio::SQL::Connection> is used to transact with the database. Instances
# of this module maintains one connection to the database at all times.  They
# will reset the connection if the database the connection is lost.
#
# B<Bivio::Agent::Task> depends on the fact that this is the only module
# which modifies the database. 

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_CONNECTIONS) = {};
my($_DEFAULT_DBI_NAME);
# Number of times we retry a single statement.
my($_MAX_RETRIES) = 3;
my($_MAX_BLOB) = int(MAX_BLOB() * 1.1);

sub CAN_LIMIT_AND_OFFSET {
    # The implemenation allows C<LIMIT> and C<OFFSET> clauses.
    return 0;
}

sub MAX_BLOB {
    # Maximum length of a blob.  You cannot retrieve blobs larger than this.
    # You can only have one blob per record.
    #
    # Returns 0x4_000_000
    return 0x4_000_000;
}

sub MAX_PARAMETERS {
    # Maximum number of '?' parameters on a single statement.
    #
    # Returns 100.
    # This value is somewhat arbitrary, but we've tested this up to
    # 230.  The problem is it depends on the statement complexity...
    # Deleting 100 at a time seems like it gets the biggest impact.
    return 100;
}

sub REQUIRE_COMMIT_OR_ROLLBACK {
    # Should a commit/rollback be issued even for queries? Subclasses may
    # override this, default is false.
    return 0;
}

sub commit {
    # Commits all open transactions.
    return _commit_or_rollback('commit', @_);
}

sub create {
    # B<DEPRECATED: Use L<get_instance|"get_instance">>.
    Bivio::IO::Alert->warn_deprecated('use get_instance()');
    return shift->get_instance(@_);
}

sub disconnect {
    my($self) = shift;
    # Disconnects from database.
    return _get_instance($self)->disconnect(@_)
	unless ref($self);
    my($fields) = $self->[$_IDI];
    _get_connection($self)->disconnect();
    $fields->{connection_pid} = 0;
    $fields->{connection} = undef;
    return;
}

sub do_execute {
    my($self) = shift;
    # Calls op with fetched row.
    return _get_instance($self)->do_execute(@_)
	unless ref($self);
    my($op) = shift;
    my($st) = $self->execute(@_);
    while (my $row = $st->fetchrow_arrayref) {
	last unless $op->($row);
    }
    $st->finish;
#TODO: Clears cached handle
#    $self->finish_statement($st);
    return;
}

sub execute {
    my($self) = shift;
    # Executes the specified statement and dies with an appropriate error
    # if it fails.
    #
    # B<NOTE: All calls must go through this>
    #
    # I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.
    #
    # If I<has_blob> is specified, the arguments are scanned for a scalar_ref.
    # If found, the positional parameter is bound properly.  If no scalar_ref
    # is found, then the BLOB is assumed to be an output parameter and
    # I<LongReadLen> and I<LongTruncOk> are set accordingly.
    #
    # We retry on certain errors (see
    # L<internal_get_retry_sleep|"internal_get_retry_sleep">).
    return _get_instance($self)->execute(@_)
	unless ref($self);
    my($sql, $params, $die, $has_blob) = @_;
    my($fields) = $self->[$_IDI];

    $sql = $self->internal_fixup_sql($sql);
    my($err, $errstr, $statement);
    my($retries) = 0;
 TRY: {
	# Execute the statement
	my($start_time) = Bivio::Type::DateTime->gettimeofday();
#TODO: should be a Die->catch() but this prints a stack trace, and
#      causes the request to lose attributes?
        my($ok) = Bivio::Die->eval(sub {
		$self->internal_execute($sql, $params, $has_blob, \$statement);
                return 1;
            });
        my($die_error) = $@;

	$self->increment_db_time($start_time);
	return $statement if $ok;

	# Extract the errors
	$err = $statement && $statement->err ? $statement->err + 0 : 0;
	$errstr = $statement && $statement->errstr
            ? $statement->errstr : $die_error;

	# If we get an error, it may be a timed-out connection.  We'll
	# check the connection the next time through.
	$fields->{need_ping} = 1;

	# Can we retry?
	my($sleep) = $self->internal_get_retry_sleep($err, $errstr);
	last TRY unless defined($sleep);

	# Don't retry if connection has executed DML already
	if ($fields->{need_commit}) {
	    Bivio::IO::Alert->warn($errstr,
		    '; not retrying, partial transaction');
	    last TRY;
	}

	# Maxed out?
	if (++$retries > $_MAX_RETRIES) {
	    Bivio::IO::Alert->warn($errstr, '; max retries hit');
	    last TRY;
	}

	# Don't do anything with statement, it will be garbage collected.
	# Shouldn't really get here, so put in the logs.
	Bivio::IO::Alert->warn('retrying:  ',
		$errstr, '; die=', $die, '; sql=', $sql,
		'; params=', @{_prep_params_for_io($params)},
		'; retries=', $retries) if $retries == 1;

	_trace('retry after sleep=', $sleep) if $_TRACE;

	# Don't call "empty" sleeps
	sleep($sleep) if $sleep > 0;
	redo TRY;
    }

    # Unrecoverable error
    my($attrs) = {
	message => $@,
	dbi_err => $err,
	dbi_errstr => $errstr,
	sql => $sql,
	sql_params => $params,
    };
    my($die_code) = $self->internal_get_error_code($attrs);
    Bivio::Die->eval(sub {
	$statement->finish if $statement;
    });
    $die ||= 'Bivio::Die';
    $die->throw_die($die_code, $attrs, caller);
    # DOES NOT RETURN
}

sub execute_one_row {
    my($self) = shift;
    # Calls L<execute|"execute"> and returns the first row as an array_ref.
    # If there is no row, returns C<undef>.
    return _get_instance($self)->execute_one_row(@_)
	unless ref($self);
    my($sth) = $self->execute(@_);
    my($row) = $sth->fetchrow_arrayref;
    $sth->finish;
    return $row;
}

sub get_db_time {
    my($self) = shift;
    # If tracing is enabled, this returns the amount of time spent processing
    # database requests. Invoking this method clears the counter.
    return _get_instance($self)->get_db_time(@_)
	unless ref($self);
    my($fields) = $self->[$_IDI];
    my($result) = $fields->{db_time};
    $fields->{db_time} = 0;
    return $result;
}

sub get_dbi_config {
    my($self) = shift;
    # Returns a copy of the dbi configuration for this connection.  See
    # L<Bivio::Ext::DBI::get_config|Bivio::Ext::DBI/"get_config">.
    return _get_instance($self)->get_dbi_config(@_)
	unless ref($self);
    my($fields) = $self->[$_IDI];
    return Bivio::Ext::DBI->get_config($fields->{dbi_name});
}

sub get_instance {
    my($proto, $dbi_name) = @_;
    # Returns the singleton instance for configured I<dbi_name> database.

    my($key) = defined($dbi_name) ? $dbi_name : '<default>';
    # cache connections by dbi_name
    unless ($_CONNECTIONS->{$key}) {
	my($module) = Bivio::Ext::DBI->get_config($dbi_name)->{connection};
	Bivio::IO::ClassLoader->simple_require($module);
	_trace($module) if $_TRACE;
	$_CONNECTIONS->{$key} = $module->internal_new($dbi_name);
    }
    return $_CONNECTIONS->{$key};
}

sub handle_commit {
    # Callback for transaction resources.
    shift->commit(@_);
    return;
}

sub handle_rollback {
    # Callback for transaction resources.
    shift->rollback(@_);
    return;
}

sub increment_db_time {
    my($self) = shift;
    # If tracing is enabled, this increments the database time counter and
    # returns its new value.
    return _get_instance($self)->increment_db_time(@_)
	unless ref($self);
    my($start_time) = @_;
    my($fields) = $self->[$_IDI];
    die('invalid start_time') unless $start_time;
    $fields->{db_time} += Bivio::Type::DateTime->gettimeofday_diff_seconds(
	    $start_time);
    return $fields->{db_time};
}

sub internal_clear_ping {
    my($self) = @_;
    # Clears the need_ping state.
    my($fields) = $self->[$_IDI];
    $fields->{need_ping} = 0;
    return;
}

sub internal_dbi_connect {
    my(undef, $dbi_name) = @_;
    # Connects to the database.  Returns the database handle.
    return Bivio::Ext::DBI->connect($dbi_name);
}

sub internal_execute {
    my($self, $sql, $params, $has_blob, $statement) = @_;
    # Executes sql.  Exception must be caught by caller. Sets statement (even on
    # error).
    my($fields) = $self->[$_IDI];

    _trace_sql($sql, $params) if $_TRACE;
#TODO: Need to investigate problems and performance of cached statements
#TODO: If do cache, then make sure not "active" when making call.
    $$statement = _get_connection($self)->prepare($sql);

    # Only need a commit if there has been data modification language
    # Tightly coupled with PropertySupport
    my($is_select) = $sql =~ /^\s*select/i
	    && $sql !~ /\bfor\s+update\b/i;
    return if !$is_select && $fields->{db_is_read_only};
    if ($has_blob) {
	$params = $self->internal_prepare_blob($is_select, $params,
		$statement);
    }
    $fields->{need_commit} = 1 unless $is_select;
    ref($params) ? $$statement->execute(@$params)
	    : $$statement->execute();
    return;
}

sub internal_fixup_sql {
    my($self, $sql) = @_;
    # Performs any database specific changes to the Oracle SQL string.

    # Removes 'order by' clause from 'select count(*) from ...' queries.
    if  ($sql =~ /^\s*SELECT\s+COUNT\(\*\)\s+FROM\s/is) {
        $sql =~ s/\border\s+by\s.*$//is;
    }
    return $sql;
}

sub internal_get_dbi_connection {
    my($self) = @_;
    # Returns the raw DBI connection.
    return _get_connection($self);
}

sub internal_get_error_code {
    my($self, $die_attrs) = @_;
    # Converts the database error into an appropriate error code. Subclasses
    # should override this to handle constraint violations.
    $die_attrs->{program_error} = 1;
    # Unexpected error is treated as an assertion fault
    return Bivio::DieCode->DB_ERROR;
}

sub internal_get_retry_sleep {
    # Returns the number of seconds to sleep for the specified transient
    # error code. 0 indicates retry immediately, undef indicates don't
    # retry.
    return undef;
}

sub internal_new {
    my($proto, $dbi_name) = @_;
    # Creates a new connection which uses the specified DBI config name.
    # Do not call this method directly, use L<connect|"connect">.
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
	dbi_name => $dbi_name,
	db_is_read_only => 0,
	connection => undef,
	# Set to the pid that creates the connection.  Ensures all
	# children use a different connection.
	connection_pid => 0,
	need_commit => 0,
	# If there is an error, this will be true.  _get_connection
	# checks the connection with a ping to make sure it is still
	# alive.
	need_ping => 0,
	db_time => 0,
    };
    return $self;
}

sub internal_prepare_blob {
    my($self, $is_select, $params, $statement) = @_;
    # Prepares a query or update of a blob field..
    # Returns the altered statement params.

    if ($is_select) {
	# Returns a value.  For older DBD::Oracle implementations, we
	# need to set the value on every $statement.  Newer imps,
	# set it once per connection.
	$$statement->{LongReadLen} = $_MAX_BLOB;
	$$statement->{LongTruncOk} = 0;
	return $params;
    }

    # Passing a value, possibly
    my($i) = 1;
    foreach my $p (@$params) {
	$$statement->bind_param($i++, $p), next unless ref($p);
	# I wonder if it stores a reference or a copy?
	$$statement->bind_param($i++,  $$p, $self->internal_get_blob_type);
    }
    # Parameters are bound, so don't pass them on
    return undef;
}

sub is_read_only {
    my($self) = shift;
    # Returns true if the current database connection is to a read-only
    # database.
    return _get_instance($self)->is_read_only(@_)
	unless ref($self);
    my($fields) = $self->[$_IDI];
    return $fields->{db_is_read_only};
}

sub next_primary_id {
    my($self) = shift;
    # Subclasses should return the next sequence number for the specified
    # table.
    return _get_instance($self)->next_primary_id(@_)
	unless ref($self);
    Bivio::Die->die('abstract method');
    # DOES NOT RETURN
}

sub ping_connection {
    my($self) = shift;
    # Ensures the connection is valid.
    return _get_instance($self)->ping_connection(@_)
        unless ref($self);
    my($fields) = $self->[$_IDI];
    $fields->{need_ping} = 1;
    return _get_connection($self);
}

sub rollback {
    # Rolls back all open transactions.
    return _commit_or_rollback('rollback', @_);
}

sub set_dbi_name {
    my(undef, $name) = @_;
    # Sets the name of the L<Bivio::Ext::DBI|Bivio::Ext::DBI> configuration
    # to use.  The default is C<undef>.  Returns the previous name.
    #
    # Doesn't do anything if I<name> is not different from the current name.
    #
    # The name selected will become the default database for all static calls.
    # Don't do anything if the names are equal
    return $name if defined($name) == defined($_DEFAULT_DBI_NAME)
	&& (!defined($name) || $name eq $_DEFAULT_DBI_NAME);
    my($old) = $_DEFAULT_DBI_NAME;
    $_DEFAULT_DBI_NAME = $name;
    _trace('default db set to ', $name) if $_TRACE;
    return $old;
}

sub _commit_or_rollback {
    my($method, $self) = splice(@_, 0, 2);
    # Wrapper for commit() and rollback()
    return _get_instance($self)->$method(@_)
	unless ref($self);
    my($fields) = $self->[$_IDI];
    return unless $self->REQUIRE_COMMIT_OR_ROLLBACK || $fields->{need_commit};
    _trace($method) if $_TRACE;
    _get_connection($self)->$method()
	unless $fields->{db_is_read_only};
    $fields->{need_commit} = 0;
    return;
}

sub _get_connection {
    my($self) = @_;
    # static _get_connection(self) : connection
    #
    # Returns a cached database connection for this process.  Checks the
    # connection for validity.
    my($fields) = $self->[$_IDI];

    if ($fields->{connection_pid} != $$) {
	if ($fields->{connection}) {
	    # This disconnects the parent process'.  Make sure we rollback
	    # any pending transactions.  By default, disconnect commits
	    Bivio::Die->eval(sub {
		$fields->{connection}->ping
			&& $fields->{connection}->rollback});
	    Bivio::Die->eval(sub {$fields->{connection}->disconnect});
	    Bivio::IO::Alert->warn("reconnecting to database: pid=$$");
	    # Make sure we don't enter this code again.
	    $fields->{connection} = undef;
	}
	_trace("creating connection: pid=$$") if $_TRACE;
	$fields->{connection} =
	    $self->internal_dbi_connect($fields->{dbi_name});
	$fields->{db_is_read_only} = Bivio::Ext::DBI->get_config(
		$fields->{dbi_name})->{is_read_only};
	# Got a connection which will be reused on next call.  We don't
	# need to ping it (just in case parent process had an error on
	# the connection).
	$fields->{connection_pid} = $$;
	$fields->{need_ping} = 0;
    }
    elsif ($fields->{need_ping}) {
	# Got an error on a previous use of this connection.  Make
	# sure is still valid.
	$fields->{need_ping} = 0;
	unless (Bivio::Die->eval(sub {$fields->{connection}->ping})) {
	    # Just in case, rollback any pending actions
	    # be executed.  Caller will reset $_CONNECTION
	    $fields->{connection_pid} = 0;
	    return _get_connection($self);
	}
	# Current connection is valid
    }
    return $fields->{connection};
}

sub _get_instance {
    my($proto) = @_;
    # Returns the default instance.
    return $proto->get_instance($_DEFAULT_DBI_NAME);
}

sub _prep_params_for_io {
    my($params) = @_;
    # Returns an array which can be passed to Bivio::IO.
    my(@args);
    my($sep) = ' [';
    my($p);
    foreach $p (ref($params) ? @$params : ()) {
	push(@args, $sep, $p);
	$sep = ',';
    }
    @args && push(@args, ']');
    # Let trace deal with string truncation and undef
    return \@args;
}

sub _trace_sql {
    my($sql, $params) = @_;
    # Traces the specified sql statement with parameters.
    # Let trace deal with string truncation and undef
    _trace($sql, '; params=', @{_prep_params_for_io($params)});
    return;
}

1;
