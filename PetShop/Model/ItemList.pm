# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::ItemList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub internal_initialize {
    return {
        version => 1,
        primary_key => [
            ['Item.item_id'],
        ],
        other => [
            'Product.name',
            {
                name => 'item_name',
                type => 'Line',
                constraint => 'NONE',
            },
            [qw(Item.product_id Product.product_id)],
        ],
        order_by => [
            'Item.attr1',
            'Product.name',
            'Item.item_id',
            'Item.list_price',
        ],
        parent_id => ['Item.product_id'],
    };
}

sub internal_post_load_row {
    # Sets the item_name using Item.attr1 and Product.name.
    my($self, $row) = @_;
    $row->{'item_name'} = b_use('Model.Item')->format_name(
        $row->{'Item.attr1'}, $row->{'Product.name'});
    return 1;
}

1;
