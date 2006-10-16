# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::Cart;
use strict;
$Bivio::PetShop::Model::Cart::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::Cart::VERSION;

=head1 NAME

Bivio::PetShop::Model::Cart - shopping cart

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::Cart;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::PetShop::Model::Cart::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::Cart>

=cut

#=IMPORTS
use Bivio::Agent::HTTP::Cookie;
use Bivio::PetShop::Type::Price;
use Bivio::Type::Date;

#=VARIABLES
Bivio::Agent::HTTP::Cookie->register(__PACKAGE__);

=head1 METHODS

=cut

=for html <a name="get_total"></a>

=head2 get_total() : string

Returns the total amount of the cart purchase.

=cut

sub get_total {
    my($self) = @_;
    my($amount) = 0;
    $self->new_other('CartItemList')->load_all->map_rows(
	sub {
	    $amount = Bivio::PetShop::Type::Price->add(
		$amount,
		shift->get('total_cost'),
	    );
	    return;
	},
    );
    return $amount;
}

=for html <a name="handle_cookie_in"></a>

=head2 static handle_cookie_in(Bivio::Agent::HTTP::Cookie cookie, Bivio::Agent::Request req)

Always set a value in the cookie, so the cookie can be validated when
the cart_id needs to be stored later.

=cut

sub handle_cookie_in {
    my($proto, $cookie, $req) = @_;
    $cookie->put(value => 1);
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'cart_t',
	columns => {
	    cart_id => ['PrimaryId', 'PRIMARY_KEY'],
	    creation_date => ['Date', 'NOT_NULL'],
	},
    };
}

=for html <a name="load_from_cookie"></a>

=head2 load_from_cookie() : self

Checks for the 'cart_id' field. Creates a new cart if the cart doesn't
exist, or already has an order associated with it. Stores the cart_id
in the cookie.

Throws a MISSING_COOKIES exception if the browser does not have cookies
enabled.

=cut

sub load_from_cookie {
    my($self) = @_;
    my($req) = $self->get_request;

    # ensure that cookies are enabled in the browser
    Bivio::Agent::HTTP::Cookie->assert_is_ok($req);

    my($cookie) = $req->get('cookie');
    my($cart_id) = $cookie->unsafe_get('cart_id');

    # check if the cart exists
    if (defined($cart_id) && $self->unsafe_load({cart_id => $cart_id})) {

	# don't use the cart_id if an order is associated with it
	if ($self->new_other('Order')->unauth_load({
            cart_id => $cookie->get('cart_id'),
        })) {
	    $cart_id = undef;
	}
    }
    else {
	# cart doesn't exist
	$cart_id = undef;
    }

    # create a new one if necessary
    unless (defined($cart_id)) {
	$cart_id = $self->create({
	    creation_date => Bivio::Type::Date->now,
	})->get('cart_id');
    }

    $cookie->put(cart_id => $cart_id);
    return $self;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
