# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Test::PetShop;
use strict;
$Bivio::PetShop::Test::PetShop::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Test::PetShop::VERSION;

=head1 NAME

Bivio::PetShop::Test::PetShop - test language for the PetShop

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Test::PetShop;

=cut

=head1 EXTENDS

L<Bivio::Test::Language::HTTP>

=cut

use Bivio::Test::Language::HTTP;
@Bivio::PetShop::Test::PetShop::ISA = ('Bivio::Test::Language::HTTP');

=head1 DESCRIPTION

C<Bivio::PetShop::Test::PetShop>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="add_to_cart"></a>

=head2 add_to_cart()

Selects the 'Add to Cart' button.

=cut

sub add_to_cart {
    my($self) = @_;
    $self->submit_form(add_to_cart => {});
    return;
}

=for html <a name="verify_cart"></a>

=head2 verify_cart(string item_name)

Verifies that the named item is in the cart.

=cut

sub verify_cart {
    my($self, $item_name) = @_;
    $self->verify_text($item_name);
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
