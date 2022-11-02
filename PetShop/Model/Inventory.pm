# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::Inventory;
use strict;
use Bivio::Base 'Biz.PropertyModel';


sub internal_initialize {
    return {
        version => 1,
        table_name => 'inventory_t',
        columns => {
            item_id => ['Item.item_id', 'PRIMARY_KEY'],
            quantity => ['Integer', 'NOT_NULL'],
        },
    };
}

1;
