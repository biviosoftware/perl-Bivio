# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::User;
use strict;
use Bivio::Base 'Model.RealmOwnerBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ADMINISTRATOR) = __PACKAGE__->use('Auth.Role')->ADMINISTRATOR;

sub concat_last_first_middle {
    my(undef, $last, $first, $middle) = @_;
    # Does the work of L<format_last_first_middle|"format_last_first_middle">.

    # We shown the last_name as "-" if not set.
    if (defined($last)) {
	my($res) = undef;
	return $last unless defined($first) || defined($middle);
	$res = $last . ',';
	$res .= ' ' . $first if defined($first);
	$res .= ' ' . $middle if defined($middle);
	return $res;
    }
    return $first . ' ' . $middle if defined($first) && defined($middle);
    return defined($first) ? $first : $middle;
}

sub create {
    my($self, $values) = @_;
    # Sets I<gender> if not set and computes the sorting name fields then
    # calls SUPER.
    $values->{gender} ||= $self->get_field_type('gender')->UNKNOWN;
    _compute_sorting_names($values);
    my($res) = $self->SUPER::create($values);
    _validate_names($self);
    return $res;
}

sub create_realm {
    my($self, $user, $realm_owner) = @_;
    $self->create($user);
    $realm_owner ||= {};
    $realm_owner->{password}
	= $self->use('Type.Password')->encrypt($realm_owner->{password})
        if defined($realm_owner->{password});
    $realm_owner->{display_name} = $self->format_full_name
	unless defined($realm_owner->{display_name});
    return shift->SUPER::create_realm($realm_owner);
}

sub format_full_name {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Returns the first, middle, and last names as one string.
    #
    # B<You should use RealmOwner.display_name whenever possible as the
    # values are identical.>
    my($res) = '';

    foreach my $name ($model->unsafe_get($model_prefix.'first_name',
        $model_prefix . 'middle_name', $model_prefix . 'last_name')) {
	$res .= $name . ' ' if defined($name) && length($name);
    }
    # Get rid of last ' '
    chop($res);
    return $res;
}

sub format_last_first_middle {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Return Last, First Middle.
    #
    # See L<format_name|"format_name"> for params.
    return $proto->concat_last_first_middle($model->unsafe_get(
        $model_prefix . 'last_name', $model_prefix . 'first_name',
        $model_prefix . 'middle_name'));
}

sub get_outgoing_emails {
    my($self, $which) = @_;
    # Returns an array of outgoing addresses for this user if no
    # I<which>.  Otherwise, returns a single address.
    #
    # Returns C<undef> is there are no outgoing email addresses for
    # this user.
    my($email) = $self->new_other('Email');
    return undef unless $email->unauth_load({
        location => $which || $email->get_field_type('location')->HOME,
        realm_id => $self->get('user_id'),
    });
    # Validate address
    return undef
	unless $email->get_field_type('email')->is_valid($email->get('email'));
    return [$email->get('email')];
}

sub internal_create_realm_administrator_id {
    return shift->get('user_id');
}

sub internal_initialize {
    # B<FOR INTERNAL USE ONLY>
    return {
	version => 1,
	table_name => 'user_t',
	columns => {
            user_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            first_name => ['Name', 'NONE'],
            first_name_sort => ['Name', 'NONE'],
            middle_name => ['Name', 'NONE'],
            middle_name_sort => ['Name', 'NONE'],
            last_name => ['Name', 'NONE'],
            last_name_sort => ['Name', 'NONE'],
            gender => ['Gender', 'NOT_NULL'],
            birth_date => ['Date', 'NONE'],
        },
	other => [
            [qw(user_id RealmOwner.realm_id)],
	],
	auth_id => 'user_id',
    };
}

sub invalidate_email {
    my($self) = @_;
    # Invalidates user's e-mail address be prefixing it with "invalid:".
    # Checks to see if already invalidated.
    $self->new_other('Email')->unauth_load_or_die({
        realm_id => $self->get('user_id'),
    })->invalidate;
    return;
}

sub set_encrypted_password {
    my($self, $encrypted) = @_;
    # Sets a user's encrypted password to a new value.
    return _get_realm->update({password => $encrypted});
}

sub unauth_delete_realm {
    my($self, $realm_owner) = @_;
    my($rid) = $realm_owner->get('realm_id');
    $self->new_other('RealmUser')->unauth_delete({
	realm_id => $rid,
	user_id => $rid,
	role => $_ADMINISTRATOR,
    });
    return shift->SUPER::unauth_delete_realm(@_);
}

sub update {
    my($self, $new_values) = @_;
    # Updates the current model's values.  Validates one of
    # first, last and middle are set.
    _compute_sorting_names($new_values);
    my($res) = $self->SUPER::update($new_values);
    _validate_names($self);
    return $res;
}

sub _compute_sorting_names {
    my($values) = @_;
    # Computes the first/middle/last sorting field values.

    # user lower case for sorting
    foreach my $field (qw(first_name middle_name last_name)) {
	next unless exists($values->{$field});

	if (defined($values->{$field}) && length($values->{$field})) {
	    $values->{$field . '_sort'} = lc($values->{$field});
	}
	else {
	    # set both to undef
	    $values->{$field} = undef;
	    $values->{$field . '_sort'} = undef;
	}
    }
    return;
}

sub _get_realm {
    my($self) = @_;
    # Returns the realm owner for the current user_id.
    return $self->new_other('RealmOwner')->unauth_load_or_die({
        realm_id => $self->get('user_id'),
    });
}

sub _validate_names {
    my($self) = @_;
    # Dies unless at least one of first/middle/last names are set.
    $self->die('must have at least one of first, last, and middle names')
        unless defined($self->get('first_name'))
            || defined($self->get('middle_name'))
            || defined($self->get('last_name'));
    return;
}

1;
