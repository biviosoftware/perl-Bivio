# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::SQL::Connection;
use strict;
$Bivio::SQL::Connection::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::SQL::Connection - a database connection manager

=head1 SYNOPSIS

    use Bivio::SQL::Connection;
    Bivio::SQL::Connection->execute('update user_t set name=?', ['foo']);

=cut

use Bivio::UNIVERSAL;
@Bivio::SQL::Connection::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::SQL::Connection> is a collection of static methods used
to transact with the database. This module maintains one connection
to the database at all times.  It will reset the connection if the
database the connection is lost.

B<Bivio::Agent::Task depends on the fact that this the only module
which modifies the database.>

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Bivio::Ext::DBI;
use Bivio::IO::Trace;
use Bivio::Util;
use Carp ();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_CONNECTION);
# Set to the pid that creates the connection.  Ensures all children
# use a different connection.
my($_CONNECTION_PID) = 0;
# If there is an error, this will be true.  _get_connection checks the
# connection with a ping to make sure it is still alive.
my($_NEED_PING) = 0;
my($_NEED_COMMIT) = 0;
my($_DB_TIME) = 0;
my(%_ERR_TO_DIE_CODE) = (
	1 => Bivio::DieCode::ALREADY_EXISTS(),
# Why bother?
#	1400 => Bivio::DieCode::ALREADY_EXISTS,
#	die('required value missing') if $err == 1400;
#    die('invalid number') if $err == 1722;
);
=head1 METHODS

=cut

=for html <a name="commit"></a>

=head2 commit()

Commits all open transactions.

=cut

sub commit {
    return unless $_NEED_COMMIT;
    &_trace('commit') if $_TRACE;
    _get_connection()->commit();
    $_NEED_COMMIT = 0;
    return;
}

=for html <a name="execute"></a>

=head2 execute(string sql)

=head2 execute(string sql, array_ref params)

=head2 execute(string sql, array_ref params, ref die)

Executes the specified statement and dies with an appropriate error
if it fails.

B<NOTE: All calls must go through this

I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.

=cut

sub execute {
    my($self, $sql, $params, $die) = @_;

    my($statement);
    Bivio::Die->eval(sub {
	_trace_sql($sql, $params) if $_TRACE;
	my($start_time) = Bivio::Util::gettimeofday();
#TODO: Need to investigate problems and performance of cached statements
#TODO: If do cache, then make sure not "active" when making call.
	$statement = _get_connection()->prepare($sql);
	# Only need a commit if there has been data modification language
	$_NEED_COMMIT = 1 if $sql !~ /^\s*select/i;
	ref($params) ? $statement->execute(@$params)
		: $statement->execute();
	$self->increment_db_time($start_time);
    });
    return $statement unless $@;

    # If we get an error, it may be a timed-out connection.  We'll
    # check the connection the next time through.
    $_NEED_PING = 1;
    my($err) = $statement ? $statement->err : 0;
    my($attrs) = {
	message => $@,
	dbi_err => $err,
	dbi_errstr => $statement ? $statement->errstr : '',
	sql => $sql,
	sql_params => $params,
    };
    Bivio::Die->eval(sub {
	# Clean up just in case statement is cached
	$statement->finish if $statement;
    });
#TODO: add more application error processing here
#TODO: Add reply processingn
    my($die_code);
    if (defined($err) && defined($_ERR_TO_DIE_CODE{$err})) {
	$err = $_ERR_TO_DIE_CODE{$err};
    }
    else {
	$attrs->{program_error} = 1;
	# Unexpected oracle error is treated as an assertion fault
	$die_code = Bivio::DieCode::DIE();
    }
    $die ||= 'Bivio::Die';
    $die->die($die_code, $attrs, caller);
}

=for html <a name="get_db_time"></a>

=head2 static get_db_time() : int

If tracing is enabled, this returns the amount of time spent processing
database requests. Invoking this method clears the counter.

=cut

sub get_db_time {
    return 0 if ! $_TRACE;
    my($result) = $_DB_TIME;
    $_DB_TIME = 0;
    return $result;
}

=for html <a name="increment_db_time"></a>

=head2 static increment_db_time(int start_time) : int

If tracing is enabled, this increments the database time counter and
returns its new value.

=cut

sub increment_db_time {
    my(undef, $start_time) = @_;
    Carp::croak('invalid start_time') unless $start_time;
    $_DB_TIME += Bivio::Util::time_delta_in_seconds($start_time);
    return $_DB_TIME;
}

=for html <a name="rollback"></a>

=head2 rollback()

Rolls back all open transactions.

=cut

sub rollback {
    return unless $_NEED_COMMIT;
    &_trace('rollback') if $_TRACE;
    _get_connection()->rollback();
    $_NEED_COMMIT = 0;
    return;
}

#=PRIVATE METHODS

# static _get_connection() : connection
#
# Returns a cached database connection for this process.  Checks the
# connection for validity.
#
sub _get_connection {
    if ($_CONNECTION_PID != $$) {
	if ($_CONNECTION) {
	    # This disconnects the parent process'.  Make sure we rollback
	    # any pending transactions.  By default, disconnect commits
	    Bivio::Die->eval(sub {
		$_CONNECTION->ping && $_CONNECTION->rollback});
	    Bivio::Die->eval(sub {$_CONNECTION->disconnect});
	    # Make sure we don't enter this code again.
	    $_CONNECTION = undef;
	}
	&_trace("creating connection: pid=$$") if $_TRACE;
	$_CONNECTION = Bivio::Ext::DBI->connect();
	# Got a connection which will be reused on next call.  We don't
	# need to ping it (just in case parent process had an error on
	# the connection).
	$_CONNECTION_PID = $$;
	$_NEED_PING = 0;
    }
    elsif ($_NEED_PING) {
	# Got an error on a previous use of this connection.  Make
	# sure is still valid.
	$_NEED_PING = 0;
	unless (Bivio::Die->eval(sub {$_CONNECTION->ping})) {
	    # Just in case, rollback any pending actions
	    # be executed.  Caller will reset $_CONNECTION
	    $_CONNECTION_PID = 0;
	    return _get_connection();
	}
	# Current connection is valid
    }
    return $_CONNECTION;
}

# _trace_sql(string sql, array_ref params)
#
# Traces the specified sql statement with parameters.
#
sub _trace_sql {
    my($sql, $params) = @_;
    my(@args);
    my($sep) = ' [';
    my($p);
    foreach $p (ref($params) ? @$params : ()) {
	push(@args, $sep, $p);
	$sep = ',';
    }
    @args && push(@args, ']');
    # Let trace deal with string truncation and undef
    &_trace($sql, @args);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
