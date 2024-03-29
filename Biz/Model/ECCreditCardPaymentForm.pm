# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ECCreditCardPaymentForm;
use strict;
use Bivio::Base 'Model.ConfirmableForm';

my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_PM) = b_use('Type.ECPaymentMethod');

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field('ECCreditCardPayment.card_number' =>
        b_use('Type.ECCreditCardNumber')->TEST_NUMBER)
        unless $self->req->is_production;
    $self->set_defaults_from_user($self->req('auth_user_id'))
        if $self->ureq('auth_user_id');
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
            map('ECCreditCardPayment.' . $_, qw(
                card_number
                card_name
                card_zip
                card_first_name
                card_last_name
                card_city
                card_state
                card_country
                card_email
            )),
            {
                name => 'card_exp_month',
                type => 'Month',
                constraint => 'NOT_NULL',
            },
            {
                name => 'card_exp_year',
                type => 'YearWindow',
                constraint => 'NOT_NULL',
            },
            {
                name => 'card_street1',
                type => 'Address.street1',
                constraint => 'NONE',
            },
            {
                name => 'card_street2',
                type => 'Address.street2',
                constraint => 'NONE',
            },
        ],
        other => [
            'ECCreditCardPayment.card_address',
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

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field(
        'ECCreditCardPayment.card_address',
        join(' ', $self->get('card_street1') || '', $self->get('card_street2') || ()),
    );
    if ($self->get('ECCreditCardPayment.card_first_name')) {
        $self->internal_put_field(
            'ECCreditCardPayment.card_name',
            join(' ', $self->get('ECCreditCardPayment.card_first_name'), $self->get('ECCreditCardPayment.card_last_name')),
        );
    }
    return @res;
}

sub process_payment {
    my($proto, $form, $payment_info) = @_;
    # returns 1 on success, 0 if double clicked or error
    # <payment_info> should contain ECPayment values (service, amount, ...)
    return 0 if _possible_double_click($proto, $form, $payment_info->{amount});
    return $form->new_other('ECCreditCardPayment')->create({
        %{$form->get_model_properties('ECCreditCardPayment')},
        ec_payment_id => $form->new_other('ECPayment')->create({
            point_of_sale => b_use('Type.ECPointOfSale')->INTERNET,
            %$payment_info,
            method => $_PM->CREDIT_CARD,
            status => b_use('Type.ECPaymentStatus')->TRY_CAPTURE,
        })->get('ec_payment_id'),
    })->process_payment($form);
}

sub set_defaults_from_user {
    my($self, $user_id) = @_;
    my($user_realm) = $self->new_other('RealmOwner')->unauth_load_or_die({
        realm_id => $user_id,
    });
    $self->internal_put_field('ECCreditCardPayment.card_name' => $user_realm->get('display_name'));
    my($user) = $user_realm->get_model('User');
    $self->internal_put_field('ECCreditCardPayment.card_first_name' => $user->get('first_name'));
    $self->internal_put_field('ECCreditCardPayment.card_last_name' => $user->get('last_name'));
    my($address) = $self->new_other('Address');
    if ($address->unauth_load({
        realm_id => $user_id,
    })) {
        $self->internal_put_field('ECCreditCardPayment.card_zip' =>
            $address->get('zip'));
        foreach my $field (qw(city state country)) {
            $self->internal_put_field("ECCreditCardPayment.card_$field" => $address->get($field));
        }
        $self->internal_put_field(card_street1 => $address->get('street1'));
        $self->internal_put_field(card_street2 => $address->get('street2'));
    }
    my($email) = $self->new_other('Email');
    if ($email->unauth_load({
        realm_id => $user_id,
    })) {
        $self->internal_put_field('ECCreditCardPayment.card_email' => $email->get('email'));
    }
    return;
}

sub validate {
    my($self) = @_;
    _validate_credit_card_expiration($self);
    _validate_credit_card_type($self);
    return;
}

sub _possible_double_click {
    my($proto, $form, $amount) = @_;
    # A double click occurs if the creation_date_time of the most recent
    # payment is very new.
    return @{$form->new_other('ECPayment')->map_iterate(sub {
        my($payment) = @_;

        if ($_DT->compare($payment->get('creation_date_time'),
            # one minute ago
            $_DT->add_seconds($_DT->now, -1 * 60)) > 0) {
            $form->req->warn('ignoring OK, possible double-click');
            return 1;
        }
        return ();
    }, 'iterate_start', 'creation_date_time DESC', {
        amount => $amount,
        user_id => $form->req('auth_user_id'),
        method => $_PM->CREDIT_CARD,
    })} ? 1 : 0;
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
    b_die('unable to convert expiration date: ' . $err->get_short_desc)
        unless $exp_date;
    $self->internal_put_field('ECCreditCardPayment.card_expiration_date' =>
        $exp_date);
    $self->internal_put_error('ECCreditCardPayment.card_expiration_date' =>
        'CREDITCARD_EXPIRED')
        if $_D->compare($exp_date, $_D->local_today) < 0;
    return;
}

sub _validate_credit_card_type {
    my($self) = @_;
    return if $self->get_field_error('ECCreditCardPayment.card_number');
    $self->internal_put_error('ECCreditCardPayment.card_number' =>
        'CREDITCARD_UNSUPPORTED_TYPE')
        unless b_use('Type.ECCreditCardType')->is_supported_by_number(
            $self->get('ECCreditCardPayment.card_number'));
    return;
}

1;
