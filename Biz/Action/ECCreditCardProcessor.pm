# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::ECCreditCardProcessor;
use strict;
use Bivio::Base 'Bivio::Biz::Action';
use Bivio::Die;
use Bivio::Ext::LWPUserAgent;
use Bivio::HTML;
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::Type::ECPaymentMethod;
use Bivio::Type::ECPaymentStatus;
use Bivio::Type::PrimaryId;
use Bivio::UI::Text;
use HTTP::Request ();

# C<Bivio::Biz::Action::ECCreditCardProcessor> manages e-commerce payments.
# For credit card payments, it accesses the Authorize.Net payment
# gateway to submit the transactions via ADC direct response method.
#
# Technical details can be found in
#   http://www.authorize.net/support/AIM_guide.pdf

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_GW_LOGIN);
my($_GW_PASSWORD);
my($_GW_TEST_MODE);
Bivio::IO::Config->register({
    login => undef,
    password => undef,
    test_mode => 1,
});

sub check_transaction_batch {
    # (self, Agent.Request) : undef
    # Download current batch from Authorize.Net and double-check
    # settled transactions. Ignores errors as those may be retried.
    # Format is one transaction per line (CR-LF), fields are TAB-separated.
    my($proto, $req) = @_;
#TODO: Recode this to new interface
    return;
    my($hreq) = HTTP::Request->new(
	POST => 'https://secure.authorize.net/Interface/minterface.dll?batchreport');
    $hreq->content_type('application/x-www-form-urlencoded');
    $hreq->content('x_Login='.$_GW_LOGIN.'&x_Password='.$_GW_PASSWORD.
            '&Action=DOWNLOAD&BATCHID=NULL');
    $hreq->referer(
	'https://' . Bivio::UI::Facade->get_value('http_host', $req));
    my($response) = Bivio::Ext::LWPUserAgent->new->request($hreq);
    my($payment) = Bivio::Biz::Model->new($req, 'ECPayment');
    foreach my $transaction (split(/\n/, $response->content)) {
        my(@fields) = split(/\t/, $transaction);
        my($status, $payment_id, $realm_id) = (@fields)[0,7,12];
#TODO: RJN: Shouldn't realm_id be required?
	unless (defined($status) && defined($payment_id)) {
	    Bivio::IO::Alert->warn('missing field values in: ',
		    \@fields);
	    next;
	}
	($payment_id) = Bivio::Type::PrimaryId->from_literal($payment_id);
	unless ($payment_id) {
	    Bivio::IO::Alert->warn('ignoring bad payment_id: ', \@fields);
	    next;
	}
        _trace('transaction data: ', \@fields) if $_TRACE;

        # Ignore payments we don't know about
        next unless $payment->unauth_load(ec_payment_id => $payment_id);

#TODO: Should the payment gateway status codes (1,2,3) be encapsulated?
        if ($status eq '1') {
            next if $payment->get('status')->is_approved;
            Bivio::IO::Alert->warn('fixing status of approved payment: ',
                    $payment_id);
            _update_status($proto, $payment, $status);
        }
	elsif ($status eq '2') {
            next if $payment->get('status')
                    == Bivio::Type::ECPaymentStatus->DECLINED;
            Bivio::IO::Alert->warn('fixing status of declined payment: ',
                    $payment_id);
            _update_status($proto, $payment, $status);
        }
	else {
	    # Ignore errors as they will be retried
            Bivio::IO::Alert->warn(
		$payment_id, ': failed request; transaction data: ', \@fields);
	}
    }
    return;
}

sub execute_process {
    # (self, Agent.Request) : boolean
    # Process credit card payment online by contacting the payment gateway
    # for the current ECPayment.
    my($proto, $req) = @_;
    _process_payment($proto, $req->get('Model.ECPayment'));
    return;
}

sub handle_config {
    # (proto, hash) : undef
    # login : string [undef]
    #
    # password : string [undef]
    #
    # test_mode : boolean [1]
    my(undef, $cfg) = @_;
    $_GW_LOGIN = $cfg->{login};
    $_GW_PASSWORD = $cfg->{password};
    $_GW_TEST_MODE = $cfg->{test_mode};
    return;
}

sub internal_get_additional_form_data {
    # (self, proto, Model.ECPayment) : string
    # Allow subclasses to provide additional form data for the payment processor.
    # Used by ECSecureSourceProcessor.
    my($proto, $payment) = @_;
    return '';
}

