# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::ProductSelectList;
use strict;
use Bivio::Base 'Model.ProductList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SBL) = __PACKAGE__->use('Model.SelectBaseList');

sub internal_load {
    return shift->delegate_method($_SBL, @_);
}

sub internal_select_field_name {
    return 'Product.name';
}

1;
