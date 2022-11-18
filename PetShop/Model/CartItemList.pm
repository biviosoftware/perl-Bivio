# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::CartItemList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_P) = b_use('Type.Price');
my($_SS) = b_use('Type.StockStatus');

sub execute_load_for_order {
    # Loads the list for the order present on the request.
    my($proto, $req) = @_;
    # load the order's cart on the request
    # used in internal_prepare_statement()
    $req->req('Model.Order')->get_model('Cart');
    return shift->execute_load_all(@_);
}

sub internal_initialize {
    return {
        version => 1,

        # List of fields which uniquely identify each row in this list
        primary_key => [
            # Causes join of Item, Inventory, and Product on item_id
            [qw(Item.item_id Inventory.item_id CartItem.item_id)],
        ],

        # Allow sorting by Item.attr1
        order_by => ['Item.attr1'],

        other => [
            # Joins Item and Product on product_id
            [qw(Item.product_id Product.product_id)],

            'CartItem.quantity',
            'CartItem.unit_price',
            'Inventory.quantity',
            'Product.name',

            # Locally computed fields
            {
                name => 'total_cost',
                type => 'Price',
                constraint => 'NOT_NULL',
            },
            {
                name => 'in_stock',
                type => 'StockStatus',
                constraint => 'NOT_NULL',
            },
            {
                name => 'item_name',
                type => 'Line',
                constraint => 'NOT_NULL',
            },
        ],
    };
}

sub internal_post_load_row {
    # Computes the total cost for the row.
    my($self, $row) = @_;
    $row->{total_cost} = $_P->mul(
        $row->{'CartItem.quantity'}, $row->{'CartItem.unit_price'});
    $row->{in_stock} = $row->{'Inventory.quantity'}
        - $row->{'CartItem.quantity'} >= 0
            ? $_SS->IN_STOCK
            : $_SS->NOT_IN_STOCK;
    $row->{item_name} = b_use('Model.Item')->format_name(
        $row->{'Item.attr1'}, $row->{'Product.name'});
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    # use the cart_id on the request, otherwise from the cookie
    $stmt->where([
        'CartItem.cart_id',
        [$self->ureq(qw(Model.Cart cart_id))
             || $self->new_other('Cart')->load_from_cookie->get('cart_id')],
    ]);
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
