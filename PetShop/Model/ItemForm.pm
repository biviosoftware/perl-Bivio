# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::ItemForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub add_item_to_cart {
    # Adds the specified item to the current cart.
    my($proto, $item) = @_;
    my($cart_id) = $item->new_other('Cart')->load_from_cookie->get('cart_id');

    # if the item is already present, reset the quantity to 1
    my($cart_item) = $item->new_other('CartItem');

    if ($cart_item->unsafe_load({
	item_id => $item->get('item_id'),
	cart_id => $cart_id,
    })) {
	$cart_item->update({
	    quantity => 1,
	});
    }
    else {
	# create the new cart item
	$cart_item->create({
	    cart_id => $cart_id,
	    item_id => $item->get('item_id'),
	    quantity => 1,
	    unit_price => $item->get('list_price'),
	});
    }
    return;
}

sub execute_ok {
    # Adds the currently selected item to the cart.
    my($self) = @_;
    $self->add_item_to_cart($self->req('Model.Item'));
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
    });
}

1;
