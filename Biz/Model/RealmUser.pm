# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmUser;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ROLES) = join(
    ',',
    map($_->is_admin ? $_->as_sql_param : (),
	__PACKAGE__->use('Auth.Role')->get_list),
);
my($_OFFLINE) = __PACKAGE__->use('Type.RealmName')->OFFLINE_PREFIX;
my($_C) = __PACKAGE__->use('SQL.Connection');

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
    my($self) = @_;
    # Returns I<Model.RealmOwner> for any online Administrator for
    # I<Request.auth_realm>.  Dies if none (shouldn't be the case).
    $self->iterate_start('user_id', {});
    my($owner) = $self->new_other('RealmOwner');

    while ($self->iterate_next_and_load) {
        next unless $self->get('role')->is_admin;
        next if $owner->unauth_load_or_die({
            realm_id => $self->get('user_id'),
        })->is_offline_user;
        $self->iterate_end;
	return $owner;
    }
    $self->throw_die('DIE', {
	message => 'no admins found',
	entity => $self->get_request->unsafe_get('auth_realm'),
    });
    # DOES NOT RETURN
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

sub unauth_delete_user {
    my($self) = @_;
    my($uid) = $self->get('user_id');
    $self->do_iterate(
	sub {
	    shift->unauth_delete;
	    return 1;
	},
	'unauth_iterate_start',
	'role',
	{user_id => $uid, realm_id => $self->get('realm_id')},
    );
    $self->new_other('RealmOwner')->unauth_delete_realm({realm_id => $uid});
    return;
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