sub _process_payment {
    # (proto, Model.ECPayment) : undef
    # Send transaction data to the payment gateway and process results.
    # See http://secure.authorize.net/docs/developersguide.pml for
    # details of required field names and values.
    my($proto, $payment) = @_;
    return unless
	$payment->get('method') == Bivio::Type::ECPaymentMethod->CREDIT_CARD;

    unless ($_GW_LOGIN && $_GW_PASSWORD) {
	Bivio::IO::Alert->warn('Missing payment gateway login configuration');
	return;
    }
    my($hreq) = HTTP::Request->new(
	    POST => 'https://secure.authorize.net/gateway/transact.dll'
	   );
    $hreq->content_type('application/x-www-form-urlencoded');
    $hreq->content(_transact_form_data($proto, $payment));
    _trace($hreq) if $_TRACE;
    my($response) = Bivio::Ext::LWPUserAgent->new->request($hreq);
    my($response_string) = $response->as_string;
    _trace($response_string) if $_TRACE;
    Bivio::Die->die('request failed: ', $response_string)
	    unless $response->is_success;
#TODO: RJN: Need more error checking on responses from external sites.
#      @details is just assumed to be correct later on.
    my($result_code, @details) = split(',', $response->content);
    Bivio::Die->die('cannot parse result string: ', $response->content)
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
    my(undef, undef, undef, undef, $m, $y) = Bivio::Type::Date->to_parts(
	$cc_payment->get('card_expiration_date'));
    my($exp_date) = sprintf('%02d/%04d', $m, $y);
    my($test_request) = '';
    my($card_number);
    my($amount);
    if ($_GW_TEST_MODE) {
        $test_request = '&x_Test_Request=TRUE';
        $card_number = '4222222222222';
        # Amount field used to trigger response:
        # 1=Approved, 2=Declined, 3=Error
        $amount = int($payment->get('amount'));
	# All other amounts are approved
	$amount = 1 if $amount < 1 || $amount > 3;
    } else {
        $card_number = $cc_payment->get('card_number');
	# Amounts are always positiv.
        $amount = Bivio::Type::Amount->abs($payment->get('amount'));
    }
    return 'x_ADC_Delim_Data=TRUE'.
            '&x_ADC_URL=FALSE'.
            '&x_Version=3.0'.
            '&x_Login='.$_GW_LOGIN.
            '&x_Password='.$_GW_PASSWORD.
            '&x_Type='.$payment->get('status')->get_authorize_net_type.
	    (defined($cc_payment->get('processor_transaction_number'))
		? '&x_Trans_ID='
		    .$cc_payment->get('processor_transaction_number')
		: '').
            '&x_Amount='.$amount.
            '&x_Card_Num='.$card_number.
            '&x_Description='.$payment->get('description').
            '&x_Exp_Date='.$exp_date.
            '&x_Cust_ID='.$payment->get('realm_id').
            '&x_Invoice_Num='.$payment->get('ec_payment_id').
	    ($cc_payment->get('card_zip') =~ /\S/
		? ('&x_Zip='.Bivio::HTML->escape_uri(
		    $cc_payment->get('card_zip')))
		: '') .
            $proto->internal_get_additional_form_data($payment).
            $test_request;
}

sub _update_status {
    # (proto, Model.ECPayment, string, array_ref) : undef
    # Update payment status given the gateway's result code.
    # Look at Authorize.Net developer's guide, app. C, for a list of error codes.
    my($proto, $payment, $result_code, $details) = @_;
    my($error_code, $msg, $processor_transaction_number) =
	$details ? (@$details)[1,2,5] : (undef, undef, undef);
    my($status);
    if ($result_code eq '1') {
	$status = $payment->get('status')->get_success_state;
    }
    elsif ($result_code eq '2') {
	$status = Bivio::Type::ECPaymentStatus->DECLINED;
    }
    elsif ($result_code eq '3') {
        # Error. Keep existing status except for the following fatal cases
        $status = $error_code =~ /^([5-9]|1[079]|2[01235678]|3[5])$/
	    ? Bivio::Type::ECPaymentStatus->FAILED
	    : $payment->get('status');
	Bivio::IO::Alert->warn($details, ': failed request: ', $payment);
    }
    else {
        Bivio::Die->throw_die('DIE', {
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
	processed_date_time => Bivio::Type::DateTime->now,
	processor_response => $msg,
	processor_transaction_number => $processor_transaction_number,
    });
    _warn_declined($proto, $payment)
	if $status->is_bad;
    return;
}

sub _warn_declined {
    # (proto, Model.ECPayment) : undef
    # Writes a warning about a declined or failed payment.
    my($proto, $payment) = @_;
    my($req) = $payment->get_request;
    $req->warn(
	$payment->get('status')->get_name,
	' payment for ',
	$req->get('auth_realm')->get('owner_name'),
    );
    return;
}

1;
