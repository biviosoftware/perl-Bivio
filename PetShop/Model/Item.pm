# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::Item;
use strict;
$Bivio::PetShop::Model::Item::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::Item::VERSION;

=head1 NAME

Bivio::PetShop::Model::Item - item for sale

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::Item;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::PetShop::Model::Item::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::Item>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="format_name"></a>

=head2 format_name() : string

=head2 static format_name(string attr1, string product_name) : string

Returns the "attr1 Product.name" combination.

=cut

sub format_name {
    my($self, $attr1, $product_name) = @_;
    return $attr1.' '.$product_name if defined($attr1);

    Bivio::Die->die("expected item instance") unless ref($self);

    # call method again with arguments from instance
    return $self->format_name($self->get('attr1'),
	    $self->get_model('Product')->get('name'));
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'item_t',
	columns => {
	    item_id => ['Name', 'PRIMARY_KEY'],
	    product_id => ['Product.product_id', 'NOT_NULL'],
	    list_price => ['Price', 'NONE'],
	    unit_cost => ['Price', 'NONE'],
	    supplier_id => ['Supplier.supplier_id', 'NONE'],
	    status => ['ItemStatus', 'NONE'],
	    attr1 => ['Line', 'NOT_NULL'],
	    attr2 => ['Line', 'NONE'],
	    attr3 => ['Line', 'NONE'],
	    attr4 => ['Line', 'NONE'],
	    attr5 => ['Line', 'NONE'],
	},
#TODO: this should be automatic, driven by the related field above
	other => [['product_id', 'Product.product_id']],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
