# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::Order;
use strict;
use Bivio::Base 'Model.RealmOwnerBase';


sub create_realm {
    my($self, $order) = (shift, shift);
    return $self->create($order)->SUPER::create_realm(@_);
}

sub internal_initialize {
    return {
        version => 1,
        table_name => 'order_t',
        columns => {
            order_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            cart_id => ['Cart.cart_id', 'NOT_NULL'],
            bill_to_name => ['Line', 'NOT_NULL'],
            ship_to_name => ['Line', 'NOT_NULL'],
        },
        other => [
            [cart_id => 'Cart.cart_id'],
        ],
        auth_id => 'order_id',
    };
}

1;
