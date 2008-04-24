# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserPasswordQueryForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_E) = __PACKAGE__->use('Type.Email');
my($_USER_FIELD) = __PACKAGE__->use('Model.UserLoginForm')->USER_FIELD;

sub QUERY_KEY {
    return 'email';
}

sub add_email_to_query {
    my($proto, $email, $query) = @_;
    ($query ||= {})->{$proto->QUERY_KEY} = $email;
    return $query;
}

sub execute_empty {
    my($self) = @_;
    # Default the email address to the user in the cookie if present.
    # don't overwrite if already set by subclass
    return if $self->unsafe_get('Email.email');
    my($req) = $self->get_request;
    $self->SUPER::execute_empty;
    my($email) = $self->new_other('Email');
    if (my $q = $self->ureq('query')) {
	$q = $q->{$self->QUERY_KEY};
	return
	    unless $q && $email->unauth_load({email => $q});
    }
    else {
	return
	    unless my $cookie = $req->ureq('cookie');
	my($user_id) = $cookie->unsafe_get($_USER_FIELD);
	return
	    unless $user_id && $email->unauth_load({
	    realm_id => $user_id,
	});
    }
    $email = $email->unsafe_get('email');
    return
	unless $_E->is_valid($email);
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
	query => undef,
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
