# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::ViewShortcuts;
use strict;
use Bivio::Base 'Bivio::UI::XHTML::ViewShortcuts';
use Bivio::Agent::TaskId;
use Bivio::Biz::QueryType;
use Bivio::PetShop::Type::Category;
use Bivio::UI::HTML::Widget::FormField;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub vs_address_fields {
    # (proto, string) : array
    # (proto, string, string) : array
    # Returns the address fields.
    my($proto, $form_name, $address_suffix) = @_;
    my($address) = $form_name . '.Address' . ($address_suffix || '');

    # state/zip are shown on one line
    my($state_zip) = [
	$proto->vs_form_field($address . '.state'),
	$proto->vs_blank_cell(3),
	$proto->vs_form_field($address . '.zip'),
    ];
    $state_zip = [$state_zip->[0],
	$proto->vs_new('Grid', [
	    [(@$state_zip)[1..4]],
	]),
    ];
    return (
	[$proto->vs_form_field($address . '.street1')],
	[$proto->vs_blank_cell,
	    $proto->vs_new('FormField', $address.'.street2')],
	[$proto->vs_form_field($address . '.city')],
	$state_zip,
	[$proto->vs_form_field($address . '.country')],
	[$proto->vs_form_field(
	    $form_name . '.Phone' . ($address_suffix || '') . '.phone')],
       );
}

sub vs_items_form {
    # (proto, string) : UI.Widget
    # Returns the items form with or without Search names.
    my($proto, $form_name) = @_;
    return $proto->vs_new('Form', $form_name,
	 $proto->vs_new('Table', $form_name, [
	    'Item.item_id',
	    ['item_name', {
		column_order_by => ['Item.attr1', 'Product.name'],
		wf_list_link => {
		    query => 'THIS_CHILD_LIST',
		    task => 'ITEM_DETAIL',
		},
	    }],
	    'Item.list_price',
	    ['add_to_cart', {
		column_widget => $proto->vs_new('ImageFormButton', {
		    image => 'add_to_cart',
		    field => 'add_to_cart',
		    alt => 'Add Item to Your Shopping Cart',
		}),
	    }],
	], {
	    cellpadding => 2,
	    cellspacing => 2,
	    # string_font is inherited by widgets in this hierarchy
	    string_font => 'page_text',
	    empty_list_widget => $proto->vs_new('String', 'No items found.'),
	}),
    );
}

sub vs_paging_table {
    # (proto, UI.Widget) : UI.Widget
    # Returns a widget which includes paging links.  I<table_args> are passed
    # directly to Table widget.
    my($proto, $model, $widget) = @_;
    return $proto->vs_new('Grid', [[
	_page_links($proto, $model),
    ], [
	$widget->put(cell_colspan => 2),
    ], [
	_page_links($proto, $model),
    ]]);
}

sub vs_product_uri {
    # (proto, any) : href
    # Creates a widget value which returns a URI which points to the I<PRODUCT> task
    # for I<category>.  See
    # L<Bivio::PetShop::Type::Category|Bivio::PetShop::Type::Category>.
    my($proto, $category) = @_;
    return [
	# format_uri only works on the request
	['->get_request'],
	'->format_uri', Bivio::Agent::TaskId->PRODUCTS, {
	    # Product task is a list of all products in a category.
	    # The category is the list's parent_id.
	    'ListQuery.parent_id' =>
	    Bivio::PetShop::Type::Category->from_any($category)->get_name(),
	}, undef, undef];
}

sub _page_link {
    # (proto, string, string) : UI.Widget
    # Returns a paging link for the specified direction.
    my($proto, $model, $direction) = @_;
    $model = "Model.$model";
    my($type) = uc($direction).'_LIST';
    return $proto->vs_new('Link',
	$direction eq 'next' ? 'next page >>>' : '<<< previous page',
	[$model, '->format_uri', Bivio::Biz::QueryType->$type()], {
	    control => [[$model, '->get_query'], 'has_'.lc($direction)],
	});
}

sub _page_links {
    # (proto, string) : array
    # Returns a next/prev links.
    my($proto, $model) = @_;
    return (
	_page_link($proto, $model, 'prev'),
	_page_link($proto, $model, 'next')->put(cell_align => 'E'),
    );
}

1;
