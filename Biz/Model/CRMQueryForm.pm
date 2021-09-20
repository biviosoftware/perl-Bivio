# Copyright (c) 2008-2021 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::CRMQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

b_use('ClassWrapper.TupleTag')->wrap_methods(
    __PACKAGE__, b_use('Model.CRMForm')->TUPLE_TAG_INFO);

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
    ];
}

1;
