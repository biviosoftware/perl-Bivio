# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserRegisterForm;
use strict;
use base 'Bivio::Biz::Model::UserCreateForm';
use Bivio::Biz::Random;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self, ) = @_;
    my($req) = $self->get_request;
    my($r) = $self->internal_create_models;
    $req->set_realm($r);
    return
	if $self->unsafe_get('password_ok');
    $self->internal_put_field(
	uri => Bivio::Biz::Action->get_instance('UserPasswordQuery')
	    ->format_uri($req),
    );
    $self->put_on_request(1);
    return {
	method => 'server_redirect',
	task_id => 'next',
	query => '',
    };
}

sub internal_create_models {
    my($self) = shift;
    $self->internal_put_field(
	'RealmOwner.display_name' => substr(
	    ($self->get('Email.email') =~ /^(.*)\@/)[0] || 'x',
	    0,
	    $self->get_instance('User')->get_field_type('last_name')->get_width,
	 ),
    ) unless $self->unsafe_get('RealmOwner.display_name');
    $self->internal_put_field(
	'RealmOwner.password' => Bivio::Biz::Random->password,
    ) unless $self->unsafe_get('RealmOwner.password')
	&& $self->unsafe_get('password_ok');
    return $self->SUPER::internal_create_models(@_);
}

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    @{$info->{visible}} = grep(ref($_) && $_->{type} =~ /Button/, @{$info->{visible}});
    return $self->merge_initialize_info($info, {
        version => 1,
	visible => [
	    'Email.email',
	    {
		name => 'RealmOwner.display_name',
		constraint => 'NONE',
	    },
	],
	other => [
	    {
		name => 'RealmOwner.password',
		constraint => 'NONE',
	    },
	    {
		name => 'uri',
		type => 'String',
		constraint => 'NONE',
	    },
	    {
		name => 'password_ok',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	],
    });
}

sub validate {
    return;
}

1;
