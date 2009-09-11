# Copyright (c) 2008-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::GroupUserForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FM) = b_use('Type.FormMode');
my($_AUX) = [qw(file_writer mail_recipient)];
my($_R) = b_use('Auth.Role');
my($_F) = b_use('UI.Facade');
my($_UNAPPROVED) = $_R->UNAPPROVED_APPLICANT;

sub UNAPPROVED_ROLE {
    return $_UNAPPROVED;
}

sub USER_LIST_CLASS {
    return 'GroupUserList';
}

sub change_main_role {
    my($self, $user_id, $role) = @_;
    # CANNOT use RealmUserAddForm (or subclasses) to avoid looping
    my($ru) = $self->new_other('RealmUser');
    $ru->delete_all({user_id => $user_id});
    $ru->create({
	realm_id => $self->req('auth_id'),
	user_id => $user_id,
	role => $role,
    }) unless $role->eq_unknown;
    _audit_user($self, $user_id);
    return;
}

sub create_unapproved_applicant {
    my($self, $user_id) = @_;
    return $self->change_main_role($user_id, $self->UNAPPROVED_ROLE);
}

sub delete_all_roles {
    my($self, $user_id) = @_;
    return $self->change_main_role($user_id, $_R->UNKNOWN);
}

sub execute_empty {
    my($self) = @_;
#TODO: Create version for site-user forum
    my($main, $aux) = $self->req('Model.' . $self->USER_LIST_CLASS)
	->roles_by_category;
    $self->internal_put_field('RealmUser.role' => $main->[0]);
    foreach my $f (@$_AUX) {
	$self->internal_put_field($f =>
	    grep($_->equals_by_name($f), @$aux) ? 1 : 0);
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    my($ul) = $self->req('Model.' . $self->USER_LIST_CLASS);
    my($uid) = $self->get('RealmUser.user_id');
    my($rid) = $self->req('auth_id');
    my($main_old) = $ul->roles_by_category;
    my($main) = $self->get('RealmUser.role');
    my($ru) = $self->new_other('RealmUser');
    unless ($main_old eq $main) {
# This only deletes this realm
	$ru->delete_all({user_id => $uid});
	return _audit_user($self, $uid)
	    if $main->eq_unknown;
# depending on the realm we'd deefinitely need to delete ForumUserDeleteForm
	$ru->create({
	    realm_id => $rid,
	    user_id => $uid,
	    role => $main,
	});
# 	$ru->create({
# 	    realm_id => $rid,
# 	    user_id => $uid,
# 	    role => $main->MEMBER,
# 	}) if $main->eq_administrator || $main->eq_accountant;
    }
#TODO: Deal with the site level (invalidate password?)
#      Maybe not delete password
#TODO: ForumUserForm would delete children (need to generalize with realm_dag)
#      Need to generalize concept of parents so that we know a realm has
#      children and a parent.
#TODO: when transitioning from unapproved to other state, send email
#      except unknown.  Have code in place to transition, but the views
#      can be empty.
#TODO: shouldn't this be using self->internal_aux_fields instead of accessing
#      $_AUX directly?
    foreach my $f (@$_AUX) {
	my($method) = $self->unsafe_get($f) ? 'unauth_create_or_update'
	    : 'delete';
	$ru->$method({
	    realm_id => $rid,
	    user_id => $uid,
	    role => $main->from_any($f),
	});
    }
    _audit_user($self, $uid);
    return;
}

sub internal_aux_fields {
    return [@$_AUX];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
	visible => [
	    {
		name => 'RealmUser.role',
		constraint => 'NOT_NULL',
	    },
#TODO: shouldn't this be using self->internal_aux_fields instead of accessing
#      $_AUX directly?
	    $self->field_decl(
		[@{$_AUX}],
		'Boolean',
	    ),
	],
	other => [
	    'RealmUser.user_id',
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($lm) = $self->new_other($self->USER_LIST_CLASS);
    $_FM->setup_by_list_this($lm, 'RealmOwner');
    $self->internal_put_field(
	'RealmUser.user_id' => $lm->get('RealmUser.user_id'));
    # SECURITY: Limit privilege escalation to the level auth_user has
    my($roles) = $self->internal_select_roles;
    my($auth_role) = $self->req('auth_role');
    pop(@$roles)
	until !@$roles || $auth_role->equals_by_name($roles->[$#$roles]);
    $self->new_other('RoleSelectList')
	->load_from_array($roles);
    return shift->SUPER::internal_pre_execute(@_);
}

sub internal_select_roles {
    my($self) = @_;
    # From least to most privileged order
    return $_F->get_from_source($self)->auth_realm_is_site_admin($self->req)
	? [qw(WITHDRAWN USER MEMBER ADMINISTRATOR)]
	: [qw(UNKNOWN GUEST MEMBER ADMINISTRATOR)];
}

sub validate {
    my($self) = @_;
    return
	if $self->in_error;
    return $self->internal_put_error('RealmUser.role' => 'NOT_FOUND')
	unless $self->req('Model.RoleSelectList')
	->find_row_by('RealmUser.role' => $self->get('RealmUser.role'));
    return shift->SUPER::validate(@_);
}

sub _audit_user {
    my($self, $uid) = @_;
    $self->req->with_user($uid, sub {
        b_use('ShellUtil.RealmUser')->new->audit_user;
    });
    return;
}

1;
