# Copyright (c) 2002-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Test::PetShop;
use strict;
use Bivio::Base 'Bivio::Test::Language::HTTP';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub add_to_cart {
    my($self, $item_name) = @_;
    # Selects the 'Add to Cart' button for I<item_name>.  Saves items in the internal
    # copy of the cart.  If I<item_name> is not supplied, assumes there is a single
    # add_to_cart link.
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

sub checkout_as_demo {
    my($self) = @_;
    # Checks out.  Must be on a page already.
    # Logs in as demo user, if need be.
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

sub create_forum {
    my($self) = @_;
    $self->home_page;
    $self->login_as('root');
    $self->basic_authorization('root');
    (my $f = $self->test_name . $self->random_string) =~ s/\W+//g;
    my($u) = '/dav/Forums.csv';
    $self->send_request(GET => $u);
    $self->send_request(PUT => $u, undef, $self->get_content() . "$f,$f\n");
    return ($f, "/$f", "/dav/$f");
}

sub do_logout {
    my($self) = @_;
    # Logs out if logged in.
    $self->follow_link('Sign-out')
	if $self->text_exists('Sign-out');
}

sub login_as {
    my($self, $user, $password) = @_;
    # Logs in as I<user> and I<password>.
    $self->do_logout();
    $self->follow_link('Sign-in');
    $self->submit_form(submit => {
        'Email:' => $user,
	'Password:' => defined($password) ? $password
	    : $self->use('Bivio::PetShop::Util')->PASSWORD,
    });
    $self->verify_text('Sign-out');
    return;
}

sub login_as_demo {
    my($self) = @_;
    return $self->login_as($self->use('Bivio::PetShop::Util')->DEMO);
}

sub next_message_id {
    my($self) = @_;
    my($i) = $self->get_or_default(next_message_id_index => 1);
    $self->get_if_exists_else_put(
	next_message_id_prefix => sub {$self->random_string() . '.'});
    my($res) = '<' . $self->get('next_message_id_prefix') . $i
	. '@' . $self->get('local_mail_host') . '>';
    $self->put(next_message_id_index => ++$i);
    return $res;
}

sub remove_from_cart {
    my($self, $item_name) = @_;
    # Removes I<item_name> from cart.
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

sub search_for {
    my($self, $words) = @_;
    # Submits the search form with I<words>.
    $self->submit_form(search => {
	anon => $words,
    });
    return;
}

sub update_cart {
    my($self, $item_name, $quantity) = @_;
    # Sets I<quantity> for I<item_name> in the cart.
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

sub verify_cart {
    my($self) = @_;
    # Verifies that the named item(s) are in the cart.  Verifies the total.
    # If no arguments supplied, calls L<verify_cart_is_empty|"verify_cart_is_empty">.
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
    my($ta) = $self->use('Type.Amount');
    foreach my $item (sort({$a->{name} cmp $b->{name}} values(%$cart))) {
	my($r) = shift(@$rows);
	Bivio::Die->die("too few rows ($i); missing items: ", $cart)
	    unless $r;
	Bivio::Die->die("missing item: ", $item)
	    unless $r->[2]->get('text') eq $item->{name};
	Bivio::Die->die("incorrect quantity (",
            $r->[5]->get('text'), ") for: ", $item)
	    unless $r->[5]->get('text') == $item->{quantity};
	my($t) = $ta->mul($item->{quantity}, $item->{price});
	Bivio::Die->die("incorrect total cost (",
            $r->[6]->get('text'), ") for: ", $item)
	    unless $ta->compare($r->[6]->get('text'), $t) == 0;
	$total = $ta->add($total, $t);
    }
    continue {
	delete($cart->{$item->{name}});
	$i++;
    }
    Bivio::Die->die("too many rows (expected $i); extra items: ", $rows)
	if @$rows != 1 || $rows->[0]->[1]->get('text') ne 'Total:';
    Bivio::Die->die("incorrect total ($rows->[0]->[6]), expected ", $total)
	unless $ta->compare($rows->[0]->[6]->get('text'), $total) == 0;
    return;
}

sub verify_cart_is_empty {
    my($self) = @_;
    # Asserts cart is empty.  Goes to cart page if not already there.
    _cart($self)->verify_text('Your shopping cart is empty');
    return;
}

sub _cart {
    my($self) = @_;
    # Goes to shopping cart page.  Must already be on another page.
    # Assumes cart isn't sorted
    $self->follow_link('Cart')
	unless $self->get_html_parser->get_nested('Cleaner', 'html')
	    =~ /Shopping Cart:/;
    return $self;
}

sub _find_in_cart {
    my($self, $item_name, $op) = @_;
    # Returns item in internal cart.
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

1;
