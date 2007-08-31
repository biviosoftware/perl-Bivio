# Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::UserAccountForm;
use strict;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Base 'Bivio::Biz::FormModel';
use Bivio::Die;
use Bivio::PetShop::Type::UserStatus;
use Bivio::PetShop::Type::UserType;
use Bivio::Type::Location;
use Bivio::Type::Password;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    # Loads values for the current user, if present.
    return unless _is_editing($self);
    _do_models(
	$self,
	sub {$self->load_from_model_properties(shift)},
    );
    return;
}

sub execute_ok {
    my($self) = @_;
    # Saves the current values into the models.
    _create_user($self)
	unless _is_editing($self);
    my($account) = $self->new_other('UserAccount')->load;
    _do_models(
	$self,
	sub {shift->update($self->get_model_properties(shift))},
    );
    Bivio::Die->die("invalid password")
	unless $self->get_request->get('auth_user')->has_valid_password;
    return;
}

sub internal_initialize {
    my($self) = @_;
    # B<FOR INTERNAL USE ONLY>
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	visible => [
            {
                name => 'User.first_name',
                constraint => 'NOT_NULL',
            },
            {
                name => 'User.last_name',
                constraint => 'NOT_NULL',
            },
	    'Email.email',
            'Address.street1',
            'Address.street2',
            'Address.city',
            'Address.state',
            'Address.zip',
            'Address.country',
            'Phone.phone',
	    {
		name => 'RealmOwner.password',
		constraint => 'NONE',
	    },
	],
	other => [
	    {
		# Set this if you want to avoid problems with
		# _is_editing().  See Petshop::Util for an example.
		name => 'force_create',
		type => 'Boolean',
		constraint => 'NONE',
	    },
        ],
    });
}

sub validate {
    my($self) = @_;
    # Ensures password is valid if required.
    $self->validate_not_null('RealmOwner.password')
        unless _is_editing($self);
    return;
}

sub _create_user {
    my($self) = @_;
    # Creates the models necessary for a new user.
    my($user) = $self->new_other('User')->create(
	$self->get_model_properties('User'));
    my($realm) = $self->new_other('RealmOwner')->create({
	%{$self->get_model_properties('RealmOwner')},
        name => 'u' . $user->get('user_id'),
	realm_id => $user->get('user_id'),
	realm_type => Bivio::Auth::RealmType->USER,
	password => Bivio::Type::Password->encrypt(
	    $self->get('RealmOwner.password')),
    });
    $self->new_other('RealmUser')->create({
	realm_id => $user->get('user_id'),
	user_id => $user->get('user_id'),
	role => Bivio::Auth::Role->ADMINISTRATOR,
    });

    foreach my $model (qw(Address Email Phone)) {
	$self->new_other($model)->create({
            realm_id => $user->get('user_id'),
            location => Bivio::Type::Location->PRIMARY,
            %{$self->get_model_properties($model)},
	});
    }
    $self->new_other('UserAccount')->create({
	user_id => $user->get('user_id'),
	status => Bivio::PetShop::Type::UserStatus->CUSTOMER,
	user_type => Bivio::PetShop::Type::UserType->HOME_CONSUMER,
    });

    my($req) = $self->get_request;
    $self->get_instance('UserLoginForm')->execute($req, {
	realm_owner => $realm,
    });
    $req->set_realm($realm);
    return;
}

sub _do_models {
    my($self, $op) = @_;
    # Operate on User, Address, Email, Phone
    foreach my $model (qw(User Address Email Phone)) {
	$op->(
	    $self->new_other($model)->load({
		$model eq 'User' ? ()
		    : (location => Bivio::Type::Location->PRIMARY),
	    }),
	    $model,
	);
    }
    return;
}

sub _is_editing {
    my($self) = @_;
    # Returns true if the account is being edited.
    return 0 if $self->unsafe_get('force_create');
    my($s) = $self->get_request->unsafe_get('user_state');
    return $s && $s == Bivio::Type::UserState->LOGGED_IN;
}

1;
