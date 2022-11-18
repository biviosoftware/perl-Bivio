# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::DBAccessRowList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_DT) = b_use('Type.DateTime');
my($_DBAMF) = b_use('Model.DBAccessModelForm');

sub internal_initialize {
    my($self) = @_;
    b_use('IO.Config')->assert_test;  
    my($columns) = [];

    while (my($model_name, $fields) = each(%{$_DBAMF->get_all_fields()})) {
            foreach my $field (sort(keys(%$fields))) {
                my($e) = {
                    name => "$model_name.$field",
                    type => $_DBAMF->get_all_fields()->{$model_name}->{$field}->{type},
                    constraint => 'NONE',
                };
            $e->{type} = 'Line' if  $e->{type} eq 'Bivio::Type::PrimaryId';
                $e->{type} = 'Line' if $e->{type}->isa('Bivio::Type::EnumSet');
                $e->{type} = 'Line' if $e->{type} eq 'Bivio::Type::EmailVerifyKey';
            $e->{type} = 'Line' if $e->{type} eq 'Bivio::Type::DateTime';
                push(@$columns, $e);
            }
    }
    return $self->merge_initialize_info($self->SUPER::internal_initialize,
        {
            version => '1',
            primary_key => [
                {
                    name => 'index',
                    type => 'String',
                    constraint => 'NONE',
                },
                @$columns,
            ],
        });
    return;
}

sub internal_load_rows {
    my($self) = @_;
    return $_DBAMF->get_all_rows($self->req);
}

1;
