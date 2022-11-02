# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::GroupUserForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_FM) = b_use('Type.FormMode');
my($_AUX) = [qw(is_subscribed file_writer)];
my($_R) = b_use('Auth.Role');
my($_F) = b_use('UI.Facade');
my($_UNAPPROVED) = $_R->UNAPPROVED_APPLICANT;
my($_EVERYBODY) = b_use('Auth.Role')->get_category_role_group('everybody');

sub UNAPPROVED_ROLE {
    return $_UNAPPROVED;
}

sub USER_LIST_CLASS {
    return 'GroupUserList';
}

sub can_add_user {
    my($self) = @_;
    return $self->new_other('GroupUserList')->can_add_user;
}

sub change_main_role {
    my($self, $user_id, $role) = @_;
    my($ru) = $self->new_other('RealmUser');
    $ru->delete_all({
        user_id => $user_id,
        role => $_EVERYBODY,
    });
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
    foreach my $f (@{$self->internal_aux_fields}) {
        $self->internal_put_field(
            $f => $f eq 'is_subscribed'
                ? _do_subscribed(
                    $self, 'unsafe_load', $self->get('RealmUser.user_id'), 1)
                : grep($_->equals_by_name($f), @$aux) ? 1 : 0,
        );
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    my($old_main);
    if (my $ul = $self->ureq('Model.' . $self->USER_LIST_CLASS)) {
        $old_main = $ul->roles_by_category->[0];
    }
    else {
        $old_main = $self->get('current_main_role');
    }
    my($uid) = $self->get('RealmUser.user_id');
    my($main) = $self->get('RealmUser.role');
    my($ru) = $self->new_other('RealmUser');

    if ($main) {
        unless (($old_main || '') eq $main) {
            $ru->delete_all({user_id => $uid});
            return _audit_user($self, $uid)
                if $main->eq_unknown;
            $ru->create({
                user_id => $uid,
                role => $main,
            });
        }
#TODO: Deal with the site level (invalidate password?)
#      Maybe not delete password
#TODO: ForumUserForm would delete children (need to generalize with realm_dag)
#      Need to generalize concept of parents so that we know a realm has
#      children and a parent.
#TODO: when transitioning from unapproved to other state, send email
#      except unknown.  Have code in place to transition, but the views
#      can be empty.
        map(
            _put_if_in_group($self, $main, @$_),
            [qw(file_writer all_admins)],
            [qw(mail_recipient all_members)],
        );
    }
    foreach my $f (@{$self->internal_aux_fields}, 'mail_recipient') {
        if ($f eq 'is_subscribed') {
            _do_subscribed(
                $self, 'create_or_update', $uid, $self->unsafe_get($f));
        }
        else {
            my($method) = $self->unsafe_get($f) ? 'create_or_update' : 'delete';
            $ru->$method({
                user_id => $uid,
                role => $_R->from_any($f),
            });
        }
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
            $self->field_decl(
                $self->internal_aux_fields,
                'Boolean',
            ),
        ],
        other => [
            'RealmUser.user_id',
            $self->field_decl([[qw(current_main_role Auth.Role)]]),
            $self->field_decl([[qw(mail_recipient Boolean NOT_NULL)]]),
        ],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    unless ($self->unsafe_get('RealmUser.user_id')) {
        my($lm) = $self->new_other($self->USER_LIST_CLASS);
        $_FM->setup_by_list_this($lm, 'RealmOwner');
        $self->internal_put_field(
            'RealmUser.user_id' => $lm->get('RealmUser.user_id'));
    }
    # SECURITY: Limit privilege escalation to the level auth_user has
    my($auth_roles) = $self->req('auth_roles');
    my($not_allowed) = [grep({
        my($g) = $_;
        !grep($_->in_category_role_group($g), @$auth_roles);
    } qw(all_members all_admins everybody))];
    $self->new_other('RoleSelectList')->load_from_array(
        [grep({
            my($r) = $_;
            !$r->eq_unknown
            && !grep($r->in_category_role_group($_), @$not_allowed);
        } map($_R->from_any($_), @{$self->internal_select_roles}))],
    );
    return shift->SUPER::internal_pre_execute(@_);
}

sub internal_select_roles {
    my($self) = @_;
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

sub _do_subscribed {
    my($self, $method, $uid, $is_subscribed) = @_;
    return $self->new_other('UserRealmSubscription')->$method({
        user_id => $uid,
        is_subscribed => $is_subscribed,
    });
}

sub _put_if_in_group {
    my($self, $role, $field, $group) = @_;
    $self->internal_put_field($field => 1)
        if $role->in_category_role_group($group);
    return;
}

1;
