# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::CartItemListForm;
use strict;
$Bivio::PetShop::Model::CartItemListForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::CartItemListForm::VERSION;

=head1 NAME

Bivio::PetShop::Model::CartItemListForm - editable cart item list

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::CartItemListForm;

=cut

=head1 EXTENDS

L<Bivio::PetShop::ListFormModel>

=cut

use Bivio::Biz::ListFormModel;
@Bivio::PetShop::Model::CartItemListForm::ISA = ('Bivio::Biz::ListFormModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::CartItemListForm>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty_row"></a>

=head2 execute_empty_row()

Sets the quantity in the form row for editing.

=cut

sub execute_empty_row {
    my($self) = @_;
    $self->internal_put_field('CartItem.quantity' =>
	    $self->get_list_model->get('CartItem.quantity'));
    return;
}

=for html <a name="execute_ok_end"></a>

=head2 execute_ok_end()

Redirects to the checkout form if OK is pressed.

=cut

sub execute_ok_end {
    my($self) = @_;
    my($req) = $self->get_request;

    # ensure the the cart grand total doesn't exceed the Price precision
    my($cart) = Bivio::Biz::Model->new($req, 'Cart');
    if ($cart->unsafe_load(cart_id => $req->get('cart_id'))) {
	my($value, $err) = Bivio::PetShop::Type::Price->from_literal(
		$cart->get_total);
	if ($err) {
	    # put the error on the first row
	    $self->reset_cursor;
	    $self->next_row;
	    $self->internal_put_error('CartItem.quantity'
		    => 'TOTAL_EXCEEDS_PRECISION');
	    return;
	}
    }

    if ($self->get('ok_button')) {
	# redirect to the checkout page
	$req->client_redirect(Bivio::Agent::TaskId->CHECKOUT);
    }
    return;
}

=for html <a name="execute_ok_row"></a>

=head2 execute_ok_row()

Updates or deletes the current row depending on the button selected.

=cut

sub execute_ok_row {
    my($self) = @_;
    my($cart_item) = $self->get_list_model->get_model('CartItem');

    if ($self->get('CartItem.quantity') <= 0 || $self->get('remove')) {
	$cart_item->delete;
    }
    else {
	$cart_item->update({
	    quantity => $self->get('CartItem.quantity'),
	});
    }
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
	list_class => 'CartItemList',
	visible => [
	    {
		name => 'CartItem.quantity',
		in_list => 1,
	    },
	    {
		name => 'remove',
		type => 'OKButton',
		constraint => 'NONE',
		in_list => 1,
	    },
	    {
		name => 'update_cart',
		type => 'OKButton',
		constraint => 'NONE',
	    },
	],
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
