# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECSubscription;
use strict;
use Bivio::Base 'Bivio::Biz::PropertyModel';

# C<Bivio::Biz::Model::ECSubscription> holds data about a particular
# service subscription. The subscription can be running or expired, depending
# on its end date.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_INFINITE_END_DATE);
sub INFINITE_END_DATE {
    # Needs to be a bit less than max for the software to work
    return $_INFINITE_END_DATE
	||= Bivio::Type::Date ->add_days(Bivio::Type::Date->get_max, -366);
}

#=IMPORTS
use Bivio::Type::Date;
use Bivio::Type::ECRenewalState;

#=VARIABLES
my($_D) = 'Bivio::Type::Date';

sub create {
    my($self, $values) = @_;
    $values->{realm_id} ||= $self->get_request->get('auth_id');
    $values->{renewal_state} ||= Bivio::Type::ECRenewalState->OK;
    return $self->SUPER::create($values);
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
