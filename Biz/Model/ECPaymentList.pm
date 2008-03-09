# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECPaymentList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RO) = __PACKAGE__->use('Model.RealmOwner');

sub format_name {
    my($self) = shift;
    return $_RO->format_name($self, 'RealmOwner.', @_);
}

sub internal_initialize {
    # (self) : hash_ref
    return {
        version => 2,
	can_iterate => 1,
        primary_key => ['ECPayment.ec_payment_id'],
        auth_id => ['ECPayment.realm_id'],
        order_by => [qw(
            ECPayment.creation_date_time
            RealmOwner.name
            ECPayment.amount
            ECPayment.method
            ECPayment.status
            ECCreditCardPayment.processed_date_time
        )],
        other => [
            'RealmOwner.display_name',
            [qw(ECPayment.user_id RealmOwner.realm_id)],
	    [qw{ECPayment.ec_payment_id ECSubscription.ec_payment_id(+)}],
	    [qw{ECPayment.ec_payment_id ECCheckPayment.ec_payment_id(+)}],
	    [qw{ECPayment.ec_payment_id ECCreditCardPayment.ec_payment_id(+)}],
            qw(
            ECPayment.user_id
            ECPayment.description
            ECPayment.remark
            ECPayment.salesperson_id
            ECPayment.service
            ECPayment.point_of_sale
            ECSubscription.start_date
            ECSubscription.end_date
            ECSubscription.renewal_state
            ECCheckPayment.check_number
            ECCheckPayment.institution
            ECCreditCardPayment.processor_response
            ECCreditCardPayment.processor_transaction_number
            ECCreditCardPayment.card_expiration_date
            ECCreditCardPayment.card_name
            ECCreditCardPayment.card_zip
       )],
    };
}

1;
