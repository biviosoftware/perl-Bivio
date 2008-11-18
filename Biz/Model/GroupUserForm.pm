# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::GroupUserForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FM) = b_use('Type.FormMode');
my($_AUX) = [qw(file_writer mail_recipient)];
my($_R) = b_use('Auth.Role');

sub SELECT_ROLES {
    return [map($_R->$_(), qw(UNKNOWN GUEST MEMBER ADMINISTRATOR))];
}

sub execute_empty {
    my($self) = @_;
#TODO: Create version for site-user forum
    my($main, $aux) = $self->req('Model.GroupUserList')->roles_by_category;
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
    my($gul) = $self->req('Model.GroupUserList');
    my($uid) = $gul->get('RealmUser.user_id');
    my($rid) = $self->req('auth_id');
    my($main_old) = $gul->roles_by_category;
    my($main) = $self->get('RealmUser.role');
    unless ($main_old eq $main) {
	$ru->delete_all({user_id => $uid});
	return
	    if $main->eq_unknown;
	$ru->create({
	    realm_id => $rid,
	    user_id => $uid,
	    role => $main,
	});
	$ru->create({
	    realm_id => $rid,
	    user_id => $uid,
	    role => $main->MEMBER,
	}) if $main->eq_administrator || $main->eq_accountant;
    }
#TODO: Deal with the site level (invalidate password?)
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
    $_FM->setup_by_list_this($self->new_other('GroupUserList'), 'RealmOwner');
    $self->new_other('RoleSelectList')->load_from_array($self->SELECT_ROLES);
    return shift->SUPER::internal_pre_execute(@_);
}

1;
