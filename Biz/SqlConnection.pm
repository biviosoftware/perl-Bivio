# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::SqlConnection;
use strict;
$Bivio::Biz::SqlConnection::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::SqlConnection - a database connection manager

=head1 SYNOPSIS

    use Bivio::Biz::SqlConnection;

    my($con) = Bivio::Biz::SqlConnection->get_connection();
    my($statement) = $conn->prepare('update user_ set name=?');
    Bivio::Biz::SqlConnection->execute($statement, $model, 'foo');
    if ($model->get_status()->is_ok()) {
        Bivio::Biz::SqlConnection->commit();
    }
    else {
        Bivio::Biz::SqlConnection->rollback();
    }

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::SqlConnection::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::SqlConnection> is a collection of static methods used
to transact with the database. SqlConnection maintains one connection
to the database at all times.

=cut

#=IMPORTS
use Bivio::Biz::Error;
use Bivio::Ext::DBI;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_CONNECTION);
my($_DB_TIME) = 0;

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

=head2 execute(statement sth, Model m, string value, ...)

Executes the specified statement and adds the appropriate error to the
model if it fails.

=cut

sub execute {
    my(undef, $statement, $model, @values) = @_;

    eval {
	$statement->execute(@values);
    };

    # check for db errors
    if ($@) {
	my($err) = $statement->err;
	my($msg);

#TODO: add more application error processing here

	$msg = 'already exists' if $err == 1;
	$msg = 'required value missing' if $err == 1400;
	$msg = 'invalid number' if $err == 1722;

	if ($msg) {
	    &_trace($statement->errstr);
	    $model->get_status()->add_error(Bivio::Biz::Error->new($msg));
	}
	else {
	    # error not handled
	    die $@;
	}
    }
    return;
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

=head2 static increment_db_time(int amount) : int

If tracing is enabled, this increments the database time counter and
returns its new value.

=cut

sub increment_db_time {
    return 0 if ! $_TRACE;
    my(undef, $amount) = @_;

    $_DB_TIME += $amount;
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

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
