# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmUserAddForm;
use strict;
use Bivio::Base 'Model.UserRegisterForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub copy_admins {
    my($self, $realm_id, $admin_user_id) = @_;
    my($req) = $self->get_request;
    foreach my $admin_id (
	$admin_user_id ? $admin_user_id : @{
	    $self->new_other('RealmAdminList')->map_iterate(
	    sub {shift->get('RealmUser.user_id')},
	    'unauth_iterate_start',
	    {auth_id => $req->get('auth_id')},
	)},
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
    _join_user(
	$self,
	$self->internal_user_id,
	$self->internal_realm_id,
    );
    return;
}

sub internal_get_roles {
    my($self) = @_;
    return [
	Bivio::Auth::Role->MEMBER,
	map(Bivio::Auth::Role->$_(),
	    $self->unsafe_get('not_mail_recipient') ? () : 'MAIL_RECIPIENT',
	    $self->unsafe_get('administrator') ? qw(ADMINISTRATOR FILE_WRITER)
		: $self->unsafe_get('file_writer') ? 'FILE_WRITER' : (),
	),
    ];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	$self->local_field(visible =>
	    [qw(not_mail_recipient administrator file_writer)],
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

sub _join_user {
    my($self, $user_id, $realm_id) = @_;
    $self->internal_put_field('RealmUser.realm_id' => $realm_id);
    $self->internal_put_field('User.user_id' => $user_id);
    foreach my $r (
	@{$self->unsafe_get('other_roles') || []},
	@{$self->internal_get_roles},
    ) {
	$self->new_other('RealmUser')->unauth_create_or_update({
	    realm_id => $realm_id,
	    user_id => $user_id,
	    role => $r,
	});
    }
    return;
}

1;
