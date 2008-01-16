# Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::UserAccountForm;
use strict;
use Bivio::Base 'Model.UserCreateForm';

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
    return shift->SUPER::execute_ok(@_)
	unless _is_editing($self);
    _do_models(
	$self,
	sub {shift->update($self->get_model_properties(shift))},
    );
    $self->new_other('UserAccount')->load;
    return;
}

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
            'Address.street1',
            'Address.street2',
            'Address.city',
            'Address.state',
            'Address.zip',
            'Address.country',
            'Phone.phone',
	    map(+{
		name => $_,
		constraint => 'NONE',
	    }, qw(RealmOwner.password RealmOwner.display_name confirm_password)),
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

sub parse_to_names {
    return shift->get_model_properties('User');
}

sub validate {
    my($self) = @_;
    # Ensures password is valid if required.
    $self->validate_not_null('RealmOwner.password')
        unless _is_editing($self);
    return;
}

sub internal_create_models {
    my($self) = shift;
    $self->internal_put_field('RealmOwner.display_name', '');
    my($realm, @rest) = $self->SUPER::internal_create_models(@_);
    $self->req->set_realm($realm);
    foreach my $model (qw(Address Phone)) {
	$self->new_other($model)->create({
            %{$self->get_model_properties($model)},
	});
    }
    $self->new_other('UserAccount')->create({
	user_id => $realm->get('realm_id'),
	status => $self->use('Type.UserStatus')->CUSTOMER,
	user_type => $self->use('Type.UserType')->HOME_CONSUMER,
    });
    return ($realm, @rest);
}

sub _do_models {
    my($self, $op) = @_;
    foreach my $model (qw(User Address Email Phone)) {
	$op->(
	    $self->new_other($model)->load({}),
	    $model,
	);
    }
    return;
}

sub _is_editing {
    my($self) = @_;
    return 0
	if $self->unsafe_get('force_create');
    my($s) = $self->get_request->unsafe_get('user_state');
    return $s && $s->eq_logged_in;
}

1;
