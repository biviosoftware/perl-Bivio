# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::Category;
use strict;
use Bivio::Base 'Biz.PropertyModel';


sub internal_initialize {
    return {
        version => 1,
        table_name => 'category_t',
        columns => {
            category_id => ['Name', 'PRIMARY_KEY'],
            name => ['Line', 'NONE'],
            description => ['Text', 'NONE'],
        },
    };
}

1;
