# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_list_for_field {
    my($proto, $field) = @_;
    return _owner_name_list($proto) if $field eq 'x_owner_name';
    return shift->SUPER::get_list_for_field(@_);
}

sub internal_query_fields {
    my($self) = @_;
    return [
	[qw(x_status CRMThreadStatus)],
	[qw(x_owner_name RealmName)],
    ];
}

sub _owner_name_list {
    my($proto) = @_;
    return Bivio::Biz::ListModel->new_anonymous({
        primary_key => [[qw(CRMThread.owner_user_id RealmOwner.realm_id)]],
	want_select_distinct => 1,
	other => [
	    {
		name => 'CRMThread.crm_thread_num',
		in_select => 0,
	    },
	],
        order_by => ['RealmOwner.name'],
	auth_id => ['CRMThread.realm_id'],
    })->load_all;
}

1;
