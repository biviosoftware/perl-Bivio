# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Connection;
use strict;
$Bivio::SQL::Connection::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::SQL::Connection::VERSION;

=head1 NAME

Bivio::SQL::Connection - a database connection manager

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::SQL::Connection;

=cut

use Bivio::UNIVERSAL;
@Bivio::SQL::Connection::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::SQL::Connection> is used to transact with the database. Instances
of this module maintains one connection to the database at all times.  They
will reset the connection if the database the connection is lost.

B<Bivio::Agent::Task> depends on the fact that this is the only module
which modifies the database.

=cut

=head1 CONSTANTS

=cut

=for html <a name="MAX_PARAMETERS"></a>

=head2 MAX_PARAMETERS : int

Maximum number of '?' parameters on a single statement.

Returns 100.

=cut

sub MAX_PARAMETERS {
    # This value is somewhat arbitrary, but we've tested this up to
    # 230.  The problem is it depends on the statement complexity...
    # Deleting 100 at a time seems like it gets the biggest impact.
    return 100;
}

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Bivio::Ext::DBI;
use Bivio::IO::Alert;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;
use Bivio::Type::DateTime;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_IDI) = __PACKAGE__->instance_data_index;
my($_CONNECTIONS) = {};
my($_DEFAULT_DBI_NAME);
# Number of times we retry a single statement.
my($_MAX_RETRIES) = 3;

=head1 FACTORIES

=cut

=for html <a name="internal_new"></a>

=head2 static internal_new(string dbi_name) : Bivio::SQL::Connection

Creates a new connection which uses the specified DBI config name.
Do not call this method directly, use L<connect|"connect">.

=cut

