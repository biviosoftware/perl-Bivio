# Copyright (c) 2002-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Test::PetShop;
use strict;
use Bivio::Base 'TestLanguage.HTTP';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_SQL) = b_use('ShellUtil.SQL');
my($_CSV) = b_use('ShellUtil.CSV');
my($_D) = b_use('Type.Date');

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
	b_die($item_name, ': not found in table')
	    unless $price;
    }
    else {
	my($row) = $self->get_html_parser
	    ->get_nested('Tables', 'item', 'rows', 0);
	($item_name) = $self->get_content() =~ /pet_title">(.*?)</;
	$price = $row->[2]->get('text');
	$price =~ s/\s+.*//;
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
    $self->submit_form('continue', {
	'_anon#0' => $_D->get_parts($_D->now, 'year') + 1,
    });
    $self->verify_text('Shipping Address');
    $self->submit_form('continue');
    $self->delete($fields->{cart});
    return;
}

sub create_crm_forum {
    my($self, $admins) = @_;
    $admins ||= [];
    my($name, $uri, $dav) = $self->create_forum;
    my($u) = "$dav/Members.csv";
    $self->send_request(GET => $u);
    $self->send_request(PUT => $u, undef, $self->get_content()
        . ${$_CSV->to_csv_text([
            #[Email,Subscribed?,Write Files?,Administrator?]
            map([$self->generate_local_email($_), 1, 1, 1], @$admins)
        ])},
    ) if @$admins;
    $self->do_test_backdoor(CRM => "-realm $name setup_realm");
    return ($name, $uri);
}

sub create_forum {
    my($self) = @_;
    $self->home_page;
    $self->login_as('root');
    $self->basic_authorization('root');
    my($f) = 'btest_'
	. (lc($self->test_name) =~ /^(\w+)/)[0]
	. '_'
	. $self->random_string;
    (my $dn = ucfirst($f)) =~ s/_/ /g;
    my($u) = '/dav/Forums.csv';
    $self->send_request(GET => $u);
    $self->send_request(
	PUT => $u,
	undef,
	$self->get_content . ${$_CSV->to_csv_text([$f, $dn])},
    );
    push(@{$self->[$_IDI]->{cleanup_realm} ||= []}, $f);
    return ($f, "/$f", "/dav/$f");
}

sub create_user {
    my($self) = @_;
    $self->clear_cookies;
    $self->home_page;
    $self->follow_link('register');
    my($n) = $self->random_string;
    $self->submit_form({
	email => my $e = $self->generate_local_email($n),
	name => $n,
    });
    $self->follow_link_in_mail($e);
    $self->submit_form({
	'^new' => $self->default_password,
	'^re-en' => $self->default_password,
    });
    push(@{$self->[$_IDI]->{cleanup_user} ||= []}, $e);
    return ($e, $n);
}

sub do_logout {
    my($self) = @_;
    $self->basic_authorization;
    if ($self->text_exists('Sign-out')) {
 	$self->follow_link('Sign-out');
    }
    elsif ($self->text_exists(qr{>Logout<}i)) {
 	$self->follow_link('Logout');
    }
    else {
	$self->visit_uri('/pub/logout');
    }
    $self->groupware_check;
    return;
}

sub groupware_check {
    my($self) = @_;
    $self->home_page
	if $self->unsafe_get('groupware_mode');
    return;
}

sub handle_cleanup {
    my($self, $die) = @_;
    unless ($die) {
	my($fields) = $self->[$_IDI];
#TODO: 'user' does not work, because constraint realm_file_t10
	foreach my $which (qw(realm )) {
	    foreach my $name (@{delete($fields->{"cleanup_$which"}) || []}) {
		$self->do_test_backdoor(
		    'RealmAdmin',
		    "-$which $name -force delete_auth_$which",
		);
	    }
	}
    }
    return shift->SUPER::handle_cleanup(@_);
}

sub handle_setup {
    my($self, $mode) = @_;
    shift->SUPER::handle_setup(@_);
    $self->put(groupware_mode => ($mode || '') eq 'groupware');
    return;
}

sub home_page {
    my($self) = shift;
    return $self->SUPER::home_page(@_)
	unless $self->unsafe_get('groupware_mode');
    $self->SUPER::home_page(@_)
	unless $self->unsafe_get_uri;
    $self->visit_uri('/bp');
    return;
}

sub login_as {
    my($self, $user, $password) = @_;
    # Logs in as I<user> and I<password>.
    $self->do_logout();
    $self->follow_link('register')
	if $self->text_exists(qr{>register<}i);
    $self->follow_link($self->text_exists('Sign-in') ? 'Sign-in' : 'login');
    $self->submit_form(submit => {
        'Email:' => $user,
	'Password:' => defined($password) ? $password : $_SQL->PASSWORD,
    });
    $self->verify_link(qr{Sign-out|logout}i);
    $self->groupware_check;
    return;
}

sub login_as_demo {
    my($self) = @_;
    return $self->login_as($_SQL->DEMO);
}

sub next_message_id {
    my($self) = @_;
    my($i) = $self->get_or_default(next_message_id_index => 1);
    $self->get_if_exists_else_put(
	next_message_id_prefix => sub {$self->random_string(128) . '.'});
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
	->unsafe_get('Item ID');
    b_die('cart is empty, expecting items: ', $cart)
	unless $t;
    my($rows) = [@{$t->{rows}}];
    my($i) = 0;
    my($total) = 0;
    my($ta) = $self->use('Type.Amount');
    foreach my $item (sort({$a->{name} cmp $b->{name}} values(%$cart))) {
	my($r) = shift(@$rows);
	b_die("too few rows ($i); missing items: ", $cart)
	    unless $r;
	b_die("missing item: ", $item)
	    unless $r->[2]->get('text') eq $item->{name};
	b_die("incorrect quantity (",
            $r->[5]->get('text'), ") for: ", $item)
	    unless $r->[5]->get('text') == $item->{quantity};
	my($t) = $ta->mul($item->{quantity}, $item->{price});
	b_die("incorrect total cost (",
            $r->[6]->get('text'), ") for: ", $item)
	    unless $ta->compare($r->[6]->get('text'), $t) == 0;
	$total = $ta->add($total, $t);
    }
    continue {
	delete($cart->{$item->{name}});
	$i++;
    }
    b_die("too many rows (expected $i); extra items: ", $rows)
	if @$rows != 1 || $rows->[0]->[1]->get('text') ne 'Total:';
    b_die("incorrect total ($rows->[0]->[6]), expected ", $total)
	unless $ta->compare($rows->[0]->[2]->get('text'), $total) == 0;
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
	->unsafe_get('Item ID');
    my($i) = -1;
    foreach my $row (@{$t->{rows}}) {
	$i++;
	next unless $row->[2]->get('text') eq $item_name;
	$op->($i);
	b_die('no items in internal cart')
	    unless $fields->{cart} && %{$fields->{cart}};
	return $fields->{cart}->{$item_name}
	    || b_die(qq{item "$item_name" not in internal cart});
    }
    b_die(qq{item "$item_name" not in cart});
    # DOES NOT RETURN
}

1;
