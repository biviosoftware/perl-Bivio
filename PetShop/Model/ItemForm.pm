# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::ItemForm;
use strict;
$Bivio::PetShop::Model::ItemForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::ItemForm::VERSION;

=head1 NAME

Bivio::PetShop::Model::ItemForm - add an item to the cart

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::ItemForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::PetShop::Model::ItemForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::ItemForm>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="add_item_to_cart"></a>

=head2 static add_item_to_cart(Bivio::PetShop::Model::Item item)

Adds the specified item to the current cart.

=cut

sub add_item_to_cart {
    my($proto, $item) = @_;
    my($req) = $item->get_request;

    # ensure that cookies are enabled in the browser
    Bivio::PetShop::Agent::Cookie->assert_is_ok($req);

    # if the item is already present, reset the quantity to 1
    my($cart_item) = Bivio::Biz::Model->new($req, 'CartItem');
    if ($cart_item->unsafe_load({
	item_id => $item->get('item_id'),
	cart_id => $req->get('cart_id'),
    })) {
	$cart_item->update({quantity => 1});
    }
    else {
	# create the new cart item
	$cart_item->create({
	    cart_id => $req->get('cart_id'),
	    item_id => $item->get('item_id'),
	    quantity => 1,
	    unit_price => $item->get('list_price'),
	});
    }
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Adds the currently selected item to the cart.

=cut

sub execute_ok {
    my($self) = @_;
    $self->add_item_to_cart($self->get_request->get('Model.Item'));
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 1,
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
