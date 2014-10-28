# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::Item;
use strict;
use Bivio::Base 'Bivio::Biz::PropertyModel';

my($_IS) = b_use('Type.ItemStatus');

sub create {
    my($self, $values) = @_;
    $values->{status} ||= $_IS->OK;
    return shift->SUPER::create(@_);
}

sub format_name {
    my($self, $attr1, $product_name) = @_;
    return join(' ', $attr1, $product_name) if defined($attr1);
    b_die('expected item instance')
	unless ref($self);
    # call method again with arguments from instance
    return $self->format_name(
	$self->get('attr1'),
	$self->get_model('Product')->get('name'),
    );
}

sub internal_initialize {
    return {
	version => 1,
	table_name => 'item_t',
	columns => {
	    item_id => ['Name', 'PRIMARY_KEY'],
	    product_id => ['Product.product_id', 'NOT_NULL'],
	    list_price => ['Price', 'NONE'],
	    unit_cost => ['Price', 'NONE'],
	    status => ['ItemStatus', 'NONE'],
	    attr1 => ['Line', 'NOT_NULL'],
	    attr2 => ['Line', 'NONE'],
	    attr3 => ['Line', 'NONE'],
	    attr4 => ['Line', 'NONE'],
	    attr5 => ['Line', 'NONE'],
	},
	other => [['product_id', 'Product.product_id']],
    };
}

1;
