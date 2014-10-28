# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Connection;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

# C<SQL.Connection> is used to transact with the database. Instances
# of this module maintains one connection to the database at all times.  They
# will reset the connection if the database the connection is lost.
#
# B<Agent.Task> depends on the fact that this is the only module
# which modifies the database. 

our($_TRACE);
b_use('IO.Trace');
my($_DT) = b_use('Type.DateTime');
my($_D) = b_use('Bivio.Die');
my($_A) = b_use('IO.Alert');
my($_DBI) = b_use('Ext.DBI');
my($_CL) = b_use('IO.ClassLoader');
my($_C) = b_use('IO.Config');
my($_DC) = b_use('Bivio.DieCode');
my($_R);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_CONNECTIONS) = {};
my($_DEFAULT_DBI_NAME);
# Number of times we retry a single statement.
my($_MAX_RETRIES) = 3;
b_use('Action.PingReply')->register_handler(__PACKAGE__);
b_use('Bivio.ShellUtil')->register_handler(__PACKAGE__);
b_use('IO.Config')->register(my $_CFG = {
    long_query_seconds => 30,
});

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
    $_A->warn_deprecated('use get_instance()');
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
    return _do_execute(shift, 'fetchrow_arrayref', @_);
}

sub do_execute_rows {
    return _do_execute(shift, 'fetchrow_hashref', @_);
}

