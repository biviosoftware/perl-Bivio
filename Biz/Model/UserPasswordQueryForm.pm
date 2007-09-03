# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserPasswordQueryForm;
use strict;
use Bivio::Base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    # Default the email address to the user in the cookie if present.
    # don't overwrite if already set by subclass
    return if $self->unsafe_get('Email.email');
    my($req) = $self->get_request;
    $self->SUPER::execute_empty;
    my($cookie) = $req->unsafe_get('cookie');
    return unless $cookie;
    my($user_id) = $cookie->unsafe_get(
        $self->get_instance('UserLoginForm')->USER_FIELD);
    return unless $user_id;
    my($email) = $self->new_other('Email');
    return unless $email->unauth_load({
        realm_id => $user_id,
    });
    $email = $email->unsafe_get('email');
    return unless Bivio::Type->get_instance('Email')->is_valid($email);
    $self->internal_put_field('Email.email' => $email);
    return;
}

sub execute_ok {
    my($self) = @_;
    # Sets the user's password to a random value. Saves the reset URI in the
    # 'uri' field. Performs a server redirect to the next task when done.
    my($req) = $self->get_request;
    my($e) = $self->new_other('Email');
    unless ($e->unauth_load({email => $self->get('Email.email')})) {
	$self->internal_put_error(qw(Email.email NOT_FOUND));
	return;
    }
    if ($self->get_request->is_super_user($e->get('realm_id'))) {
	$self->internal_put_error(qw(Email.email PASSWORD_QUERY_SUPER_USER));
	return;
    }
    $self->get_request->set_realm($e->get('realm_id'));
    if ($e->get_model('RealmOwner')->require_otp) {
	$self->internal_put_error(qw(Email.email PASSWORD_QUERY_OTP));
	return;
    }
    $self->internal_put_field(
	uri => Bivio::Biz::Action->get_instance('UserPasswordQuery')
	    ->format_uri($req),
    );
    $self->put_on_request(1);
    return 'server_redirect.next';
}

sub internal_initialize {
    my($self) = @_;
    # Returns config
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	visible => [
	    'Email.email',
	],
	other => [
	    {
		name => 'uri',
		type => 'Line',
		constraint => 'NONE',
	    },
	],
    });
}

1;
