# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AdmSuperUserList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_GENERAL_ID) = b_use('Auth.Realm')->get_general->get('id');
my($_ADMINISTRATOR) = b_use('Auth.Role')->ADMINISTRATOR;

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        primary_key => [qw(RealmUser.user_id)],
	want_select_distinct => 1,
	order_by => [
	    'RealmUser.user_id',
	],
	other => [
	    map(+{
		name => $_,
		in_select => 0,
	    }, qw(
		RealmUser.realm_id
		RealmUser.role
	    )),
	],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where([
	$stmt->IN('RealmUser.realm_id', _realms($self)),
	['RealmUser.role', [$_ADMINISTRATOR]],
    ]);
    return shift->SUPER::internal_prepare_statement(@_);
}

sub _realms {
    my($self) = @_;
    return [
	$_GENERAL_ID,
	map(
	    b_use('UI.Facade')->get_instance($_)->get('Constant')
	    ->get_value('site_admin_realm_id'),
	    @{b_use('UI.Facade')->get_all_classes},
	),
    ];
}

1;
