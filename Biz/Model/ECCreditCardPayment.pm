# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ECCreditCardPayment;
use strict;
use Bivio::Base 'Biz.PropertyModel';

my($_A) = b_use('Type.Amount');

sub create {
    my($self, $new_values) = @_;
    $new_values->{realm_id} ||= $self->req('auth_id');
    return shift->SUPER::create(@_);
}

sub get_payment_processor {
    my($self) = @_;
    return b_use('Action.ECCreditCardProcessor');
}

sub internal_initialize {
    # none of the related fields are linked here
    # need to always preserve ECPayments, so deleting them
    # via cascade_delete() should always fail
    return {
        version => 1,
        table_name => 'ec_credit_card_payment_t',
        columns => {
            ec_payment_id => ['ECPayment.ec_payment_id', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            processed_date_time => ['DateTime', 'NONE'],
            processor_response => ['Text', 'NONE'],
            processor_transaction_number => ['Name', 'NONE'],
            # May be generated from first/last
            card_number => ['ECCreditCardNumber', 'NOT_NULL'],
            card_expiration_date => ['Date', 'NOT_NULL'],
            card_name => ['Line', 'NOT_NULL'],
            card_zip => ['Name', 'NOT_NULL'],
            card_first_name => ['Name', 'NONE'],
            card_last_name => ['Name', 'NONE'],
            card_address => ['Line', 'NONE'],
            card_city => ['Name', 'NONE'],
            # Only if US or CA
            card_state => ['Name', 'NONE'],
            card_country => ['Country', 'NONE'],
            card_email => ['Email', 'NONE'],
        },
        auth_id => 'realm_id',
        other => [['ec_payment_id', 'ECPayment.ec_payment_id']],
    };
}

sub is_accepted_currency {
    # POSIT: payment processor is static, get_payment_processor is
    return shift->get_payment_processor->is_accepted_currency(@_);
}

sub process_payment {
    my($self, $form) = @_;
    $self->req->with_realm($self->req('auth_user'), sub {
        Bivio::Die->catch(sub {
            $self->get_payment_processor->execute_process($self->req);
            my($payment) = $self->req('Model.ECPayment');

            if ($payment->get('status')->is_bad) {
                $form->internal_put_error(processor_error => 'NULL');
                $form->internal_put_field(processor_error =>
                    $payment->get_model('ECCreditCardPayment')
                        ->get('processor_response') || 'Card declined');
            }
            else {
                b_info('credit card processed: ',
                    join(' ',
                         $payment->get(qw(realm_id user_id currency_name)),
                         $_A->to_literal($payment->get('amount')),
                    ),
                );
            }
        });
    });
    return $form->in_error ? 0 : 1;
}

1;
