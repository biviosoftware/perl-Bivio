# Copyright (c) 2008-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ECCreditCardRefundForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_A) = b_use('Type.Amount');
my($_D) = b_use('Type.Date');
my($_ECPS) = b_use('Type.ECPaymentStatus');

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field('ECPayment.amount' =>
	$self->req(qw(Model.ECPayment amount)));
    return;
}

sub execute_ok {
    my($self) = @_;
    my($payment) = $self->req('Model.ECPayment');
    my($cc_payment) = $payment->get_model('ECCreditCardPayment');
    my($values) = $payment->get_shallow_copy;
    $values->{amount} = $_A->neg($self->get('ECPayment.amount'));
    $values->{description} = _append_text(
	$self, $payment, 'description', ' Refund');
    $values->{status} = $_ECPS->TRY_CREDIT;
    $values->{remark} = "Refund for payment on "
	. $_D->to_string($payment->get('creation_date_time'));

    foreach my $f (qw(creation_date_time ec_payment_id)) {
	delete($values->{$f});
    }
    $payment->create($values);
    $cc_payment->create({
	%{$cc_payment->get_shallow_copy},
	ec_payment_id => $payment->get('ec_payment_id'),
	processor_response => '',
    })->process_payment($self);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    'ECPayment.amount',
	],
    });
}

sub validate {
    my($self) = @_;
    $self->validate_greater_than_zero('ECPayment.amount');
    $self->internal_put_error('ECPayment.amount' => 'NUMBER_RANGE')
	if $self->get('ECPayment.amount')
	    && $_A->compare($self->get('ECPayment.amount'),
		$self->req(qw(Model.ECPayment amount))) > 0;
    return;
}

sub _append_text {
    my($self, $model, $field, $text) = @_;
    my($value) = $model->get($field) || '';
    my($size) = $model->get_field_type($field)->get_width;

    if (length($value . $text) > $size) {
	$value = substr($value, 0, $size - length($text));
    }
    return $value . $text;
}

1;
