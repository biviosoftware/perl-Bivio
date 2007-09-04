# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
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

C<Bivio::PetShop::Test::PetShop> tracks the shopping cart in an internal
field.  L<verify_cart|"verify_cart"> uses this to test the results.

=cut

#=IMPORTS
use Bivio::Type::Amount;
use Bivio::PetShop::Util;

#=VARIABLES
my($_A) = 'Bivio::Type::Amount';
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 METHODS

=cut

=for html <a name="add_to_cart"></a>

=head2 add_to_cart(string item_name)

Selects the 'Add to Cart' button for I<item_name>.  Saves items in the internal
copy of the cart.  If I<item_name> is not supplied, assumes there is a single
add_to_cart link.

=cut

sub add_to_cart {
    my($self, $item_name) = @_;
    my($fields) = $self->[$_IDI] ||= {};
    my($button) = 'add_to_cart';
    my($price);
    if ($item_name) {
	my($rows) = $self->get_html_parser
	    ->get_nested('Tables', 'Item ID', 'rows');
	my($i) = -1;
	foreach my $row (@$rows) {
	    $i++;
	    next unless $row->[1]->get('text') eq $item_name;
	    $price = $row->[2]->get('text');
	    $button .= "_$i";
	    last;
	}
	die($item_name, ': not found in table')
	    unless $price;
    }
    else {
	my($row) = $self->get_html_parser
	    ->get_nested('Tables', 'item', 'rows', 0);
	$item_name = $row->[0]->get('text');
	$price = $row->[1]->get('text');
    }
    $self->submit_form($button => {});
    (($fields->{cart} ||= {})->{$item_name} ||= {
	name => $item_name,
	quantity => 0,
	price => $price,
    })->{quantity}++;
    $self->verify_cart;
    return;
}

=for html <a name="checkout_as_demo"></a>

=head2 checkout_as_demo()

Checks out.  Must be on a page already.
Logs in as demo user, if need be.

=cut

sub checkout_as_demo {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    $self->login_as_demo;
    $self->follow_link('Cart');
    $self->verify_cart;
    $self->submit_form('checkout');
    # Displays what's in the cart (check this?)
    $self->follow_link('continue');
    # Is filled in by default
    $self->verify_text('Credit Card Information');
    $self->submit_form('continue');
    $self->verify_text('Shipping Address');
    $self->submit_form('continue');
#   $self->verify_order();
    $self->delete($fields->{cart});
    return;
}

=for html <a name="create_forum"></a>

=head2 create_forum()

Logs out if logged in.

=cut

sub create_forum {
    my($self) = @_;
    $self->home_page();
    $self->login_as('root');
    $self->basic_authorization('root');
    (my $f = $self->test_name . $self->random_string) =~ s/\W+//g;
    my($u) = '/dav/Forums.csv';
    $self->send_request(GET => $u);
    $self->send_request(PUT => $u, undef, $self->get_content() . "$f,$f\n");
    return $f;
}

=for html <a name="do_logout"></a>

=head2 do_logout()

Logs out if logged in.

=cut

sub do_logout {
    my($self) = @_;
    $self->follow_link('Sign-out')
	if $self->text_exists('Sign-out');
}

=for html <a name="login_as"></a>

=head2 login_as(string user, string password)

Logs in as I<user> and I<password>.

=cut

sub login_as {
    my($self, $user, $password) = @_;
    $self->do_logout();
    $self->follow_link('Sign-in');
    $self->submit_form(submit => {
        'Email:' => $user,
	'Password:' => defined($password) ? $password
	    : Bivio::PetShop::Util->PASSWORD,
    });
    $self->verify_text('Sign-out');
    return;
}

=for html <a name="login_as_demo"></a>

=head2 login_as_demo()

Logs in as demo user.  Returns to the current page.

=cut

sub login_as_demo {
    return shift->login_as(Bivio::PetShop::Util->DEMO);
}

=for html <a name="remove_from_cart"></a>

=head2 remove_from_cart(string item_name)

