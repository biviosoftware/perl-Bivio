# Copyright (c) 2003 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Connection::None;
use strict;
$Bivio::SQL::Connection::None::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::SQL::Connection::None::VERSION;

=head1 NAME

Bivio::SQL::Connection::None - connection to no database

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::SQL::Connection::None;

=cut

=head1 EXTENDS

L<Bivio::SQL::Connection>

=cut

use Bivio::SQL::Connection;
@Bivio::SQL::Connection::None::ISA = ('Bivio::SQL::Connection');

=head1 DESCRIPTION

C<Bivio::SQL::Connection::None> is not a database, but the default connnection
for when there is no database.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

#=PRIVATE METHODS


=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
