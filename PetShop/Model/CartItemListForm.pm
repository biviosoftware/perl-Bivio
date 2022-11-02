# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::CartItemListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';

my($_P) = b_use('Type.Price');

sub execute_empty_row {
    # Sets the quantity in the form row for editing.
    my($self) = @_;
    $self->internal_put_field('CartItem.quantity' =>
        $self->get_list_model->get('CartItem.quantity'));
    return;
}

sub execute_ok_end {
    # Redirects to the checkout form if OK is pressed.
    my($self) = @_;

    # ensure the the cart grand total doesn't exceed the Price precision
    my($value, $err) = $_P->from_literal(
        $self->new_other('Cart')->load_from_cookie->get_total);

    if ($err) {
        # put the error on the first row
        $self->reset_cursor;
        $self->next_row;
        $self->internal_put_error('CartItem.quantity'
            => 'TOTAL_EXCEEDS_PRECISION');
        return;
    }

    if ($self->get('ok_button')) {
        # redirect to the checkout page
        return {
            task_id => 'CHECKOUT',
        };
    }
    return;
}

sub execute_ok_row {
    # Updates or deletes the current row depending on the button selected.
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

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
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
    });
}

1;
