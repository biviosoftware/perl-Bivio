# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECSubscription;
use strict;
use Bivio::Base 'Model.RealmBase';

# C<Bivio::Biz::Model::ECSubscription> holds data about a particular
# service subscription. The subscription can be running or expired, depending
# on its end date.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');

sub INFINITE_END_DATE {
    return $_D->add_days($_D->get_max, -366);
}

sub create {
    my($self, $values) = @_;
    $values->{renewal_state} ||= $self->use('Type.ECRenewalState')->OK;
    return shift->SUPER::create(@_);
}

sub internal_initialize {
    return {
        version => 1,
        table_name => 'ec_subscription_t',
        columns => {
	    ec_payment_id => ['ECPayment.ec_payment_id', 'PRIMARY_KEY'],
            realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
            start_date => ['Date', 'NOT_NULL'],
            end_date => ['Date', 'NOT_NULL'],
	    renewal_state => ['ECRenewalState', 'NOT_ZERO_ENUM'],
        },
        auth_id => 'realm_id',
	other => [['ec_payment_id', 'ECPayment.ec_payment_id']],
    };
}

sub is_active {
    my($self) = @_;
    my($today) = $_D->local_today;
    return $_D->compare($today, $self->get('start_date')) >= 0
	&& $_D->compare($today, $self->get('end_date')) <= 0 ? 1 : 0;
}

sub is_infinite {
    # Returns true if the subscription is infinite.
    my($self) = @_;
    return $self->get('end_date') eq $self->INFINITE_END_DATE ? 1 : 0;
}

sub make_infinite {
    # Updates to an infinite subscription.
    my($self) = @_;
    return $self->update({end_date => $self->INFINITE_END_DATE});
}

1;