sub internal_new {
    my($proto, $dbi_name) = @_;
    my($self) = Bivio::UNIVERSAL::new($proto);
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

=head1 METHODS

=cut

=for html <a name="commit"></a>

=head2 commit()

Commits all open transactions.

=cut

sub commit {
    my($self) = @_;
    return _get_instance($self)->commit
	    unless ref($self);
    my($fields) = $self->[$_IDI];
    return unless $fields->{need_commit};
    _trace('commit') if $_TRACE;
    _get_connection($self)->commit() unless $fields->{db_is_read_only};
    $fields->{need_commit} = 0;
    return;
}

=for html <a name="connect"></a>

=head2 static create() : Bivio::SQL::Connection

=head2 static create(string dbi_name) : Bivio::SQL::Connection

Returns a connection instance which uses the specified database
configuration.

=cut

sub create {
    my($proto, $dbi_name) = @_;

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

=for html <a name="disconnect"></a>

=head2 disconnect()

Disconnects from database.

=cut

sub disconnect {
    my($self) = @_;
    return _get_instance($self)->disconnect
	    unless ref($self);
    my($fields) = $self->[$_IDI];
    _get_connection($self)->disconnect();
    $fields->{connection_pid} = undef;
    $fields->{connection} = undef;
    return;
}

=for html <a name="execute"></a>

=head2 execute(string sql)

=head2 execute(string sql, array_ref params)

=head2 execute(string sql, array_ref params, ref die)

=head2 execute(string sql, array_ref params, ref die, boolean has_blob)

Executes the specified statement and dies with an appropriate error
if it fails.

B<NOTE: All calls must go through this>

I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.

If I<has_blob> is specified, the arguments are scanned for a scalar_ref.
If found, the positional parameter is bound properly.  If no scalar_ref
is found, then the BLOB is assumed to be an output parameter and
I<LongReadLen> and I<LongTruncOk> are set accordingly.

We retry on certain errors (see
L<internal_get_retry_sleep|"internal_get_retry_sleep">).

=cut

sub execute {
    my($self, $sql, $params, $die, $has_blob) = @_;
    return _get_instance($self)->execute($sql, $params, $die, $has_blob)
	    unless ref($self);
    my($fields) = $self->[$_IDI];

    $sql = $self->internal_fixup_sql($sql);
    my($err, $errstr, $statement);
    my($retries) = 0;
 TRY: {
	# Execute the statement
	my($start_time) = Bivio::Type::DateTime->gettimeofday();
	my($ok) = Bivio::Die->eval(sub {
        	_execute_helper($self, $sql, $params, $has_blob, \$statement);
		return 1;
	    });
	$self->increment_db_time($start_time);
	return $statement if $ok;

	# Extract the errors
	$err = $statement && $statement->err ? $statement->err + 0 : 0;
	$errstr = $statement && $statement->errstr ? $statement->errstr : '';

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

    # Clean up just in case statement is cached
    Bivio::Die->eval(sub {
	$statement->finish if $statement;
    });

    # Throw exception
    $die ||= 'Bivio::Die';
    $die->throw_die($die_code, $attrs, caller);
    # DOES NOT RETURN
}

=for html <a name="execute_one_row"></a>

=head2 execute_one_row(string sql, array_ref params, ref die, boolean has_blob) : array_ref

Calls L<execute|"execute"> and returns the first row as an array_ref.
If there is no row, returns C<undef>.

=cut

sub execute_one_row {
    my($self) = shift;
    return _get_instance($self)->execute_one_row(@_)
	    unless ref($self);
    my($sth) = $self->execute(@_);
    my($row) = $sth->fetchrow_arrayref;
    $sth->finish;
    return $row;
}

=for html <a name="get_db_time"></a>

=head2 get_db_time() : int

If tracing is enabled, this returns the amount of time spent processing
database requests. Invoking this method clears the counter.

=cut

sub get_db_time {
    my($self) = @_;
    return _get_instance($self)->get_db_time
	    unless ref($self);
    my($fields) = $self->[$_IDI];
    my($result) = $fields->{db_time};
    $fields->{db_time} = 0;
    return $result;
}

=for html <a name="get_dbi_prefix"></a>

=head2 static abstract get_dbi_prefix(hash_ref cfg) : string

Returns the DBI connect prefix for the database.

=cut

$_ = <<'}'; # emacs
sub get_dbi_prefix {
}

=for html <a name="increment_db_time"></a>

=head2 increment_db_time(int start_time) : int

If tracing is enabled, this increments the database time counter and
returns its new value.

=cut

sub increment_db_time {
    my($self, $start_time) = @_;
    return _get_instance($self)->increment_db_time($start_time)
	    unless ref($self);
    my($fields) = $self->[$_IDI];
    die('invalid start_time') unless $start_time;
    $fields->{db_time} += Bivio::Type::DateTime->gettimeofday_diff_seconds(
	    $start_time);
    return $fields->{db_time};
}

=for html <a name="internal_clear_ping"></a>

=head2 internal_clear_ping()

Clears the need_ping state.

=cut

sub internal_clear_ping {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{need_ping} = 0;
    return;
}

=for html <a name="internal_dbi_connect"></a>

=head2 static internal_dbi_connect(string dbi_name) : Bivio::Ext::DBI

Connects to the database.  Returns the database handle.

=cut

sub internal_dbi_connect {
    my(undef, $dbi_name) = @_;
    return Bivio::Ext::DBI->connect($dbi_name);
}

=for html <a name="internal_fixup_sql"></a>

=head2 internal_fixup_sql(string sql) : string

Performs any database specific changes to the Oracle SQL string.

=cut

sub internal_fixup_sql {
    my($self, $sql) = @_;
    return $sql;
}

=for html <a name="internal_get_dbi_connection"></a>

=head2 internal_get_dbi_connection() : connection

Returns the raw DBI connection.

=cut

sub internal_get_dbi_connection {
    my($self) = @_;
    return _get_connection($self);
}

=for html <a name="internal_get_error_code"></a>

=head2 internal_get_error_code(hash_ref die_attrs) : Bivio::Type::Enum

Converts the database error into an appropriate error code. Subclasses
should override this to handle constraint violations.

=cut

sub internal_get_error_code {
    my($self, $die_attrs) = @_;
    $die_attrs->{program_error} = 1;
    # Unexpected error is treated as an assertion fault
    return Bivio::DieCode::DB_ERROR();
}

=for html <a name="internal_get_retry_sleep"></a>

=head2 internal_get_retry_sleep(int error, string message) : int

Returns the number of seconds to sleep for the specified transient
error code. 0 indicates retry immediately, undef indicates don't
retry.

=cut

sub internal_get_retry_sleep {
    return undef;
}

=for html <a name="internal_execute_blob"></a>

=head2 abstract internal_prepare_blob(boolean is_select, array_ref params, scalar_ref statement) : array_ref

Prepares the statement which store a blob. By default this method is not
implemented.
Returns the altered statement params.

=cut

$_ = <<'}'; # emacs
sub internal_prepare_blob {
}

=for html <a name="is_read_only"></a>

=head2 is_read_only() : boolean

Returns true if the current database connection is to a read-only
database.

=cut

sub is_read_only {
    my($self) = @_;
    return _get_instance($self)->is_read_only
	    unless ref($self);
    my($fields) = $self->[$_IDI];
    return $fields->{db_is_read_only};
}

=for html <a name="next_primary_id"></a>

=head2 abstract next_primary_id(string table_name, ref die) : string

Subclasses should return the next sequence number for the specified
table.

=cut

sub next_primary_id {
    my($self, $table_name, $die) = @_;
    return _get_instance($self)->next_primary_id($table_name, $die)
	    unless ref($self);
    Bivio::Die->die('abstract method');
    # DOES NOT RETURN
}

=for html <a name="rollback"></a>

=head2 rollback()

Rolls back all open transactions.

=cut

sub rollback {
    my($self) = @_;
    return _get_instance($self)->rollback
	    unless ref($self);
    my($fields) = $self->[$_IDI];
    return unless $fields->{need_commit};
    _trace('rollback') if $_TRACE;
    _get_connection($self)->rollback() unless $fields->{db_is_read_only};
    $fields->{need_commit} = 0;
    return;
}

=for html <a name="set_dbi_name"></a>

=head2 static set_dbi_name(string name) : string

Sets the name of the L<Bivio::Ext::DBI|Bivio::Ext::DBI> configuration
to use.  The default is C<undef>.  Returns the previous name.

Doesn't do anything if I<name> is not different from the current name.

The name selected will become the default database for all static calls.

=cut

sub set_dbi_name {
    my(undef, $name) = @_;

    # Don't do anything if the names are equal
    return $name if defined($name) == defined($_DEFAULT_DBI_NAME)
	    && (!defined($name) || $name eq $_DEFAULT_DBI_NAME);

    my($old) = $_DEFAULT_DBI_NAME;
    $_DEFAULT_DBI_NAME = $name;
    _trace('default db set to ', $name) if $_TRACE;
    return $old;
}

#=PRIVATE METHODS

# _execute_helper(string sql, array_ref params, boolean has_blob, scalar_ref statement)
#
# Executes sql.  Exception must be caught by caller. Sets statement (even on
# error).
#
sub _execute_helper {
    my($self, $sql, $params, $has_blob, $statement) = @_;
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

# _get_instance(proto) : Bivio::SQL::Connection
#
# Returns the default instance.
#
sub _get_instance {
    my($proto) = @_;
    return $proto->create($_DEFAULT_DBI_NAME);
}

# static _get_connection(self) : connection
#
# Returns a cached database connection for this process.  Checks the
# connection for validity.
#
sub _get_connection {
    my($self) = @_;
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

# _prep_params_for_io(array_ref params) : array_ref
#
# Returns an array which can be passed to Bivio::IO.
#
sub _prep_params_for_io {
    my($params) = @_;
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

# _trace_sql(string sql, array_ref params)
#
# Traces the specified sql statement with parameters.
#
sub _trace_sql {
    my($sql, $params) = @_;
    # Let trace deal with string truncation and undef
    _trace($sql, '; params=', @{_prep_params_for_io($params)});
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
