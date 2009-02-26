# Copyright (c) 2002-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserCreateForm;
use strict;
use Bivio::Base 'Biz.FormModel';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DN) = __PACKAGE__->use('Type.DisplayName');
my($_A) = __PACKAGE__->use('IO.Alert');
my($_GUEST) = b_use('Auth.Role')->GUEST;
b_use('IO.Config')->register(my $_CFG = {
    unapproved_applicant_mode => 0,
});

sub execute_ok {
    my($self) = @_;
    my($r) = $self->internal_create_models;
    $self->new_other('UserLoginForm')->process({realm_owner => $r})
	unless $self->unsafe_get('without_login');
    return;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub if_unapproved_applicant_mode {
    my($self, $then, $else) = @_;
    if ($_CFG->{unapproved_applicant_mode}) {
	return $then->()
	    unless ref($self);
	return $self->req->with_realm(
	    b_use('FacadeComponent.Constant')
		->get_value('site_admin_realm_name', $self->req),
	    $then,
	);
    }
    return $else->()
	if $else;
    return;
}

sub internal_create_models {
    my($self, $params) = @_;
    # Creates User, RealmOwner, Email and RealmUser models.
    # Returns the RealmOwner and User created.
    #
    # Sets the password to INVALID if does not exist.
    # Email is set to an ignored value if it doesn't exist.
    #
    # The only difference between this method and execute_ok is that
    # the user is logged in at that point.
    #
    # Will not create email if value is
    # L<Bivio::Type::Email::IGNORE_PREFIX|Bivio::Type::Email::IGNORE_PREFIX>.
    #
    # Returns () if there is an error.
    $params ||= {};
    my($req) = $self->get_request;
    my($user, $realm) = $self->new_other('User')->create_realm(
	$self->parse_to_names('RealmOwner.display_name') || return,
	$self->get_model_properties('RealmOwner'),
    );
    $self->internal_put_field('User.user_id' => $user->get('user_id'));
    my($e) = $self->new_other('Email');
    my($et) = $e->get_field_type('email');
    $e->create({
	realm_id => $user->get('user_id'),
	email => $self->unsafe_get('Email.email')
	    || $et->format_ignore(
		$realm->get('name')
		    . '-'
		    . $self->use('Bivio::Biz::Random')->hex_digits(8),
		$req,
	    ),
	want_bulletin => defined($params->{'Email.want_bulletin'})
	    ? $params->{'Email.want_bulletin'} : 1,
    }) unless ($self->unsafe_get('Email.email') || '') eq $et->IGNORE_PREFIX;
    return ($realm, $user);
}

sub internal_initialize {
    my($self) = @_;
    # B<FOR INTERNAL USE ONLY>
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	visible => [
	    'RealmOwner.display_name',
	    'Email.email',
            'RealmOwner.password',
	    {
		name => 'confirm_password',
		type => 'Password',
		constraint => 'NOT_NULL',
	    },
	],
	$self->field_decl(other => [qw(
	    RealmOwner.name
	    User.user_id
	    without_login
	    password_ok
	)], 'Boolean'),
    });
}

sub parse_display_name {
    my(undef, $name) = @_;
    $_A->warn_deprecated('use parse_to_names');
    return $_DN->parse_to_names($name);
}

sub parse_to_names {
    my(undef, $delegator, $field) = shift->delegated_args(@_);
    my($x) = $_DN->parse_to_names($delegator->get($field));
    unless (ref($x) eq 'HASH') {
	$delegator->internal_put_error($field => $x);
	return;
    }
    return $x;
}

sub validate {
    my($self) = @_;
    # Ensures the fields are valid.
    $self->internal_put_error('RealmOwner.password', 'CONFIRM_PASSWORD')
	unless $self->get_field_error('RealmOwner.password')
	    || $self->get_field_error('confirm_password')
	    || $self->get('RealmOwner.password')
		eq $self->get('confirm_password');
    return;
}

1;
