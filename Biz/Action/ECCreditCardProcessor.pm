# Copyright (c) 2002-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::ECCreditCardProcessor;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::IO::Trace;
use HTTP::Request ();

# C<Bivio::Biz::Action::ECCreditCardProcessor> manages e-commerce payments.
# For credit card payments, it accesses the Authorize.Net payment
# gateway to submit the transactions via ADC direct response method.
#
# Technical details can be found in
#   http://www.authorize.net/support/AIM_guide.pdf

my($_ECPS) = b_use('Type.ECPaymentStatus');
my($_CN) = b_use('Type.CurrencyName');
my($_HTML) = b_use('Bivio.HTML');
our($_TRACE);
my($_CURRENCIES);
my($_C) = b_use('IO.Config');
my($_FAKE_LOGIN) = '<fake>';
$_C->register(my $_CFG = {
    Bivio::IO::Config->NAMED => {
	login => $_FAKE_LOGIN,
	password => 'x',
    },
    test_mode => 1,
});

sub execute_process {
    # Process credit card payment online by contacting the payment gateway
    # for the current ECPayment.
    my($proto, $req) = @_;
    my($payment) = $req->get('Model.ECPayment');
    my($cn) = $payment->get('currency_name');
    b_die($cn, ': invalid currency for payment ', $payment, '; valid=', $_CURRENCIES)
	unless my $cfg = $_C->unsafe_get($cn);
    _process_payment($proto, $cfg, $payment);
    return;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    $_CURRENCIES = [sort(grep($_CN->is_valid($_), keys(%$_CFG)))];
    unless (@$_CURRENCIES) {
        if ($_CFG->{login} && $_CFG->{password}) {
            #DEPRECATED
            $_CFG->{$_CN->get_default} = {
                login => $_CFG->{login},
                password => $_CFG->{password},
            };
        }
        elsif ($_C->is_production) {
            # Don't output config, because contains passwords
            b_die('no currencies defined in ECCreditCardProcessor config');
        }
        else {
            # test or dev
            $_CFG->{$_CN->get_default} = {
                login => $_FAKE_LOGIN,
                password => 'x',
            };
        }
    }
    return;
}

sub internal_get_additional_form_data {
    # (self, proto, Model.ECPayment) : string
    # Allow subclasses to provide additional form data for the payment
    # processor.
    # Used by ECSecureSourceProcessor.
    my($proto, $payment) = @_;
    return [];
}

sub is_accepted_currency {
    my(undef, $value) = @_;
    return 0
        unless $value;
    return grep(
        $value eq $_,
        @{$_CURRENCIES || b_die('CURRENCIES not initialized')},
    ) ? 1 : 0;
}

sub _process_payment {
    # Send transaction data to the payment gateway and process results.
    # See http://secure.authorize.net/docs/developersguide.pml for
    # details of required field names and values.
    my($proto, $cfg, $payment) = @_;
    return
	unless $payment->get('method')->eq_credit_card;

    unless ($cfg->{login} && $cfg->{password}) {
	b_warn('Missing payment gateway login configuration')
	    if $payment->req->is_production;
	return;
    }
    my($result_code, @details);
    if ($_CFG->{test_mode} && $cfg->{login} eq $_FAKE_LOGIN) {
        $result_code = (_transact_form_data($proto, $cfg, $payment) =~ /x_Amount=(\d+)/)[0];
        b_info('FAKE: not making a request');
    }
    else {
        my($site) = 'secure';
        if ($_CFG->{test_mode}) {
            b_info('TEST: using test.authorize.net');
            $site = 'test';
        }
        my($hreq) = HTTP::Request->new(
            POST => "https://$site.authorize.net/gateway/transact.dll");
        $hreq->content_type('application/x-www-form-urlencoded');
        $hreq->content(_transact_form_data($proto, $cfg, $payment));
        _trace($hreq) if $_TRACE;
        my($response) = b_use('Ext.LWPUserAgent')->new->request($hreq);
        my($response_string) = $response->as_string;
        _trace($response_string) if $_TRACE;
        b_die('request failed: ', $response_string)
            unless $response->is_success;
#TODO: RJN: Need more error checking on responses from external sites.
#      @details is just assumed to be correct later on.
        ($result_code, @details) = split(',', $response->content);
        b_die('cannot parse result string: ', $response->content)
            unless defined($result_code);
    }
    _update_status($proto, $payment, $result_code, \@details);
    return;
}

