# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserRealmSubscription;
use strict;
use Bivio::Base 'Model.RealmBase';
b_use('IO.ClassLoaderAUTOLOAD');


sub create {
    my($self, $values) = @_;
    $self->internal_set_default_values($values);
    $values->{is_subscribed} = $self->new_other('UserDefaultSubscription')
        ->user_default_subscription_status(
            $values->{user_id}, $values->{realm_id})
        unless defined($values->{is_subscribed});
    return shift->SUPER::create(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'user_realm_subscription_t',
        columns => {
            $self->USER_ID_FIELD => [qw(User.user_id PRIMARY_KEY)],
            $self->REALM_ID_FIELD => [$self->REALM_ID_FIELD_TYPE, 'PRIMARY_KEY'],
            is_subscribed => [qw(Boolean NOT_NULL)],
            modified_date_time => [qw(DateTime NOT_NULL)],
        },
    });
}

1;
