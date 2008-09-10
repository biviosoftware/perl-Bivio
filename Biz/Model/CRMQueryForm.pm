# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TSN) = __PACKAGE__->use('Type.TupleSlotNum');
my($_SLOT_FIELDS) = $_TSN->map_list(sub {
    return 'x_' . shift(@_);
});

sub get_list_for_field {
    my($proto, $field) = @_;
    return _owner_name_list($proto) if $field eq 'x_owner_name';
    return _tuple_value_list($proto, $field)
	if grep($field eq $_, @$_SLOT_FIELDS);
    return shift->SUPER::get_list_for_field(@_);
}

sub internal_query_fields {
    my($self) = @_;
    return [
	[qw(x_status CRMThreadStatus)],
	[qw(x_owner_name PrimaryId)],
	map([$_ => 'String'], @$_SLOT_FIELDS),
    ];
}

sub _owner_name_list {
    my($proto) = @_;
    return $proto->new_other('CRMActionList')->load_owner_names;
}

sub _tuple_value_list {
    my($proto, $field) = @_;
    $field =~ s/^x_//;
    my($slot) = 'TupleTag.' . $field;
    return Bivio::Biz::ListModel->new_anonymous({
        primary_key => [$slot],
	want_select_distinct => 1,
	other => [
	    [qw(CRMThread.thread_root_id TupleTag.primary_id)],
	    map(+{
		name => $_,
		in_select => 0,
	    }, qw(CRMThread.crm_thread_num TupleTag.tuple_def_id
                CRMThread.thread_root_id)),
	],
        order_by => [$slot],
	auth_id => ['CRMThread.realm_id'],
    })->load_all;
}

1;
