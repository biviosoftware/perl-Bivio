# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::UI::ViewShortcuts;
use strict;
$Bivio::PetShop::UI::ViewShortcuts::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::UI::ViewShortcuts::VERSION;

=head1 NAME

Bivio::PetShop::UI::ViewShortcuts - view convenience methods

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::UI::ViewShortcuts;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::ViewShortcuts>

=cut

use Bivio::UI::HTML::ViewShortcuts;
@Bivio::PetShop::UI::ViewShortcuts::ISA = ('Bivio::UI::HTML::ViewShortcuts');

=head1 DESCRIPTION

C<Bivio::PetShop::UI::ViewShortcuts>

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Biz::QueryType;
use Bivio::PetShop::Type::Category;
use Bivio::UI::HTML::Widget::FormField;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="vs_address_fields"></a>

=head2 static vs_address_fields(string form_name, string address_suffix) : array

Returns the address fields.

=cut

sub vs_address_fields {
    my($proto, $form_name, $address_suffix) = @_;

    my($address) = $form_name.'.EntityAddress'.$address_suffix;

    # state/zip are shown on one line
    my($state_zip) = [
	$proto->vs_form_field($address.'.state'),
	$proto->vs_blank_cell(3),
	$proto->vs_form_field($address.'.zip'),
    ];
    $state_zip = [$state_zip->[0],
	$proto->vs_new('Grid', [
	    [(@$state_zip)[1..4]],
	]),
    ];

    return (
	[$proto->vs_form_field($address.'.addr1')],
	[$proto->vs_blank_cell,
	    $proto->vs_new('FormField', $address.'.addr2')],
	[$proto->vs_form_field($address.'.city')],
	$state_zip,
	[$proto->vs_form_field($address.'.country')],
	[$proto->vs_form_field(
	    $form_name.'.EntityPhone'.$address_suffix.'.phone')],
       );
}

=for html <a name="vs_items_form"></a>

=head2 static vs_items_form(string form_name) : Bivio::UI::Widget

Returns the items form with or without Search names.

=cut

sub vs_items_form {
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

=for html <a name="vs_paging_table"></a>

=head2 static vs_paging_table(Bivio::UI::Widget widget) : Bivio::UI::Widget

Returns a widget which includes paging links.  I<table_args> are passed
directly to Table widget.

=cut

sub vs_paging_table {
    my($proto, $model, $widget) = @_;
    return $proto->vs_new('Grid', [[
	_page_links($proto, $model),
    ], [
	$widget->put(cell_colspan => 2),
    ], [
	_page_links($proto, $model),
    ]]);
}

=for html <a name="vs_product_uri"></a>

=head2 static vs_product_uri(any category) : href

Creates a widget value which returns a URI which points to the I<PRODUCT> task
for I<category>.  See
L<Bivio::PetShop::Type::Category|Bivio::PetShop::Type::Category>.

=cut

sub vs_product_uri {
    my($proto, $category) = @_;
    return [
	# format_uri only works on the request
	['->get_request'],
	'->format_uri', Bivio::Agent::TaskId->PRODUCTS, {
	    # Product task is a list of all products in a category.
	    # The category is the list's parent_id.
	    'ListQuery.parent_id' =>
	    Bivio::PetShop::Type::Category->unsafe_from_any($category)
	    ->get_name(),
	}, undef, undef];
}

#=PRIVATE METHODS

# _page_link(proto, string model, string direction) : Bivio::UI::Widget
#
# Returns a paging link for the specified direction.
#
sub _page_link {
    my($proto, $model, $direction) = @_;
    $model = "Model.$model";
    my($type) = uc($direction).'_LIST';
    return $proto->vs_new('Link',
	$direction eq 'next' ? 'next page >>>' : '<<< previous page',
	[$model, '->format_uri', Bivio::Biz::QueryType->$type()], {
	    control => [[$model, '->get_query'], 'has_'.lc($direction)],
	});
}

# _page_links(proto, string model) : array
#
# Returns a next/prev links.
#
sub _page_links {
    my($proto, $model) = @_;
    return (
	_page_link($proto, $model, 'prev'),
	_page_link($proto, $model, 'next')->put(cell_align => 'E'),
    );
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
