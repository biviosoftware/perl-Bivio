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
use Bivio::Type::Amount;

#=VARIABLES
my($_A) = 'Bivio::Type::Amount';

=head1 METHODS

=cut

=for html <a name="add_to_cart"></a>

=head2 add_to_cart()

Selects the 'Add to Cart' button.  Saves items in the internal copy
of the cart.

=cut

sub add_to_cart {
    my($self) = @_;
    my($cart) = $self->unsafe_get('petshop_cart');
    $self->put(petshop_cart => $cart = {})
	unless $cart;
    my($row) = $self->get_html_parser->get_nested('Tables', 'item', 'rows', 0);
    ($cart->{$row->[0]} ||= {
	name => $row->[0],
	quantity => 0,
	price => $row->[1],
    })->{quantity}++;
    $self->submit_form(add_to_cart => {});
    return;
}

=for html <a name="checkout_as_demo"></a>

=head2 checkout_as_demo()

Checks out.  Must be on a page already.
Logs in as demo user, if need be.

=cut

sub checkout_as_demo {
    my($self) = @_;
    $self->login_as_demo;
    $self->follow_link('Cart');
    $self->verify_cart();
    $self->submit_form('checkout');
    # Displays what's in the cart (check this?)
    $self->follow_link('continue');
    # Is filled in by default
    $self->verify_text('Credit Card Information');
    $self->submit_form('continue');
    $self->verify_text('Shipping Address');
    $self->submit_form('continue');
#   $self->verify_order();
    $self->delete('petshop_cart');
    return;
}

=for html <a name="login_as_demo"></a>

=head2 login_as_demo()

Logs in as demo user.  Returns to the current page.

=cut

sub login_as_demo {
    my($self) = @_;
    $self->follow_link('Sign-in');
    $self->submit_form(submit => {
        'Email:' => 'demo',
	'Password:' => 'password',
    });
    $self->verify_text('Sign-out');
    return;
}

=for html <a name="verify_cart"></a>

=head2 verify_cart()

Verifies that the named item(s) are in the cart.  Verifies the total.
If no arguments supplied, calls L<verify_cart_is_empty|"verify_cart_is_empty">.

=cut

sub verify_cart {
    my($self) = @_;
    my($cart) = $self->unsafe_get('petshop_cart') || {};
    return $self->verify_cart_is_empty
	unless %$cart;
    # Tables are named by their first column by default
    my($t) = _cart($self)->get_html_parser->get('Tables')
	->unsafe_get('Remove');
    Bivio::Die->die('cart is empty, expecting items: ', $cart)
	unless $t;
    my($rows) = [@{$t->{rows}}];
    my($i) = 0;
    my($total) = 0;
    foreach my $item (sort({$a->{name} <=> $b->{name}} values(%$cart))) {
	my($r) = shift(@$rows);
	Bivio::Die->die("too few rows ($i); missing items: ", $cart)
	    unless $r;
	Bivio::Die->die("missing item: ", $item)
	    unless $r->[2] eq $item->{name};
	Bivio::Die->die("incorrect quantity ($r->[5]) for: ", $item)
	    unless $r->[5] == $item->{quantity};
	my($t) = $_A->mul($item->{quantity}, $item->{price});
	Bivio::Die->die("incorrect total cost ($r->[6]) for: ", $item)
	    unless $_A->compare($r->[6], $t) == 0;
	$total = $_A->add($total, $t);
    }
    continue {
	delete($cart->{$item->{name}});
	$i++;
    }
    Bivio::Die->die("too many rows (expected $i); extra items: ", $rows)
	if @$rows != 1 || $rows->[0]->[1] ne 'Total:';
    Bivio::Die->die("incorrect total ($rows->[0]->[6]), expected ", $total)
	unless $_A->compare($rows->[0]->[6], $total) == 0;
    return;
}

=for html <a name="verify_cart_is_empty"></a>

=head2 verify_cart_is_empty()

Asserts cart is empty.  Goes to cart page if not already there.

=cut

sub verify_cart_is_empty {
    my($self) = @_;
    _cart($self)->verify_text('Your shopping cart is empty');
    return;
}

#=PRIVATE SUBROUTINES

# _cart(self)
#
# Goes to shopping cart page.  Must already be on another page.
#
sub _cart {
    my($self) = @_;
    # Assumes cart isn't sorted
    $self->follow_link('Cart')
	unless $self->get_html_parser->get_nested('Cleaner', 'html')
	    =~ /Shopping Cart:/;
    return $self;
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
