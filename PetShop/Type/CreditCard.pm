# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::CreditCard;
use strict;
$Bivio::PetShop::Type::CreditCard::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Type::CreditCard::VERSION;

=head1 NAME

Bivio::PetShop::Type::CreditCard - credit card number

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Type::CreditCard;

=cut

=head1 EXTENDS

L<Bivio::Type::Line>

=cut

use Bivio::Type::Line;
@Bivio::PetShop::Type::CreditCard::ISA = ('Bivio::Type::Line');

=head1 DESCRIPTION

C<Bivio::PetShop::Type::CreditCard>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
