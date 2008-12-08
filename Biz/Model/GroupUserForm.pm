# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::GroupUserForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FM) = b_use('Type.FormMode');
my($_AUX) = [qw(file_writer mail_recipient)];
my($_R) = b_use('Auth.Role');
my($_F) = b_use('UI.Facade');

sub USER_LIST_CLASS {
    return 'GroupUserList';
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
    my($ru) = $self->new_other('RealmUser');
    my($ul) = $self->req('Model.' . $self->USER_LIST_CLASS);
    my($uid) = $ul->get('RealmUser.user_id');
    my($rid) = $self->req('auth_id');
    my($main_old) = $ul->roles_by_category;
    my($main) = $self->get('RealmUser.role');
    unless ($main_old eq $main) {
# This only deletes this realm
	$ru->delete_all({user_id => $uid});
	return
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
    foreach my $f (@$_AUX) {
	my($method) = $self->unsafe_get($f) ? 'unauth_create_or_update'
	    : 'delete';
	$ru->$method({
	    realm_id => $rid,
	    user_id => $uid,
	    role => $main->from_any($f),
	});
    }
    $self->req->with_user($uid, sub {
        b_use('ShellUtil.RealmUser')->new->audit_user;
    });
    return;
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
	    $self->field_decl(
		[@{$_AUX}],
		'Boolean',
	    ),
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $_FM->setup_by_list_this(
	$self->new_other($self->USER_LIST_CLASS), 'RealmOwner');
    $self->new_other('RoleSelectList')
	->load_from_array($self->internal_select_roles);
    return shift->SUPER::internal_pre_execute(@_);
}

sub internal_select_roles {
    my($self) = @_;
    return $_F->get_from_source($self)->auth_realm_is_site($self->req)
	? [qw(USER MEMBER ADMINISTRATOR)]
	: [qw(UNKNOWN GUEST MEMBER ADMINISTRATOR)];
}

1;
