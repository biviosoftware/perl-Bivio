# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ECCreditCardPaymentForm;
use strict;
use base ('Bivio::Biz::Model::ConfirmableForm');
use Bivio::Biz::Action;
use Bivio::Type::Date;
use Bivio::Type::ECCreditCardType;
use Bivio::Type::ECPaymentMethod;
use Bivio::Type::ECPaymentStatus;
use Bivio::Type::ECPointOfSale;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = 'Bivio::Type::Date';
my($_DT) = 'Bivio::Type::DateTime';

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field('ECCreditCardPayment.card_number' =>
	Bivio::Type->get_instance('ECCreditCardNumber')->TEST_NUMBER)
        unless $self->req->is_production;

    return unless $self->req('auth_user_id');
    $self->internal_put_field('ECCreditCardPayment.card_name' =>
        $self->req(qw(auth_user display_name)));
    my($address) = $self->new_other('Address');

    if ($address->unauth_load({
        realm_id => $self->req('auth_user_id'),
    })) {
        $self->internal_put_field('ECCreditCardPayment.card_zip' =>
            $address->get('zip'));
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    map('ECCreditCardPayment.' . $_,
		qw(card_number card_name card_zip)),
	    {
		name => 'card_exp_month',
		type => 'ECCreditCardExpMonth',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'card_exp_year',
		type => 'ECCreditCardExpYear',
		constraint => 'NOT_NULL',
	    },
        ],
        other => [
            {
                name => 'processor_error',
                type => 'String',
                constraint => 'NONE',
            },
	    {
		name => 'ECCreditCardPayment.card_expiration_date',
		constraint => 'NONE',
	    },
        ],
    });
}

sub process_payment {
    my($proto, $form, $payment) = @_;
    # returns 1 on success, 0 if double clicked
    # <payment> should contain ECPayment values (service, amount, ...)
    return 0 if _possible_double_click($proto, $form, $payment->{amount});
    $form->new_other('ECCreditCardPayment')->create({
        %{$form->get_model_properties('ECCreditCardPayment')},
        ec_payment_id => $form->new_other('ECPayment')->create({
            point_of_sale => Bivio::Type::ECPointOfSale->INTERNET,
	    %$payment,
            method => Bivio::Type::ECPaymentMethod->CREDIT_CARD,
            status => Bivio::Type::ECPaymentStatus->TRY_CAPTURE,
        })->get('ec_payment_id'),
    });

    # pay in the user's realm
    my($req) = $form->get_request;
    $req->with_realm($req->get('auth_user'), sub {
        Bivio::Die->catch(sub {
            Bivio::Biz::Action->get_instance('ECCreditCardProcessor')
                ->execute_process($req);
            my($payment) = $req->get('Model.ECPayment');

            if ($payment->get('status')->equals_by_name('DECLINED')) {
                $form->internal_put_error(processor_error => 'NULL');
                $form->internal_put_field(processor_error =>
                    $payment->get_model('ECCreditCardPayment')
                        ->get('processor_response') || 'Card declined');
            }
        });
    });
    return 1;
}

sub validate {
    my($self) = @_;
    _validate_credit_card_expiration($self);
    _validate_credit_card_type($self);
    return;
}

sub _possible_double_click {
    my($proto, $form, $amount) = @_;
    # Returns true if the form was most likely double clicked.
    #
    # A double click occurs if the creation_date_time of the most recent
    # payment is very new.  The description must be the same.
    my($result) = 0;
    $form->new_other('ECPayment')->do_iterate(sub {
	my($payment) = @_;

	if ($_DT->compare($payment->get('creation_date_time'),
	    # one minute ago
	    $_DT->add_seconds($_DT->now, -1 * 60)) > 0
	    && $payment->get('amount') == $amount) {
	    $form->req->warn('ignoring OK, possible double-click');
	    $result = 1;
	}
	return 0;
    }, 'iterate_start', 'creation_date_time');
    return $result;
}

sub _validate_credit_card_expiration {
    my($self) = @_;
    return if $self->get_field_error('card_exp_year')
	|| $self->get_field_error('card_exp_month')
	|| !$self->unsafe_get('card_exp_month')
	|| !$self->unsafe_get('card_exp_year');
    my($month) = $self->get('card_exp_month')->as_int;
    my($year) = $self->get('card_exp_year')->as_int;
    my($day) = $_D->get_last_day_in_month($month, $year);

    my($exp_date, $err) = $_D->date_from_parts($day, $month, $year);

    Bivio::Die->throw_die('DIE', {
	message => 'unable to convert expiration date: '.$err->get_short_desc,
	entity => [$day, $month, $year],
    }) unless $exp_date;

    $self->internal_put_field('ECCreditCardPayment.card_expiration_date' =>
	$exp_date);
    $self->internal_put_error('ECCreditCardPayment.card_expiration_date',
	'CREDITCARD_EXPIRED')
	if $_D->compare($exp_date, $_D->local_today) < 0;
    return;
}

sub _validate_credit_card_type {
    my($self) = @_;
    return if $self->get_field_error('ECCreditCardPayment.card_number');
    $self->internal_put_error('ECCreditCardPayment.card_number' =>
        'CREDITCARD_UNSUPPORTED_TYPE')
	unless Bivio::Type::ECCreditCardType->is_supported_by_number(
	    $self->get('ECCreditCardPayment.card_number'));
    return;
}

1;
