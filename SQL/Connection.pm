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
to transact with the database. Connection maintains one connection
to the database at all times.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Carp ();
use Bivio::Ext::DBI;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_CONNECTION);
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
    my($self) = @_;

    &_trace('commit') if $_TRACE;
    $self->get_connection()->commit();
    return;
}

=for html <a name="execute"></a>

=head2 execute(statement sth)

=head2 execute(statement sth, array_ref params)

=head2 execute(statement sth, array_ref params, ref die)

Executes the specified statement and dies with an appropriate error
if it fails.

I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.

=cut

sub execute {
    my($self, $sql, $params, $die) = @_;

    my($statement);
    eval {
	_trace_sql($sql, $params) if $_TRACE;
	my($start_time) = Bivio::Util::gettimeofday();
#TODO: Need to investigate problems and performance of cached statements
#TODO: If do cache, then make sure not "active" when making call.
	$statement = $self->get_connection->prepare($sql);
	ref($params) ? $statement->execute(@$params)
		: $statement->execute();
	$self->increment_db_time($start_time);
    };
    return $statement unless $@;

    my($err) = $statement->err;
    my($attrs) = {
	message => $@,
	dbi_err => $err,
	dbi_errstr => $statement->errstr,
	sql => $sql,
	sql_params => $params,
    };
    eval {
	# Clean up just in case statement is cached
	$statement->finish;
    };
#TODO: add more application error processing here
#TODO: Add reply processingn
    my($die_code) = defined($err) && defined($_ERR_TO_DIE_CODE{$err})
	    ? $_ERR_TO_DIE_CODE{$err} : Bivio::DieCode::UNKNOWN;
    $die ||= 'Bivio::Die';
    $die->die($die_code, $attrs, caller);
}

=for html <a name="get_connection"></a>

=head2 static get_connection() : connection

Returns a cached database connection.

=cut

sub get_connection {
    if (!$_CONNECTION) {
	&_trace('creating connection') if $_TRACE;
	$_CONNECTION = Bivio::Ext::DBI->connect();
    }
    return $_CONNECTION;
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
    my($self) = @_;

    &_trace('rollback') if $_TRACE;
    $self->get_connection()->rollback();
    return;
}

#=PRIVATE METHODS

# _trace_sql(string sql, array_ref params)
#
# Traces the specified sql statement with parameters.

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
