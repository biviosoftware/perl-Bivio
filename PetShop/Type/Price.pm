# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::Price;
use strict;
$Bivio::PetShop::Type::Price::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Type::Price::VERSION;

=head1 NAME

Bivio::PetShop::Type::Price - a decimal (10, 2) amount

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Type::Price;

=cut

=head1 EXTENDS

L<Bivio::Type::Number>

=cut

use Bivio::Type::Number;
@Bivio::PetShop::Type::Price::ISA = ('Bivio::Type::Number');

=head1 DESCRIPTION

C<Bivio::PetShop::Type::Price>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="get_decimals"></a>

=head2 static get_decimals : int

Returns 2.

=cut

sub get_decimals {
    return 2;
}

=for html <a name="get_max"></a>

=head2 static get_max : string

Returns '99999999.99'.

=cut

sub get_max {
    return '99999999.99';
}

=for html <a name="get_min"></a>

=head2 static get_min : string

Returns '-99999999.99'.

=cut

sub get_min {
    return '-99999999.99';
}

=for html <a name="get_precision"></a>

=head2 static get_precision : int

Returns 10.

=cut

sub get_precision {
    return 10;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