Removes I<item_name> from cart.

=cut

sub remove_from_cart {
    my($self, $item_name) = @_;
    my($fields) = $self->[$_IDI];
    _find_in_cart($self, $item_name, sub {
	my($index) = @_;
	$self->submit_form("remove_$index");
	return;
    });
    delete($fields->{cart}->{$item_name});
    $self->verify_cart;
    return;
}

=for html <a name="search_for"></a>

=head2 search_for(string words)

Submits the search form with I<words>.

=cut

sub search_for {
    my($self, $words) = @_;
    $self->submit_form(search => {
	anon => $words,
    });
    return;
}

=for html <a name="update_cart"></a>

=head2 update_cart(string item_name, int quantity)

Sets I<quantity> for I<item_name> in the cart.

=cut

sub update_cart {
    my($self, $item_name, $quantity) = @_;
    my($fields) = $self->[$_IDI];
    _find_in_cart($self, $item_name, sub {
	my($index) = @_;
	$self->submit_form(update_cart => {
	    "Quantity_$index" => $quantity,
	});
	return;
    })->{quantity} = $quantity
	or delete($fields->{cart}->{$item_name});
    $self->verify_cart;
    return;
}

=for html <a name="verify_cart"></a>

=head2 verify_cart()

Verifies that the named item(s) are in the cart.  Verifies the total.
If no arguments supplied, calls L<verify_cart_is_empty|"verify_cart_is_empty">.

=cut

sub verify_cart {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $self->verify_cart_is_empty
	unless $fields->{cart} && %{$fields->{cart}};
    my($cart) = {%{$fields->{cart}}};
    # Tables are named by their first column by default
    my($t) = _cart($self)->get_html_parser->get('Tables')
	->unsafe_get('Remove');
    Bivio::Die->die('cart is empty, expecting items: ', $cart)
	unless $t;
    my($rows) = [@{$t->{rows}}];
    my($i) = 0;
    my($total) = 0;
    foreach my $item (sort({$a->{name} cmp $b->{name}} values(%$cart))) {
	my($r) = shift(@$rows);
	Bivio::Die->die("too few rows ($i); missing items: ", $cart)
	    unless $r;
	Bivio::Die->die("missing item: ", $item)
	    unless $r->[2]->get('text') eq $item->{name};
	Bivio::Die->die("incorrect quantity (",
            $r->[5]->get('text'), ") for: ", $item)
	    unless $r->[5]->get('text') == $item->{quantity};
	my($t) = $_A->mul($item->{quantity}, $item->{price});
	Bivio::Die->die("incorrect total cost (",
            $r->[6]->get('text'), ") for: ", $item)
	    unless $_A->compare($r->[6]->get('text'), $t) == 0;
	$total = $_A->add($total, $t);
    }
    continue {
	delete($cart->{$item->{name}});
	$i++;
    }
    Bivio::Die->die("too many rows (expected $i); extra items: ", $rows)
	if @$rows != 1 || $rows->[0]->[1]->get('text') ne 'Total:';
    Bivio::Die->die("incorrect total ($rows->[0]->[6]), expected ", $total)
	unless $_A->compare($rows->[0]->[6]->get('text'), $total) == 0;
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

# _find_in_cart(self, string item_name, code_ref op) : hash_ref
#
# Returns item in internal cart.
#
sub _find_in_cart {
    my($self, $item_name, $op) = @_;
    my($fields) = $self->[$_IDI];
    my($t) = _cart($self)->get_html_parser->get('Tables')
	->unsafe_get('Remove');
    my($i) = -1;
    foreach my $row (@{$t->{rows}}) {
	$i++;
	next unless $row->[2]->get('text') eq $item_name;
	$op->($i);
	die('no items in internal cart')
	    unless $fields->{cart} && %{$fields->{cart}};
	return $fields->{cart}->{$item_name}
	    || die(qq{item "$item_name" not in internal cart});
    }
    die(qq{item "$item_name" not in cart});
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
