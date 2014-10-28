# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserDefaultSubscription;
use strict;
use Bivio::Base 'Model.RealmBase';
b_use('IO.ClassLoaderAUTOLOAD');

b_use('IO.Config')->register(my $_CFG = {
    app_default => 1,
});

sub default_subscription_realm_id {
    my($self, $realm_type_or_id) = @_;
    my($realm_type) = Auth_RealmType()->is_super_of($realm_type_or_id)
	? $realm_type_or_id
	: $self->new_other('RealmOwner')->unauth_load_or_die({
	    realm_id => $realm_type_or_id,
	})->get('realm_type');
    return $realm_type->as_default_owner_id;
}

sub get_app_default {
    return $_CFG->{app_default};
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'user_default_subscription_t',
        columns => {
	    $self->USER_ID_FIELD => [qw(User.user_id PRIMARY_KEY)],
	    $self->REALM_ID_FIELD => [$self->REALM_ID_FIELD_TYPE, 'PRIMARY_KEY'],
	    subscribed_by_default => [qw(Boolean NOT_NULL)],
	    modified_date_time => [qw(DateTime NOT_NULL)],
	},
    });
}

sub user_default_subscription_status {
    my($self, $user_id, $realm_type_or_id) = @_;
    return $self->unauth_load({
	user_id => $user_id,
	realm_id => $self->default_subscription_realm_id($realm_type_or_id),
    })
	? $self->get('subscribed_by_default')
	: $self->get_app_default;
}

1;