sub _transact_form_data {
    # Prepare payment transaction form data for capturing the amount.
    # Will add x_Test_Request=TRUE if in test mode.
    my($proto, $cfg, $payment) = @_;
    my($cc_payment) = $payment->get_model('ECCreditCardPayment');
    my(undef, undef, undef, undef, $m, $y) = b_use('Type.Date')
	->to_parts($cc_payment->get('card_expiration_date'));
    my($exp_date) = sprintf('%02d/%04d', $m, $y);
    my($card_number);
    my($amount);

    if ($_CFG->{test_mode}) {
        $card_number = '4222222222222';
        # Amount field used to trigger response:
        # 1=Approved, 2=Declined, 3=Error
        $amount = int($payment->get('amount'));
	# All other amounts are approved
	$amount = 1 if $amount < 1 || $amount > 3;
    } else {
        $card_number = $cc_payment->get('card_number');
	# Amounts are always positive
        $amount = b_use('Type.Amount')->abs($payment->get('amount'));
    }
    return join(
        '&',
        map(
            join('=', @$_),
            [x_ADC_Delim_Data => 'TRUE'],
            [x_ADC_URL => 'FALSE'],
            [x_Version => '3.0'],
            [x_Login => $cfg->{login}],
            [x_Password => $cfg->{password}],
            [x_Type => $payment->get('status')->get_authorize_net_type],
            defined($cc_payment->get('processor_transaction_number'))
                ? [x_Trans_ID => $cc_payment->get('processor_transaction_number')]
                : (),
            [x_Amount => $amount],
            [x_Card_Num => $card_number],
            [x_Description => $payment->get('description')],
            [x_Exp_Date => $exp_date],
            [x_Cust_ID => $payment->get('realm_id')],
            [x_Invoice_Num => $payment->get('ec_payment_id')],
            @{_optional_fields($cc_payment)},
            $_CFG->{test_mode}
                ? [x_Test_Request => 'TRUE']
                : (),
            @{$proto->internal_get_additional_form_data($payment)},
        ),
    );
}

sub _optional_fields() {
    my($cc) = @_;
    my($res) = [];
    for my $x (
        # these are the size restrictions
        [email => 255],
        [first_name => 50],
        [last_name => 50],
        [address => 60],
        [city => 40],
        [state => 40],
        [zip => 20],
        [country => 2],
    ) {
        my($f, $l) = @$x;
        my($v) = $cc->get("card_$f");
        if (!defined($v) || $v !~ /\S/) {
            next;
        }
        if ($f eq 'email') {
            # When we supply an email, the merchant interface automatically sends
            # a message to the user. This turns it off.
            push(
                @$res,
                ['x_email_customer', 'FALSE'],
            );
        } else {
            # All other fields can't have symbols
            $v =~ s/\s+/ /g;
            $v =~ s/[^a-z0-9 ]//ig;
            if (!length($v)) {
                # Let the credit card processor return the error
                next;
            }
        }
        push(
            @$res,
            ["x_$f" => $_HTML->escape_uri(substr($v, 0, $l))],
        );
    }
    return $res;
}

sub _update_status {
    # (proto, Model.ECPayment, string, array_ref) : undef
    # Update payment status given the gateway's result code.
    # Look at Authorize.Net developer's guide, app. C, for a list of error codes.
    my($proto, $payment, $result_code, $details) = @_;
    my($error_code, $msg, $txn) =
	$details ? (@$details)[1,2,5] : (undef, undef, undef);
    my($status);
    if ($result_code eq '1') {
	$status = $payment->get('status')->get_success_state;
    }
    elsif ($result_code eq '2') {
	$status = $_ECPS->DECLINED;
	b_warn($status, ': ', $details, ' ', $payment);
    }
    elsif ($result_code eq '3') {
        $status = $_ECPS->FAILED;
	b_warn($status, ': ', $details, ' ', $payment);
    }
    else {
        b_die({
	    message => "unknown processor result code: $result_code",
	    entity => $payment->unsafe_get('ec_payment_id'),
	    details => $details,
	});
	# DOES NOT RETURN
    }
    $payment->update({
	status => $status,
    });
    $payment->get_model('ECCreditCardPayment')->update({
	processed_date_time => b_use('Type.DateTime')->now,
	processor_response => $msg,
	processor_transaction_number => $txn,
    });
    b_warn($payment->get('status')->get_name,
	' payment for ', $payment->req(qw(auth_realm owner_name)),
    ) if $status->is_bad;
    return;
}

1;
