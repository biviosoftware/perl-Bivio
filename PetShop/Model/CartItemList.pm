# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::CartItemList;
use strict;
$Bivio::PetShop::Model::CartItemList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::CartItemList::VERSION;

=head1 NAME

Bivio::PetShop::Model::CartItemList - items in a cart

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::CartItemList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::PetShop::Model::CartItemList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::CartItemList>

=cut

#=IMPORTS
use Bivio::PetShop::Type::Price;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_load_for_order"></a>

=head2 static execute_load_for_order(Bivio::Agent::Request req)

Loads the list for the order present on the request.

=cut

sub execute_load_for_order {
    my($proto, $req) = @_;
    $req->put(cart_id => $req->get('Model.Order')->get('cart_id'));
    $proto->new($req)->load_all;
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,

	# List of fields which uniquely identify each row in this list
	primary_key => [
	    # Causes join of Item, Inventory, and Product on item_id
	    [qw(Item.item_id Inventory.item_id CartItem.item_id)],
	],

	# Allow sorting by Item.attr1
	order_by => ['Item.attr1'],

	other => [
	    # Joins Item and Product on product_id
	    [qw(Item.product_id Product.product_id)],

	    'CartItem.quantity',
	    'CartItem.unit_price',
	    'Inventory.quantity',
	    'Product.name',

	    # Locally computed fields
	    {
		name => 'total_cost',
		type => 'Price',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'in_stock',
		type => 'StockStatus',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'item_name',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	],
    };
}

=for html <a name="internal_pre_load"></a>

=head2 internal_pre_load(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

Adds the current cart_id to the query.

=cut

sub internal_pre_load {
    my($self, $query, $support, $params) = @_;
    push(@$params, $self->get_request->get('cart_id'));
    return 'cart_item_t.cart_id=?';
}

=for html <a name="internal_post_load_row"></a>

=head2 internal_post_load_row(hash_ref row)

Computes the total cost for the row.

=cut

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{total_cost} = Bivio::PetShop::Type::Price->mul(
	    $row->{'CartItem.quantity'}, $row->{'CartItem.unit_price'});
    $row->{in_stock} = $row->{'Inventory.quantity'}
	    - $row->{'CartItem.quantity'} >= 0
		    ? Bivio::PetShop::Type::StockStatus->IN_STOCK
		    : Bivio::PetShop::Type::StockStatus->NOT_IN_STOCK;
    $row->{item_name} = Bivio::PetShop::Model::Item->format_name(
	    $row->{'Item.attr1'}, $row->{'Product.name'});
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
