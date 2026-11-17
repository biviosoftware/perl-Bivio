# Copyright (c) 2008-2026 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::CRMQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

my($_NUM) = 'b_crm_thread_num';
b_use('ClassWrapper.TupleTag')->wrap_methods(
    __PACKAGE__, b_use('Model.CRMForm')->TUPLE_TAG_INFO);

sub execute_empty {
    my($self) = @_;
    shift->SUPER::execute_empty(@_);
    return
        unless defined($self->unsafe_get($_NUM));
    $self->internal_put_field(map(
        ($_ => undef),
        grep($_ ne $_NUM, map($_->[0], @{$self->internal_query_fields})),
        map($self->get_field_info($_, 'name'), $self->tuple_tag_field_check),
    ));
    return;
}

sub get_list_for_field {
    my($proto, $field) = @_;
    return $proto->new_other('CRMUserList')->load_all
        if $field eq 'b_owner';
    return shift->SUPER::get_list_for_field(@_);
}

sub internal_query_fields {
    return [
        [qw(b_status CRMThreadStatus)],
        [qw(b_owner PrimaryId)],
        [$_NUM, 'CRMThreadNum'],
    ];
}

1;
