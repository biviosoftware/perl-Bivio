# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::SqlConnection;
use strict;
$Bivio::Biz::SqlConnection::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::SqlConnection - a database connection manager

=head1 SYNOPSIS

    use Bivio::Biz::SqlConnection;
    Bivio::Biz::SqlConnection->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::SqlConnection::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::SqlConnection>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_CONNECTION);

=head1 METHODS

=cut

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

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
