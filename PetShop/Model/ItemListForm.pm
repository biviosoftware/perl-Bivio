# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::ItemListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';


sub execute_ok_row {
    # Adds the current row to the cart if the add_to_cart button was selected.
    my($self) = @_;

    if ($self->get('add_to_cart')) {
        b_use('Model.ItemForm')->add_item_to_cart(
            $self->get_list_model->get_model('Item'),
        );
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'ItemList',
        visible => [
            {
                name => 'add_to_cart',
                constraint => 'NONE',
                type => 'OKButton',
                in_list => 1,
            },
        ],
    });
}

1;
