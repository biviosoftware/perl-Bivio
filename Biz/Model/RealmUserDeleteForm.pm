# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmUserDeleteForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    unless ($self->unsafe_get('RealmUser.realm_id')) {
	my($r) = $self->new_other('RealmOwner');
	return unless $r->unauth_load({name => lc($self->get('realm'))});
	$self->internal_put_field('RealmUser.realm_id' => $r->get('realm_id'));
    }
    unless ($self->unsafe_get('User.user_id')) {
	my($e) = $self->new_other('Email');
	return unless $e->unauth_load({email => lc($self->get('Email.email'))});
	$self->internal_put_field('User.user_id' => $e->get('realm_id'));
    }
    my($req) = $self->get_request;
    my($old_realm) = $req->get('auth_id');
    $req->set_realm($self->get('RealmUser.realm_id'));
    $self->new_other('RealmUser')->delete_all(
	{user_id => $self->get('User.user_id')});
    $req->set_realm($old_realm);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    'Email.email',
	],
	other => [
	    # Match RealmUserAddForm
	    {
		name => 'realm',
		type => 'RealmOwner.name',
		constraint => 'NONE',
	    },
	    'RealmUser.realm_id',
	    'User.user_id',
	],
    });
}

1;
