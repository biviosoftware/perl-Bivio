# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Password;
use strict;
$Bivio::Type::Password::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Password - a password value

=head1 SYNOPSIS

    use Bivio::Type::Password;

=cut

=head1 EXTENDS

L<Bivio::Type::Name>

=cut

use Bivio::Type::Name;
@Bivio::Type::Password::ISA = ('Bivio::Type::Name');

=head1 DESCRIPTION

C<Bivio::Type::Password> indicates the input is a password entry.
It should be handled with care, e.g. never displayed to user.

There are no special methods.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
