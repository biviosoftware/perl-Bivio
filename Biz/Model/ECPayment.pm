# Copyright (c) 2000-2002 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECPayment;
use strict;
use Bivio::Base 'Bivio::Biz::PropertyModel';
use Bivio::Type::DateTime;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    my($self, $new_values) = @_;
    my($req) = $self->get_request;
    $new_values->{realm_id} ||= $req->get('auth_id');
    $new_values->{user_id} ||= $req->get('auth_user_id');
    $new_values->{creation_date_time} ||= Bivio::Type::DateTime->now;
    $new_values->{description} = $new_values->{service}->get_short_desc
	unless defined($new_values->{description});
    return shift->SUPER::create(@_);
}

sub get_amount_sum {
    # Returns the sum of all payments in this realm.  Returns 0 if no payments
    # for this realm.
    my($self) = @_;
    return (Bivio::SQL::Connection->execute_one_row(
	'SELECT SUM(amount)
         FROM ec_payment_t
         WHERE realm_id = ?',
	[$self->get_request->get('auth_id')])
	|| [0])->[0];
}

sub internal_initialize {
    # none of the related fields are linked here
    # need to always preserve ECPayments, so deleting them
    # via cascade_delete() should always fail
    return {
        version => 1,
        table_name => 'ec_payment_t',
        columns => {
            ec_payment_id => ['PrimaryId', 'PRIMARY_KEY'],
	    # Which realm is using the service
            realm_id => ['PrimaryId', 'NOT_NULL'],
	    # Which realm paid for the service
            user_id => ['PrimaryId', 'NOT_NULL'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
            amount => ['Amount', 'NOT_NULL'],
            method => ['ECPaymentMethod', 'NOT_ZERO_ENUM'],
            status => ['ECPaymentStatus', 'NOT_NULL'],
	    description => ['Line', 'NOT_NULL'],
            remark => ['Text', 'NONE'],
	    salesperson_id => ['PrimaryId', 'NONE'],
	    service => ['ECService', 'NOT_NULL'],
	    point_of_sale => ['ECPointOfSale', 'NOT_NULL'],
        },
        auth_id => 'realm_id',
    };
}

sub unsafe_get_model {
    # Overridden to support getting the related ECSubscription,
    # ECCheckPayment or ECCreditCardPayment.
    my($self, $name) = @_;

    if ($name eq 'ECSubscription' || $name eq 'ECCheckPayment'
	|| $name eq 'ECCreditCardPayment') {

	my($model) =  $self->new_other($name);
	$model->unauth_load({
	    ec_payment_id => $self->get('ec_payment_id'),
        });
        return $model;
    }
    return shift->SUPER::unsafe_get_model(@_);
}

1;
