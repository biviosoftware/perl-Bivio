# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::Cart;
use strict;
use Bivio::Base 'Biz.PropertyModel';

b_use('AgentHTTP.Cookie')->register(__PACKAGE__);
my($_P) = b_use('Type.Price');
my($_D) = b_use('Type.Date');

sub get_total {
    # Returns the total amount of the cart purchase.
    my($self) = @_;
    my($amount) = 0;
    $self->new_other('CartItemList')->load_all->do_rows(
        sub {
            my($list) = @_;
            $amount = $_P->add($amount,        $list->get('total_cost'));
            return 1;
        },
    );
    return $amount;
}

sub handle_cookie_in {
    # Always set a value in the cookie, so the cookie can be validated when
    # the cart_id needs to be stored later.
    my($proto, $cookie, $req) = @_;
    $cookie->put(value => 1);
    return;
}

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

sub load_from_cookie {
    # Checks for the 'cart_id' field. Creates a new cart if the cart doesn't
    # exist, or already has an order associated with it. Stores the cart_id
    # in the cookie.
    #
    # Throws a MISSING_COOKIES exception if the browser does not have cookies
    # enabled.
    my($self) = @_;

    # ensure that cookies are enabled in the browser
    b_use('AgentHTTP.Cookie')->assert_is_ok($self->req);

    my($cookie) = $self->req('cookie');
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
            creation_date => $_D->now,
        })->get('cart_id');
    }

    $cookie->put(cart_id => $cart_id);
    return $self;
}

1;
