# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::CategoryList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub get_image_name {
    my($self) = @_;
    return lc($self->get('Category.name'));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => ['Category.category_id'],
	order_by => [
	    'Category.name',
	    'Category.description',
	],
    });
}

1;
