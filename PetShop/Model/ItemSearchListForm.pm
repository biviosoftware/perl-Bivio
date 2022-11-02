# Copyright (c) 2002-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::ItemSearchListForm;
use strict;
use Bivio::Base 'Model.ItemListForm';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        list_class => 'ItemSearchList',
    });
}

1;