sub execute {
    my($self) = _verify_instance(shift);
    # Executes the specified statement and dies with an appropriate error
    # if it fails.
    #
    # B<NOTE: All calls must go through this>
    #
    # I<die> must implement L<Die.die|Die/"die">.
    #
    # If I<has_blob> is specified, the arguments are scanned for a scalar_ref.
    # If found, the positional parameter is bound properly.  If no scalar_ref
    # is found, then the BLOB is assumed to be an output parameter and
    # I<LongReadLen> and I<LongTruncOk> are set accordingly.
    #
    # We retry on certain errors (see
    # L<internal_get_retry_sleep|"internal_get_retry_sleep">).
    my($sql, $params, $die, $has_blob) = @_;
    my($fields) = $self->[$_IDI];
    $sql = $self->internal_fixup_sql($sql);
    my($err, $errstr, $statement);
    my($retries) = 0;
    TRY: {
	# Execute the statement
#TODO: should be a Die->catch() but this prints a stack trace, and
#      causes the request to lose attributes?
        my($delta) = 0;
        my($ok) = $self->perf_time_op(sub {
	    return $_D->eval(sub {
	        $self->internal_execute($sql, $params, $has_blob, \$statement);
		return 1;
	    }),
	},
	    \$delta,
	);
        my($die_error) = $@;
	b_warn($delta, 's: query took a long time: ', $sql, $params)
	    if $delta > $_CFG->{long_query_seconds};
	return $statement
	    if $ok;
	$err = $statement && $statement->err ? $statement->err + 0 : 0;
	$errstr = $statement && $statement->errstr
            ? $statement->errstr : $die_error;
	# If we get an error, it may be a timed-out connection.  We'll
	# check the connection the next time through.
	$fields->{need_ping} = 1;
	my($sleep) = $self->internal_get_retry_sleep($err, $errstr);
	last TRY
	    unless defined($sleep);
	if ($fields->{need_commit}) {
	    b_warn($errstr, '; not retrying, partial transaction');
	    last TRY;
	}
	if (++$retries > $_MAX_RETRIES) {
	    b_warn($errstr, '; max retries hit');
	    last TRY;
	}
	# Don't do anything with statement, it will be garbage collected.
	# Shouldn't really get here, so put in the logs.
	b_warn(
	    'retrying:  ',
	    $errstr,
	    '; die=',
	    $die,
	    '; sql=',
	    $sql,
	    '; params=',
	    $params,
	    '; retries=',
	    $retries,
	) if $retries == 1;
	_trace('retry after sleep=', $sleep) if $_TRACE;
	sleep($sleep)
	    if $sleep > 0;
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
    $_D->eval(sub {
	$self->perf_time_op(sub {$statement->finish})
	    if $statement;
    });
    ($die || $_D)->throw_die($die_code, $attrs, caller);
    # DOES NOT RETURN
}

sub execute_one_row {
    return _execute_one_row('fetchrow_arrayref', @_);
}

sub execute_one_row_hashref {
    return _execute_one_row('fetchrow_hashref', @_);
}

sub get_dbi_config {
    my($self) = shift;
    return $_DBI->get_config(
	@_ ? @_
	    : ref($self) ? $self->[$_IDI]->{dbi_name}
	    : $_C->DEFAULT_NAME,
    );
}

sub get_instance {
    my($proto, $dbi_name) = @_;
    $dbi_name = $_C->DEFAULT_NAME
	unless defined($dbi_name);
    unless ($_CONNECTIONS->{$dbi_name}) {
	my($module) = b_use($proto->get_dbi_config($dbi_name)->{connection});
	_trace($module) if $_TRACE;
	$_CONNECTIONS->{$dbi_name} = $module->internal_new($dbi_name);
    }
    if (my $req = ($_R ||= b_use('Agent.Request'))->get_current) {
	$req->push_txn_resource($_CONNECTIONS->{$dbi_name});
    }
    return $_CONNECTIONS->{$dbi_name};
}

sub handle_commit {
    shift->commit(@_);
    return;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub handle_ping_reply {
    return shift->ping_connection;
}

sub handle_piped_exec_child {
    foreach my $self (values(%$_CONNECTIONS)) {
	next
	    unless my $fields = $self->[$_IDI];
	$fields->{connection}->{InactiveDestroy} = 1;
	$fields->{connection} = undef;
    }
    return;
}

sub handle_rollback {
    shift->rollback(@_);
    return;
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
    return $_DBI->connect($dbi_name);
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
    $sql =~ s/\border\s+by\s.*$//is
	if $sql =~ /^\s*SELECT\s+COUNT\(\*\)\s+FROM\s/is;
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
    return $_DC->DB_ERROR;
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
	$$statement->{LongReadLen} = int($self->MAX_BLOB * 1.1);
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

sub map_execute {
    return _map_execute(shift, 'fetchrow_arrayref', @_);
}

sub map_execute_rows {
    return _map_execute(shift, 'fetchrow_hashref', @_);
}

sub next_primary_id {
    my($self) = shift;
    # Subclasses should return the next sequence number for the specified
    # table.
    return _get_instance($self)->next_primary_id(@_)
	unless ref($self);
    $_D->die('abstract method');
    # DOES NOT RETURN
}

sub perf_time_finish {
    my($self, $st) = @_;
    return $self->perf_time_op(sub {$st->finish});
}

sub perf_time_op {
    shift;
    return ($_R ||=  b_use('Agent.Request'))->perf_time_op(__PACKAGE__, @_);
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
    # Sets the name of the L<Ext.DBI|Ext.DBI> configuration
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

sub _do_execute {
    # (self, string, code_ref, @_) : undef
    my($self) = _verify_instance(shift);
    my($method, $op) = (shift, shift);
    my($st) = $self->execute(@_);
    return
	unless $st->{Active};
    while (my $row = $self->perf_time_op(sub {$st->$method})) {
	last
	    unless $op->($row);
    }
    $self->perf_time_finish($st);
#TODO: Clears cached handle
#    $self->finish_statement($st);
    return;
}

sub _execute_one_row {
    my($method, $self) = (shift, shift);
    return _execute_one_row($method, _get_instance($self), @_)
	unless ref($self);
    my($sth) = $self->execute(@_);
    return $self->perf_time_op(sub {
	my($row) = $sth->$method;
        $sth->finish;
	return $row;
    });
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
	    $_D->eval(sub {
		$fields->{connection}->ping
			&& $fields->{connection}->rollback});
	    $_D->eval(sub {$fields->{connection}->disconnect});
	    b_warn("reconnecting to database: pid=$$");
	    # Make sure we don't enter this code again.
	    $fields->{connection} = undef;
	}
	_trace("creating connection: pid=$$") if $_TRACE;
	$fields->{connection} =
	    $self->internal_dbi_connect($fields->{dbi_name});
	$fields->{db_is_read_only}
	    = $_DBI->get_config($fields->{dbi_name})->{is_read_only};
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
	unless ($_D->eval(sub {$fields->{connection}->ping})) {
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
    return ref($proto) ? $proto
	: $proto->get_instance($_DEFAULT_DBI_NAME);
}

sub _map_execute {
    # (self, string, @_) : undef
    # (self, string, code_ref, @_) : undef
    my($self) = _verify_instance(shift);
    my($method) = shift;
    my($op) = ref($_[0]) eq 'CODE' ? shift : sub {
	my($row) = @_;
	return @$row == 1 ? $row->[0] : [@$row];
    };
    my($st) = $self->execute(@_);
    my($res) = [];
    return $res
	unless $st->{Active};
    while (1) {
	last
	    unless my $row = $self->perf_time_op(sub {$st->$method});
	push(@$res, $op->($row));
    }
    $self->perf_time_finish($st);
#TODO: Clears cached handle
#    $self->finish_statement($st);
    return $res;
}

sub _trace_sql {
    my($sql, $params) = @_;
    map($sql
	=~ s{\?}{
	    !defined($_) ? 'NULL'
		: ref($_) ? '<blob>'
		: $_ =~ /\D/ ? _trace_sql_quote($_)
		: $_;
	}e,
	@$params,
    );
    _trace($sql);
    return;
}

sub _trace_sql_quote {
    my($v) = @_;
    $v = $_A->format_args($v);
    chomp($v);
    $v =~ s/'/''/sg;
    return qq{'$v'};
}

sub _verify_instance {
    return shift
	if ref($_[0]);
    return _get_instance(shift);
}

1;
