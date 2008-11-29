# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::GroupUser;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub form {
    my($self) = @_;
    return shift->internal_body(vs_simple_form(GroupUserForm => [
	['GroupUserForm.RealmUser.role', {
	    choices => ['->req', 'Model.RoleSelectList'],
	    list_display_field => 'display',
	    list_id_field => 'RealmUser.role',
	}],
	'GroupUserForm.file_writer',
	'GroupUserForm.mail_recipient',
    ]));
}

sub list {
    my($self, $extra_columns) = @_;
    vs_user_email_list(
	'GroupUserList',
	[
	    [privileges => {
		wf_list_link => {
		    query => 'THIS_DETAIL',
		    task => 'GROUP_USER_FORM',
		},
	    }],
	    @{$extra_columns || []},
	],
    );
    return;
}

1;
