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
    $self->load_from_model_properties($self->get_request->get('auth_user'));
    foreach my $model (qw(Address Email Phone)) {
	$self->load_from_model_properties(
            $self->new_other($model)->load({
                location => Bivio::Type::Location->PRIMARY,
            }));
    }
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Saves the current values into the models.

=cut

sub execute_ok {
    my($self) = @_;
    _create_user($self)
	unless _is_editing($self);
    my($account) = $self->new_other('UserAccount')->load;

    foreach my $model (qw(User)) {
	$self->new_other($model)->load->update(
	    $self->get_model_properties($model));
    }

    foreach my $model (qw(Address Email Phone)) {
	$self->new_other($model)->load({
	    location => Bivio::Type::Location->PRIMARY,
	})->update($self->get_model_properties($model));
    }
    Bivio::Die->die("invalid password")
	unless $self->get_request->get('auth_user')->has_valid_password;
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
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

=for html <a name="validate"></a>

=head2 validate()

Ensures password is valid if required.

=cut

sub validate {
    my($self) = @_;
    $self->validate_not_null('RealmOwner.password')
        unless _is_editing($self);
    return;
}

#=PRIVATE METHODS

# _create_user()
#
# Creates the models necessary for a new user.
#
sub _create_user {
    my($self) = @_;
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
	honorific => Bivio::Type::Honorific->SELF,
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

# _is_editing() : boolean
#
# Returns true if the account is being edited.
#
sub _is_editing {
    my($self) = @_;
    return 0 if $self->unsafe_get('force_create');
    my($s) = $self->get_request->unsafe_get('user_state');
    return $s && $s == Bivio::Type::UserState->LOGGED_IN;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
