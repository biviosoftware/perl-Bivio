# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::CartItem;
use strict;
$Bivio::PetShop::Model::CartItem::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::CartItem::VERSION;

=head1 NAME

Bivio::PetShop::Model::CartItem - order line item

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::CartItem;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::PetShop::Model::CartItem::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::CartItem>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'cart_item_t',
	columns => {
	    cart_id => ['Cart.cart_id', 'PRIMARY_KEY'],
	    cart_item_id => ['PrimaryId', 'PRIMARY_KEY'],
	    item_id => ['Item.item_id', 'NOT_NULL'],
	    quantity => ['Integer', 'NOT_NULL'],
	    unit_price => ['Price', 'NOT_NULL'],
	},
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
