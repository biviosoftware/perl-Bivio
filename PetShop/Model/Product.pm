# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::Product;
use strict;
use Bivio::Base 'Biz.PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_image_url {
    my($self) = @_;
    return $self->req->format_uri({
	task_id => 'FORUM_FILE',
	realm => $self->req('UI.Facade')->SITE_REALM_NAME,
	path_info => join(
	    '',
	    'images/',
	    $self->get('image_name'),
	    '.gif',
	),
    });
}

sub internal_initialize {
    return {
	version => 1,
	table_name => 'product_t',
	columns => {
	    product_id => ['Name', 'PRIMARY_KEY'],
	    category_id => ['Category.category_id', 'NOT_NULL'],
	    name => ['Line', 'NOT_NULL'],
	    image_name => ['Name', 'NONE'],
	    description => ['Text', 'NOT_NULL'],
	},
    };
}

1;
