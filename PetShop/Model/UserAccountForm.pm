# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::UserAccountForm;
use strict;
$Bivio::PetShop::Model::UserAccountForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::UserAccountForm::VERSION;

=head1 NAME

Bivio::PetShop::Model::UserAccountForm - user account entry

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::UserAccountForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::PetShop::Model::UserAccountForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::UserAccountForm> creates a new user account.

=cut

#=IMPORTS
use Bivio::Auth::RealmType;
use Bivio::Die;
use Bivio::PetShop::Type::EntityLocation;
use Bivio::PetShop::Type::UserStatus;
use Bivio::PetShop::Type::UserType;
use Bivio::Type::Honorific;
use Bivio::Type::Location;
use Bivio::Type::Password;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Loads values for the current user, if present.

=cut

sub execute_empty {
    my($self) = @_;
    return unless _is_editing($self);

    my($req) = $self->get_request;
    $self->load_from_model_properties($req->get('auth_user'));

    # create a default account if necessary
    my($account) = $self->new($req, 'UserAccount');
    unless ($account->unsafe_load) {
	$account = _create_default_account($self);
    }

    foreach my $model (qw(EntityAddress EntityPhone)) {
	$self->load_from_model_properties(
		$self->new($req, $model)->load({
		    entity_id => $account->get('entity_id'),
		    location => Bivio::PetShop::Type::EntityLocation
		    ->PRIMARY,
		}));
    }

    $self->load_from_model_properties($self->new($req, 'User')->load);
    $self->load_from_model_properties(
	    $self->new($req, 'Email')->load({
		location => Bivio::Type::Location->HOME,
	    }));
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Saves the current values into the models.

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;

    _create_user($self)
	unless _is_editing($self);

    my($account) = $self->new($req, 'UserAccount')->load;

    foreach my $model (qw(User Email)) {
	$self->new($req, $model)->load->update(
	    $self->get_model_properties($model));
    }

    foreach my $model (qw(EntityAddress EntityPhone)) {
	$self->new($req, $model)->load({
	    entity_id => $account->get('entity_id'),
	    location => Bivio::PetShop::Type::EntityLocation->PRIMARY,
	})->update($self->get_model_properties($model));
    }

    Bivio::Die->die("invalid password")
	    unless $req->get('auth_user')->has_valid_password;
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 1,
	visible => [
	    'User.first_name',
	    'User.last_name',
	    'Email.email',
	    'EntityAddress.addr1',
	    'EntityAddress.addr2',
	    'EntityAddress.city',
	    'EntityAddress.state',
	    'EntityAddress.zip',
	    'EntityAddress.country',
	    'EntityPhone.phone',
	    {
		name => 'RealmOwner.name',
		constraint => 'NONE',
	    },
	    {
		name => 'RealmOwner.password',
		constraint => 'NONE',
	    },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="validate"></a>

=head2 validate()

Ensures that name and password are valid if required.

=cut

sub validate {
    my($self) = @_;

    # either first or last name must be filled in
    unless (defined($self->get('User.first_name'))
	    || defined($self->get('User.last_name'))) {
	$self->validate_not_null('User.last_name');
    }

    if (_is_editing($self)) {
	$self->internal_put_field('RealmOwner.name'
		=> $self->get_request->get('auth_user')->get('name'));
    }
    else {
	foreach my $field (qw(RealmOwner.name RealmOwner.password)) {
	    $self->validate_not_null($field);
	}
    }
    return;
}

#=PRIVATE METHODS

# _create_default_account(self)
#
# Creates the default account/address/phone entries.
#
sub _create_default_account {
    my($self) = @_;
    my($req) = $self->get_request;

    my($account) = $self->new($req, 'UserAccount')->create({
	user_id => $req->get('auth_user_id'),
	entity_id => $self->new($req, 'Entity')->create->get('entity_id'),
	status => Bivio::PetShop::Type::UserStatus->CUSTOMER,
	user_type => Bivio::PetShop::Type::UserType->HOME_CONSUMER,
    });

    foreach my $model (qw(EntityAddress EntityPhone)) {
	$self->new($req, $model)->create({
	    entity_id => $account->get('entity_id'),
	    location => Bivio::PetShop::Type::EntityLocation->PRIMARY,
	});
    }
    return $account;
}

# _create_user()
#
# Creates the models necessary for a new user.
#
sub _create_user {
    my($self) = @_;
    my($req) = $self->get_request;

    my($user) = $self->new($req, 'User')->create(
	    $self->get_model_properties('User'));

    my($realm) = $self->new($req, 'RealmOwner')->create({
	%{$self->get_model_properties('RealmOwner')},
	realm_id => $user->get('user_id'),
	realm_type => Bivio::Auth::RealmType->USER,
	password => Bivio::Type::Password->encrypt(
	    $self->get('RealmOwner.password')),
    });

    $self->new($req, 'RealmUser')->create({
	realm_id => $user->get('user_id'),
	user_id => $user->get('user_id'),
	honorific => Bivio::Type::Honorific->SELF,
    });

    $self->new($req, 'Email')->create({
	realm_id => $user->get('user_id'),
	location => Bivio::Type::Location->HOME,
	%{$self->get_model_properties('Email')},
    });

    # log the user in
    $self->get_instance('UserLoginForm')->execute($req, {
	realm_owner => $realm,
    }) if $req->unsafe_get('cookie');

    $req->set_user($realm);
    $req->set_realm($realm);
    _create_default_account($self);
    return;
}

# _is_editing() : boolean
#
# Returns true if the account is being edited.
#
sub _is_editing {
    my($self) = @_;
    my($s) = $self->get_request->unsafe_get('user_state');
    return $s && $s == Bivio::Type::UserState->LOGGED_IN;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
