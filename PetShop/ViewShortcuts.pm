# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::ViewShortcuts;
use strict;
use Bivio::Base 'UIXHTML.ViewShortcuts';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub vs_address_fields {
    my($proto, $form_name, $address_suffix) = @_;
    my($address) = $form_name . '.Address' . ($address_suffix || '');
    return (
	"$address.street1",
	[
	    $proto->vs_blank_cell,
	    FormField($address.'.street2')->put(cell_class => 'field'),
	],
	"$address.city",
	"$address.state",
	"$address.zip",
	"$address.country",
	$form_name . '.Phone' . ($address_suffix || '') . '.phone',
    );
}

sub vs_items_form {
    my($proto, $form_name) = @_;
    return vs_simple_form($form_name, [
	 $proto->vs_paged_list($form_name, [
	    'Item.item_id',
	    ['item_name', {
		column_order_by => ['Item.attr1', 'Product.name'],
		wf_list_link => {
		    query => 'THIS_CHILD_LIST',
		    task => 'ITEM_DETAIL',
		},
	    }],
	    'Item.list_price',
	    [ 'add_to_cart', {
		column_heading => '',
		class => 'submit',
	    }],
	], {
	    empty_list_widget => 'No items found.',
	}),
    ], 1);
}

1;
