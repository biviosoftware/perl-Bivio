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
	my($m);
	if (my $e = $self->unsafe_get('Email.email')) {
	    $m = $self->new_other('Email');
	    return unless $m->unauth_load({email => lc($e)});
	}
	elsif (my $n = $self->unsafe_get('user_name')) {
	    $m = $self->new_other('RealmOwner');
	    return unless $m->unauth_load({name => $n});
	}
	$self->internal_put_field('User.user_id' => $m->get('realm_id'));
    }
    $self->req->with_realm(
	$self->get('RealmUser.realm_id'),
	sub {
	    $self->new_other('RealmUser')->delete_all(
		{user_id => $self->get('User.user_id')});
	    return;
	},
    );
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
	    {
		name => 'user_name',
		type => 'RealmOwner.name',
		constraint => 'NONE',
	    },
	    'RealmUser.realm_id',
	    'User.user_id',
	],
    });
}

1;
