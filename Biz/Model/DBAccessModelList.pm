# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::DBAccessModelList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_DBAMF) = b_use('Model.DBAccessModelForm');

sub internal_initialize {
    my($self) = @_;
    b_use('IO.Config')->assert_test;  
    return $self->merge_initialize_info($self->SUPER::internal_initialize,
        {
	    version => '1',
	    primary_key => [
                {
                    name => 'name',
                    type => 'String',
                    constraint => 'NONE',
                },
	    ],
        });
    return;
}

sub internal_load_rows {
    my($self) = @_;
    my(@result) = map(({name => $_}),  $_DBAMF->get_property_model_names);
    return \@result;
}

1;
