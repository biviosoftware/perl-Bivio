# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::DBAccessModelList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_DBAMF) = b_use('Model.DBAccessModelForm');

sub internal_initialize {
    my($self) = @_;
    b_use('IO.Config')->assert_test;
    return $self->merge_initialize_info(
        $self->SUPER::internal_initialize,
        {
            version => '1',
            primary_key => [
                $self->field_decl([[qw(name String)]]),
            ],
        });
}

sub internal_load_rows {
    return [map(({name => $_}), @{$_DBAMF->get_property_model_names})];
}

1;
