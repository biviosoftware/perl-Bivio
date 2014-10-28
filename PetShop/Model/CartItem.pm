# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::CartItem;
use strict;
use Bivio::Base 'Biz.PropertyModel';


sub internal_initialize {
    return {
	version => 1,
	table_name => 'cart_item_t',
	columns => {
	    cart_id => ['Cart.cart_id', 'PRIMARY_KEY'],
	    cart_item_id => ['PrimaryId', 'PRIMARY_KEY'],
	    item_id => ['Item.item_id', 'NOT_NULL'],
	    quantity => ['Integer', 'NOT_NULL'],
	    unit_price => ['Price', 'NOT_NULL'],
	},
    };
}

1;
