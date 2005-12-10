# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmUserAddForm;
use strict;
use base 'Bivio::Biz::Model::UserRegisterForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    my($e) = $self->new_other('Email');
    _join_user(
	$self,
	$self->unsafe_get('User.user_id')
	    || ($e->unauth_load({email => $self->get('Email.email')})
		? $e->get('realm_id')
		: (($self->internal_create_models)[0] || return)
		    ->get('realm_id')),
	$self->unsafe_get('RealmUser.realm_id')
	    || $self->unsafe_get('realm')
		&& $self->new_other('RealmOwner')->unauth_load_or_die({
		    name => $self->get('realm'),
		})->get('realm_id')
	    || $self->get_request->get('auth_id'),
    );
    return;
}

sub internal_get_roles {
    return [Bivio::Auth::Role->MEMBER];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	other => [
	    {
		name => 'realm',
		type => 'RealmOwner.name',
		constraint => 'NONE',
	    },
	    'RealmUser.realm_id',
	    'RealmUser.role',
	],
    });
}

sub _join_user {
    my($self, $user_id, $realm_id) = @_;
    $self->internal_put_field('RealmUser.realm_id' => $realm_id);
    $self->internal_put_field('User.user_id' => $user_id);
    foreach my $r (
	grep($_, @{$self->internal_get_roles}, $self->unsafe_get('RealmUser.role')),
    ) {
	$self->new_other('RealmUser')->create_or_unauth_update({
	    realm_id => $realm_id,
	    user_id => $user_id,
	    role => $r,
	});
    }
    return;
}

1;
