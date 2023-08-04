# Copyright (c) 2002-2023 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserCreateForm;
use strict;
use Bivio::Base 'Biz.FormModel';
use Bivio::IO::Trace;
b_use('IO.ClassLoaderAUTOLOAD');

my($_A) = b_use('IO.Alert');
my($_DN) = b_use('Type.DisplayName');
my($_GUEST) = b_use('Auth.Role')->GUEST;
my($_USER) = $_GUEST->USER;
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
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
    my($self, $then) = (shift, shift);
    my($then2) = sub {
        return $then->()
            unless ref($self);
        return $self->req->with_realm(
            b_use('FacadeComponent.Constant')
                ->get_value('site_admin_realm_name', $self->req),
            $then,
        );
    };
    return $self->if_then_else($_CFG->{unapproved_applicant_mode}, $then2, @_);
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
        {
            %{$self->get_model_properties('RealmOwner')},
            password => $self->unsafe_get('new_password'),
        },
    );
    $self->internal_put_field('User.user_id' => $user->get('user_id'));
    my($e) = $self->new_other('Email');
    my($et) = $e->get_field_type('email');
    $e->create({
        realm_id => $user->get('user_id'),
        email => $self->unsafe_get('Email.email')
            || $et->format_ignore_random($realm->get('name'), $req),
        want_bulletin => defined($params->{'Email.want_bulletin'})
            ? $params->{'Email.want_bulletin'} : 1,
    }) unless ($self->unsafe_get('Email.email') || '') eq $et->IGNORE_PREFIX;
    return
        unless $self->internal_validate_realm_owner_password($realm);
    $self->join_site_admin_realm
        if $_C->if_version(10);
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
            {
                name => 'new_password',
                type => 'NewPassword',
                constraint => 'NOT_NULL',
            },
            {
                name => 'confirm_password',
                type => 'ConfirmPassword',
                constraint => 'NOT_NULL',
            },
        ],
        other => [
            'RealmOwner.name',
            'User.user_id',
            $self->field_decl([qw(
                without_login
                password_ok
            )], 'Boolean'),
        ],
    });
}

sub internal_validate_realm_owner_password {
    my($self, $realm_owner) = @_;
    $realm_owner ||= $self->ureq(qw(auth_realm owner)) || b_die('realm owner required');
    # Disallow old field name
    b_die('use new_password')
        if $self->unsafe_get('RealmOwner.password');
    if (my $err = $realm_owner->validate_password($self->unsafe_get('new_password') // '')) {
        $self->internal_put_error('new_password' => $err);
        return 0;
    }
    return 1;
}

sub join_site_admin_realm {
    my($self, $user_id) = @_;
    my($ro) = $self->new_other('RealmOwner');
    return
        unless $ro->unauth_load({
            name => b_use('FacadeComponent.Constant')
            ->get_value('site_admin_realm_name', $self->req),
        });
    $self->req->with_realm(
        $ro,
        sub {
            return $self->new_other('GroupUserForm')
                ->change_main_role(
                    $user_id || $self->get('User.user_id'),
                    $_USER,
               );
        },
    );
    return;
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
    $self->internal_put_error('new_password', 'CONFIRM_PASSWORD')
        unless $self->get_field_error('new_password')
            || $self->get_field_error('confirm_password')
            || $self->get('new_password') eq $self->get('confirm_password');
    return;
}

1;
