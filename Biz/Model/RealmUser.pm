# Copyright (c) 1999-2012 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmUser;
use strict;
use Bivio::Base 'Model.RealmBase';
b_use('IO.ClassLoaderAUTOLOAD');

my($_ROLES) = join(
    ',',
    map($_->is_admin ? $_->as_sql_param : (), b_use('Auth.Role')->get_list),
);
my($_OFFLINE) = b_use('Type.RealmName')->OFFLINE_PREFIX;
my($_C) = b_use('SQL.Connection');
my($_R) = b_use('Auth.Role');

sub delete_main_roles {
    my($self, $realm_id, $user_id) = @_;
    my($res) = 0;
    map{
        $res = $self->delete
            if $self->unauth_load({
                user_id => $user_id,
                realm_id => $realm_id,
                role => $_,
            })
        } $_R->get_main_list;
    return $res;
}

sub execute_auth_user {
    my($proto, $req) = @_;
    # Loads this realm for this auth user.
    my($user) = $req->get('auth_user') || Bivio::Die->die('no auth_user');
    $proto->new($req)->load({
        user_id => $user->get('realm_id'),
    });
    return;
}

sub get_any_online_admin {
    my($self) = shift;
    return $self->unsafe_get_any_online_admin(@_)
        || $self->throw_die('DIE', {
            message => 'no admins found',
            entity => $self->ureq('auth_realm'),
        });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'realm_user_t',
        columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            user_id => ['User.user_id', 'PRIMARY_KEY'],
            role => ['RealmRole.role', 'PRIMARY_KEY'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
        },
#TODO: SECURITY: If user_id known, does that mean can get to all user's info?
        other => [
            # User_1 is the realm, if the realm_type is a user.
            [qw(realm_id Club.club_id User_1.user_id RealmOwner_1.realm_id)],
            # User_2 is the the "realm_user"
            [qw(user_id User_2.user_id RealmOwner_2.realm_id)],
        ],
    });
}

sub is_auth_user {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Returns true if the current row is the request's auth_user.
    my($auth_user) = $model->get_request->get('auth_user');
    return 0 unless $auth_user;
    return $model->get($model_prefix . 'user_id')
        eq $auth_user->get('realm_id') ? 1 : 0;
}

sub is_sole_admin {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Returns true if this is the only online ADMINISTRATOR left in the realm.
    # Check to see if an admin at all.  This avoids a db query for most
    # realm users.
    return 0 unless $model->get($model_prefix . 'role')->is_admin;
#TODO: fix this code;  Should do_rows.  Indeed, should be RealmUserList.
    return $_C->execute_one_row("
        SELECT count(*)
        FROM realm_owner_t, realm_user_t
        WHERE realm_user_t.realm_id = ?
        AND user_id != ?
        AND role IN ($_ROLES)
        AND realm_user_t.user_id = realm_owner_t.realm_id
        AND realm_owner_t.name NOT LIKE '$_OFFLINE\%'",
        [$model->get($model_prefix . 'realm_id',
            $model_prefix . 'user_id')])->[0] ? 0 : 1;
}

sub is_user_attached_to_other_realms {
    my($self, $user_id) = @_;
    my($ignore) = {
        $user_id => 1,
        FacadeComponent_Constant()->unsafe_get_value('site_admin_realm_id') => 1,
    };
    my($res) = 0;
    $self->do_iterate(
        sub {
            my($it) = @_;
            return 1
                if $ignore->{$it->get('realm_id')};
            $res = 1;
            return 0;
        },
        'unauth_iterate_start',
        {user_id => $user_id},
    );
    return $res;
}

sub unauth_delete_user {
    my($self) = @_;
    my($uid) = $self->get('user_id');
    my($req) = $self->req;
    my($delete) = sub {$self->new->delete_all({user_id => $uid})};
    $req->with_realm($self->get('realm_id'), $delete);
    $self->new_other('UserCreateForm')->if_unapproved_applicant_mode($delete);
    $self->new_other('RealmOwner')->unauth_delete_realm({realm_id => $uid});
    return;
}

sub unsafe_get_any_online_admin {
    my($self) = @_;
    my($owner);
    $self->do_iterate(
        sub {
            my($it) = @_;
            return 1
                unless $it->get('role')->is_admin;
            $owner = $it->new_other('RealmOwner');
            return 0
                unless $owner->unauth_load_or_die({
                    realm_id => $self->get('user_id'),
                })->is_offline_user;
            $owner = undef;
            return 1;
        },
        'user_id',
    );
    return $owner;
}

sub update_role {
    my($self, $role) = @_;
    # Changes the role by deleting and recreating the RealmUser record.
    # Primary keys can't be update in bOP.
    return $self
        if $self->get('role') == $role;
    my($values) = $self->get_shallow_copy;
    $self->delete;
    return $self->create({
        %$values,
        role => $role,
    });
}

1;
