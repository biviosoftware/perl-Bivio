# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::ProductList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub internal_initialize {
    return {
	version => 1,
	can_iterate => 1,

	# List of fields which uniquely identify each row in this list
	primary_key => [
	    ['Product.product_id'],
	],

	# Allow sorting by name and product_id
	order_by => [
	    'Product.name',
	    'Product.product_id',
 	     # For example, to add a column, uncomment this line
	     # 'Product.description',
	],

	# Narrows query to just this category_id; selectable by ListQuery
	parent_id => ['Product.category_id'],
    };
}

1;
