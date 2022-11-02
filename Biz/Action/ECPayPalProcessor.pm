# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::ECPayPalProcessor;
use strict;
use Bivio::Base 'Biz.Action';
use Business::PayPal::NVP ();
use IO::Socket ();
b_use('IO.Trace');

our($_TRACE);
Bivio::IO::Config->register(my $_CFG = {
    login => undef,
    password => undef,
    signature => undef,
    test_mode => 1,
});
my($_A) = b_use('Type.Amount');
my($_D) = b_use('Type.Date');
my($_ECCCT) = b_use('Type.ECCreditCardType');
my($_ECPS) = b_use('Type.ECPaymentStatus');

# DoDirectPayment
# PAYMENTACTION  => Sale
# IPADDRESS => 'xx.xx.xxx.xxxx'
# CREDITCARDTYPE => Visa|MasterCard|Discover|Amex
# ACCT => '4736656842918643',
# EXPDATE => 'MMYYYY',
# FIRSTNAME => 'TestFirst', (max 25)
# LASTNAME => 'TestLast', (max 25)
# AMT => '141.00', (must include 2 decimal places)
# CURRENCYCODE => USD|...
# DESC => ... (max 127)
# INVNUM => '12346',

# Error Response
# L_SEVERITYCODE0 => 'Error',
# L_LONGMESSAGE0 => 'This transaction cannot be processed. Please enter a valid credit card number and type.',
# L_ERRORCODE0 => '10527',
# L_SHORTMESSAGE0 => 'Invalid Data',
# ACK => 'Failure'

# Success Response
# TRANSACTIONID => '0W1644053X9353517',
# ACK => 'Success'

# RefundTransaction
# TRANSACTIONID
# REFUNDTYPE (Full|Partial)
# AMT (Partial only, don't set for Full)
# CURRENCYCODE (Partial only)
# NOTE (max 255)

# Success Response
# CURRENCYCODE => 'USD',
# REFUNDTRANSACTIONID => '58017159N42374400',
# ACK => 'Success'

# Error Response
# L_SEVERITYCODE0 => 'Error',
# L_LONGMESSAGE0 => 'This transaction has already been fully refunded',
# L_ERRORCODE0 => '10009',
# L_SHORTMESSAGE0 => 'Transaction refused',
# ACK => 'Failure'

sub execute_process {
    my($proto, $req) = @_;
    _process_payment($proto, $req->get('Model.ECPayment'));
    return;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub _args_for_method {
    my($proto, $payment, $method) = @_;
    my(@res) = $method eq 'DoDirectPayment'
        ? _payment($proto, $payment)
        : $method eq 'RefundTransaction'
            ? _refund($proto, $payment)
            : b_die('invalid paypal method: ', $method);
    _trace({@res}) if $_TRACE;
    return @res;
}

sub _payment {
    my($proto, $payment) = @_;
    my($cc_payment) = $payment->get_model('ECCreditCardPayment');
    my($user) = $payment->new_other('User')->unauth_load_or_die({
        user_id => $payment->get('user_id'),
    });
    my($ip) = $payment->ureq('client_addr');

    unless ($ip) {
        my($host) = $payment->req('UI.Facade')->get_value('http_host');
        $host =~ s/\:.*$//;
        $ip = IO::Socket::inet_ntoa((gethostbyname($host))[4]);
    }
    return (
        PAYMENTACTION  => 'Sale',
        IPADDRESS => $ip,
        CREDITCARDTYPE => $_ECCCT->get_by_number(
            $cc_payment->get('card_number'))->get_short_desc,
        ACCT => $cc_payment->get('card_number'),
        EXPDATE => sprintf('%02d%04d', $_D->get_parts(
            $cc_payment->get('card_expiration_date'), qw(month year))),
        FIRSTNAME => _trim($user->get('first_name'), 25),        
        LASTNAME => _trim($user->get('last_name'), 25),
        AMT => sprintf('%.02f', $payment->get('amount')),
        CURRENCYCODE => $payment->get('currency_name'),
        DESC => _trim($payment->get('description'), 127),
        INVNUM => $payment->get('ec_payment_id'),
    );
}

sub _process_payment {
    my($proto, $payment) = @_;
    return
        unless $payment->get('method')->eq_credit_card;
    unless ($_CFG->{login} && $_CFG->{password} && $_CFG->{signature}) {
        b_warn('Missing paypal payment gateway login configuration')
            if $payment->req->is_production;
        return;
    }
    my($method) = $payment->get('status')->get_paypal_type;
    unless ($method) {
        b_warn('Missing PayPal type for status: ', $payment->get('status'));
        return;
    }

    my($mode) = $_CFG->{test_mode} ? 'test' : 'live';
    my($pp) = Business::PayPal::NVP->new(
        branch => $mode,
        $mode => {
            user => $_CFG->{login},
            pwd  => $_CFG->{password},
            sig  => $_CFG->{signature},
        }
    );
    my($res) = {
        $pp->$method(_args_for_method($proto, $payment, $method)),
    };
    _trace($res) if $_TRACE;
    unless (%$res) {
        b_warn($method, ' failed: ', $pp->errors);
        return;
    }
    if ($res->{ACK} eq 'Success') {
        $payment->update({
            status => $payment->get('status')->get_success_state,
        });
    }
    else {
        b_warn($res);
        unless ($res->{L_ERRORCODE0} =~ /^(10102|10500|10501|10507|10509|10511|10523|10539|10544|10547)$/) {
            $payment->update({
                status => $_ECPS->DECLINED,
            });
        }
    }
    $payment->get_model('ECCreditCardPayment')->update({
        processed_date_time => b_use('Type.DateTime')->now,
        processor_response => $res->{L_LONGMESSAGE0} || $res->{ACK},
        $res->{TRANSACTIONID}
            ? (processor_transaction_number => $res->{TRANSACTIONID})
            : (),
    });
    return;
}

sub _refund {
    my($proto, $payment) = @_;
    b_die('invalid refund sign: ', $payment)
        unless $payment->get('amount') < 0;
    my($original_payment);
    my($transaction_number) = $payment->get_model('ECCreditCardPayment')
        ->get('processor_transaction_number');
    $payment->new_other('ECCreditCardPayment')->set_ephemeral->do_iterate(sub {
        my($cc) = @_;
        my($p) = $cc->new_other('ECPayment')->set_ephemeral
            ->unauth_load_or_die({
                ec_payment_id => $cc->get('ec_payment_id'),
            });
        if ($p->get('status')->eq_captured && $p->get('amount') > 0) {
            $original_payment = $p;
            return 0;
        }
        return 1;
    }, 'unauth_iterate_start', 'ec_payment_id ASC', {
        processor_transaction_number => $transaction_number,
    });
    b_die('missing refund original: ', $payment)
        unless $original_payment;
    my($is_partial_refund) = $_A->add($original_payment->get('amount'),
        $payment->get('amount')) > 0 ? 1 : 0;
    return (
        TRANSACTIONID => $transaction_number,
        REFUNDTYPE => $is_partial_refund ? 'Partial' : 'Full',
        $is_partial_refund ? (
            AMT => sprintf('%.02f', $_A->neg($payment->get('amount'))),
            CURRENCYCODE => $original_payment->get('currency_name'),
        ) : (),
        NOTE => _trim($payment->get('description'), 255),
    );
}

sub _trim {
    my($value, $size) = @_;
    return '' unless defined($value);
    return length($value) > $size
        ? substr($value, 0, $size)
        : $value;
}

1;
