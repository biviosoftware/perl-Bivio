# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Email;
use strict;
use Bivio::Base 'Model.LocationBase';

my($_E) = b_use('Type.Email');

sub create {
    my($self, $values) = (shift, shift);
    $values->{want_bulletin} = 1
	unless defined($values->{want_bulletin});
    return $self->SUPER::create($self->internal_prepare_query($values), @_);
}

sub email_for_auth_user {
    my($self) = @_;
    return $self->unauth_load_or_die({
	realm_id => $self->req('auth_user_id'),
	location => $self->DEFAULT_LOCATION,
    })->get('email');
}

sub internal_initialize {
    return {
	version => 2,
	table_name => 'email_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            location => ['Location', 'PRIMARY_KEY'],
            email => ['Email', 'NOT_NULL_UNIQUE'],
	    want_bulletin => ['Boolean', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
        other => [
            [qw(realm_id RealmOwner.realm_id)],
        ],
    };
}

sub internal_prepare_query {
    my($self, $values) = (shift, shift);
    $values->{email} = lc($values->{email})
	if $values->{email};
    return $self->SUPER::internal_prepare_query($values, @_);
}

sub invalidate {
    my($self) = @_;
    my($address) = $self->get('email');
    my($prefix) = $self->get_field_type('email')->INVALID_PREFIX;
    return if $address =~ /^\Q$prefix/o;
    my($other) = $self->new_other('Email');
    my($i) = 0;
    $i++ while $other->unauth_load({email => $prefix . $i . $address});
    $self->update({
	email => $prefix . $i . $address,
	want_bulletin => 0,
    });
    return;
}

sub is_ignore {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return $_E->is_ignore($model->get($model_prefix.'email'));
}

sub unsafe_user_id_from_email {
    my($self, $email) = @_;

    # detect a rewritted email domain
    if ($email && $email =~ /(\w+)\*(\d+)@/) {
        my($tag, $realm_id) = ($1, $2);
        return $realm_id
            if $tag eq  b_use('Action.MailForward')->REWRITE_FROM_DOMAIN_URI;
    }
    # guard against duplicate email, use user with role, or oldest id
    my($user_ids) = $self->map_iterate(
	'realm_id', 'unauth_iterate_start', 'realm_id ASC', {
	    email => $email,
	});
    return undef unless @$user_ids;

    if (@$user_ids > 1) {
	foreach my $user_id (@$user_ids) {
	    return $user_id
		if @{$self->new_other('RealmUser')->map_iterate('role', {
		    user_id => $user_id,
		})};
	}
    }
    return $user_ids->[0];
}

sub update {
    my($self, $values) = (shift, shift);
    return $self->SUPER::update($self->internal_prepare_query($values), @_);
}

1;
