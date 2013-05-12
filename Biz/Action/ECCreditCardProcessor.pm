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

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ECPS) = b_use('Type.ECPaymentStatus');
our($_TRACE);
Bivio::IO::Config->register(my $_CFG = {
    login => undef,
    password => undef,
    test_mode => 1,
});

sub execute_process {
    # (self, Agent.Request) : boolean
    # Process credit card payment online by contacting the payment gateway
    # for the current ECPayment.
    my($proto, $req) = @_;
    my($payment) = $req->get('Model.ECPayment');
    b_die('invalid currency, expect USD: ', $payment)
	unless $payment->get('currency_name') eq 'USD';
    _process_payment($proto, $payment);
    return;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
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

sub _process_payment {
    # (proto, Model.ECPayment) : undef
    # Send transaction data to the payment gateway and process results.
    # See http://secure.authorize.net/docs/developersguide.pml for
    # details of required field names and values.
    my($proto, $payment) = @_;
    return
	unless $payment->get('method')->eq_credit_card;

    unless ($_CFG->{login} && $_CFG->{password}) {
	b_warn('Missing payment gateway login configuration')
	    if $payment->req->is_production;
	return;
    }
    my($hreq) = HTTP::Request->new(
	POST => 'https://secure.authorize.net/gateway/transact.dll');
    $hreq->content_type('application/x-www-form-urlencoded');
    $hreq->content(_transact_form_data($proto, $payment));
    _trace($hreq) if $_TRACE;
    my($response) = b_use('Ext.LWPUserAgent')->new->request($hreq);
    my($response_string) = $response->as_string;
    _trace($response_string) if $_TRACE;
    b_die('request failed: ', $response_string)
	unless $response->is_success;
#TODO: RJN: Need more error checking on responses from external sites.
#      @details is just assumed to be correct later on.
    my($result_code, @details) = split(',', $response->content);
    b_die('cannot parse result string: ', $response->content)
	unless defined($result_code);
    _update_status($proto, $payment, $result_code, \@details);
    return;
}

sub _transact_form_data {
    # (proto, Model.ECPayment) : string
    # Prepare payment transaction form data for capturing the amount.
    # Will add x_Test_Request=TRUE if in test mode.
    my($proto, $payment) = @_;
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
	# Amounts are always positiv.
        $amount = b_use('Type.Amount')->abs($payment->get('amount'));
    }
    return join('&', map(join('=', @$_),
        [x_ADC_Delim_Data => 'TRUE'],
        [x_ADC_URL => 'FALSE'],
	[x_Version => '3.0'],
	[x_Login => $_CFG->{login}],
        [x_Password => $_CFG->{password}],
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
	$cc_payment->get('card_zip') =~ /\S/
	    ? [x_Zip => b_use('Bivio::HTML')
	        ->escape_uri($cc_payment->get('card_zip'))]
	    : (),
        $_CFG->{test_mode}
	    ? [x_Test_Request => 'TRUE']
	    : (),
	@{$proto->internal_get_additional_form_data($payment)},
    ));
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
        # Error. Keep existing status except for the following fatal cases
        $status = $error_code =~ /^([5-9]|1[079]|2[01235678]|3[5])$/
	    ? $_ECPS->FAILED
	    : $payment->get('status');
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
