# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Location;
use strict;
$Bivio::Type::Location::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Location - identifies a physical location of address, phone, email

=head1 SYNOPSIS

    use Bivio::Type::Location;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::Location::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::Location> describes the physical location where an
address, phone, or email resides.  The current choices are:

=over 4

=item HOME

=item WORK

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

__PACKAGE__->compile(
    HOME => [
	1,
    ],
    WORK => [
	2,
    ],
       );


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
