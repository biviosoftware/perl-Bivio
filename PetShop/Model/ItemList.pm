# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::ItemList;
use strict;
$Bivio::PetShop::Model::ItemList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::ItemList::VERSION;

=head1 NAME

Bivio::PetShop::Model::ItemList - list of items by product

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::ItemList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::PetShop::Model::ItemList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::ItemList>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	primary_key => [
	    ['Item.item_id'],
	],
	other => [
            'Product.name',
            'Item.attr1',
            'Item.list_price',
	    {
		name => 'item_name',
		type => 'Line',
		constraint => 'NONE',
	    },
	    [qw(Item.product_id Product.product_id)],
	],
	order_by => ['Item.item_id'],
	parent_id => ['Item.product_id'],
    };
}

=for html <a name="internal_post_load_row"></a>

=head2 internal_post_load_row(hash_ref row)

Sets the item_name using Item.attr1 and Product.name.

=cut

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{'item_name'} = Bivio::PetShop::Model::Item->format_name(
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
