# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::GroupUser;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub add_form {
    my($self) = @_;
    $self->internal_put_base_attr(tools => TaskMenu([
	'GROUP_USER_LIST',
    ]));
    return $self->internal_body(vs_simple_form(RealmUserAddForm => [
	'RealmUserAddForm.Email.email',
	'RealmUserAddForm.RealmOwner.display_name',
    ]));
}

sub create_forum {
    my($self) = @_;
    return $self->internal_body(vs_simple_form(ForumForm => [
        qw(
            ForumForm.RealmOwner.display_name
            ForumForm.RealmOwner.name
            ForumForm.Forum.want_reply_to
            ForumForm.admin_only_forum_email
            ForumForm.system_user_forum_email
            ForumForm.public_forum_email
            ForumForm.Forum.require_otp
        ),
    ]));
}

sub form {
    my($self) = @_;
    $self->internal_put_base_attr(tools => TaskMenu([
	'GROUP_USER_ADD_FORM',
	'GROUP_USER_LIST',
    ]));
    return $self->internal_body(vs_simple_form(GroupUserForm => [
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
    $self->internal_put_base_attr(selector =>
	vs_filter_query_form('GroupUserQueryForm', [
	    Select({
		choices => b_use('Model.GroupUserQueryForm'),
		field => 'b_privilege',
		unknown_label => 'Any Privilege',
		auto_submit => 1,
	    }),
	]),
    );
    vs_user_email_list(
	'GroupUserList',
	[
	    [privileges => {
		wf_list_link => {
		    query => 'THIS_DETAIL',
		    task => 'GROUP_USER_FORM',
		},
                control => ['is_not_withdrawn'],
	    }],
	    @{$extra_columns || []},
	],
	[TaskMenu([
	    'GROUP_USER_ADD_FORM',
	])],
    );
    return;
}

1;
