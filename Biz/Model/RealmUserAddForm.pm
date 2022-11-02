# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmUserAddForm;
use strict;
use Bivio::Base 'Model.UserRegisterForm';
#TODO: Problably should not subclass UserRegisterForm, but should call
#      UserCreateForm to create the user
b_use('IO.ClassLoaderAUTOLOAD');

my($_RU) = b_use('ShellUtil.RealmUser');
my($_R) = b_use('Auth.Role');

sub copy_admins {
    my($self, $realm_id, $admin_user_id) = @_;
    my($req) = $self->get_request;
    foreach my $admin_id (
        ref($admin_user_id) ? @$admin_user_id
            : $admin_user_id ? $admin_user_id
            : _admin_list($self),
    ) {
        $self->new->process({
            'RealmUser.realm_id' => $realm_id,
            'User.user_id' => $admin_id,
            administrator => 1,
        });
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    my(@args) = (
        $self->internal_user_id || return,
        $self->internal_realm_id,
    );
    _join_user($self, @args);
    $self->set_subscription(@args);
    return;
}

sub internal_get_roles {
    my($self) = @_;
    return [
        map($_R->from_name($_),
            $self->unsafe_get('administrator') ? qw(ADMINISTRATOR FILE_WRITER) : (
                'MEMBER',
                $self->unsafe_get('file_writer') ? 'FILE_WRITER' : (),
            ),
            'MAIL_RECIPIENT',
        ),
    ];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
        $self->field_decl(visible =>
            [qw(is_subscribed administrator file_writer)],
            qw(Boolean NONE),
        ),
        other => [
            {
                # Match RealmUserDeleteForm
                name => 'realm',
                type => 'RealmOwner.name',
                constraint => 'NONE',
            },
            {
                # Match RealmUserDeleteForm
                name => 'other_roles',
                type => 'Array',
                constraint => 'NONE',
            },
            {
                name => 'dont_add_subscription',
                type => 'Boolean',
                constraint => 'NONE',
            },
            {
                name => 'override_default_subscription',
                type => 'Boolean',
                constraint => 'NONE',
            },
            'RealmUser.realm_id',
        ],
    });
}

sub internal_realm_id {
    my($self) = @_;
    my($id) = $self->unsafe_get('RealmUser.realm_id');
    $self->internal_put_field('RealmUser.realm_id' =>
         $id = $self->unsafe_get('realm')
             && $self->new_other('RealmOwner')
             ->unauth_load_or_die({name => $self->get('realm')})
             ->get('realm_id')
             || $self->get_request->get('auth_id'),
    ) unless $id;
    return $id;
}

sub internal_user_id {
    my($self) = @_;
    my($id) = $self->unsafe_get('User.user_id');
    my($e) = $self->new_other('Email');
    $self->internal_put_field('User.user_id' =>
        $id = $e->unauth_load({email => $self->get('Email.email')})
            ? $e->get('realm_id')
            : (($self->internal_create_models)[0] || return)->get('realm_id'),
    ) unless $id;
    return $id;
}

sub set_subscription {
    my($self, $user_id, $realm_id) = @_;
    return
        if $self->unsafe_get('dont_add_subscription');
    $self->new_other('UserRealmSubscription')->create({
        user_id => $user_id,
        realm_id => $realm_id,
        is_subscribed => $self->unsafe_get('override_default_subscription')
            ? $self->unsafe_get('is_subscribed') : undef,
    }) unless _is_subscription_status_set($self, $user_id, $realm_id);
    return;
}

sub _admin_list {
    my($self) = @_;
    return @{$self->new_other('RealmAdminList')->map_iterate(
        sub {shift->get('RealmUser.user_id')},
        'unauth_iterate_start',
        {auth_id => $self->req('auth_id')},
    )};
}

sub _is_subscription_status_set {
    my($self, $user_id, $realm_id) = @_;
    return $self->new_other('UserRealmSubscription')->unauth_load({
        user_id => $user_id,
        realm_id => $realm_id,
    });
}

sub _join_user {
    my($self, $user_id, $realm_id) = @_;
    $self->internal_put_field('RealmUser.realm_id' => $realm_id);
    $self->internal_put_field('User.user_id' => $user_id);
    # Just in case there's another RealmUser record
    my($v) = {
        user_id => $user_id,
        realm_id => $realm_id,
    };
    foreach my $r (
        @{$self->unsafe_get('other_roles') || []},
        @{$self->internal_get_roles},
    ) {
        $self->new_other('RealmUser')->unauth_create_or_update({
            %$v,
            role => $r,
        });
    }
    $self->req->with_realm_and_user($realm_id, $user_id, sub {
        $_RU->new->audit_user;
    }) if $_RU->IS_AUDIT_ENABLED;
    return;
}

1;
