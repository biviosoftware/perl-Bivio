# Copyright (c) 2008-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::GroupAdmin;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = b_use('Type.Array');

sub forum_form {
    my($self, $model) = @_;
    $model ||= 'ForumForm';
    return shift->internal_feature_form($model => [
	"$model.RealmOwner.display_name",
	"$model.RealmOwner.name",
    ]);
}

sub user_add_form {
    my($self) = @_;
    $self->internal_put_base_attr(tools => TaskMenu([
	'GROUP_USER_LIST',
    ]));
    return $self->internal_body(vs_simple_form(RealmUserAddForm => [
	'RealmUserAddForm.Email.email',
	'RealmUserAddForm.RealmOwner.display_name',
    ]));
}

sub feature_form {
    return shift->internal_feature_form(RealmFeatureForm => []);
}

sub internal_feature_form {
    my($self, $model, $extra_cols) = @_;
    return $self->internal_body([sub {
        my($req) = shift->req;
	my($m) = $req->get("Model.$model");
        return vs_simple_form($model => [
	    @$extra_cols,
	    @{$_A->map_sort_map(
		sub {vs_text($req, shift->[0])},
		sub {lc(shift) cmp lc(shift)},
		$m->map_feature_type(sub {
		    my($field, $type) = @_;
		    $m->get_field_type($_)->isa('Bivio::Type::Enum')
			? ["$model.$field" => {
			    wf_want_select => 1,
			    enum_sort => 'as_int',
			    vs_descriptive_field_no_label => 1,
			}] : ["$model.$field"],
		}),
	    )},
	]),
    }]);
}

sub user_form {
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

sub user_list {
    my($self, $extra_columns, $other_tools, $list) = @_;
    $list ||= 'GroupUserList'; 
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
	$list,
	[
	    @{$extra_columns || []},
	    [privileges => {
		wf_list_link => {
		    query => 'THIS_DETAIL',
		    task => 'GROUP_USER_FORM',
		    control => [qw(->can_change_privileges GROUP_USER_FORM)],
		},
	    }],
	],
	$other_tools || [TaskMenu(['GROUP_USER_ADD_FORM'])],
    );
    return;
}

1;
