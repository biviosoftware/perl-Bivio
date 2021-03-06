# Copyright (c) 2008-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

b_use('ClassWrapper.TupleTag')->wrap_methods(
    __PACKAGE__, b_use('Model.CRMForm')->TUPLE_TAG_INFO);

sub get_list_for_field {
    my($proto, $field) = @_;
    return _owner_name_list($proto)
	if $field eq 'b_owner_name';
    return shift->SUPER::get_list_for_field(@_);
}

sub internal_query_fields {
    return [
	[qw(b_status CRMThreadStatus)],
	[qw(b_owner_name Line)],
    ];
}

sub _owner_name_list {
    my($proto) = @_;
    return $proto->new_other('CRMActionList')->load_owner_names;
}

1;
