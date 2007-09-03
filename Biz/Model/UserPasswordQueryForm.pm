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
    return unless $self->validate_email_and_put_uri;
    $self->put_on_request(1);
    return {
 	method => 'server_redirect',
 	task_id => 'next',
#TODO: This doesn't work, because the ack is not set at this point.
#   Action.Acknowledgement is called after the return, and that
#   puts the ack on the query.
# 	query => $self->get_request->unsafe_get('query'),
     };
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

sub validate_email_and_put_uri {
    my($self, $form) = @_;
    $form ||= $self;
    my($req) = $form->get_request;
    my($e) = $form->new_other('Email');
    unless ($e->unauth_load({email => $form->get('Email.email')})) {
	$form->internal_put_error(qw(Email.email NOT_FOUND));
	return 0;
    }
    $form->internal_put_field(
	uri => $req->with_realm(
	    $e->get('realm_id'),
	    sub {
		my($ro) = $form->req(qw(auth_realm owner));
		return Bivio::Biz::Action->get_instance('UserPasswordQuery')
		    ->format_uri($req)
		    unless $req->is_super_user($ro->get('realm_id'))
		    || $ro->require_otp;
		$form->internal_put_error(qw(Email.email PERMISSION_DENIED));
		return;
	    },
	) || return 0,
    );
    return 1;
}

1;
