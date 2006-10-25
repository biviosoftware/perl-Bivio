# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Connection::MySQL;
use strict;
$Bivio::SQL::Connection::MySQL::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::SQL::Connection::MySQL::VERSION;

=head1 NAME

Bivio::SQL::Connection::MySQL - connection to a PostgreSQL database

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::SQL::Connection::MySQL;

=cut

=head1 EXTENDS

L<Bivio::SQL::Connection>

=cut

use Bivio::SQL::Connection;
@Bivio::SQL::Connection::MySQL::ISA = ('Bivio::SQL::Connection');

=head1 DESCRIPTION

C<Bivio::SQL::Connection::MySQL>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_dbi_prefix"></a>

=head2 static get_dbi_prefix(hash_ref cfg) : string

Returns the PostgreSQL DBI connection prefix.

=cut

sub get_dbi_prefix {
    return 'DBI:mysql:database=';
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
