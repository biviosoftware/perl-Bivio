# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECPayment;
use strict;
$Bivio::Biz::Model::ECPayment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ECPayment::VERSION;

=head1 NAME

Bivio::Biz::Model::ECPayment - handle payments for premium services

=head1 SYNOPSIS

    use Bivio::Biz::Model::ECPayment;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::ECPayment::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ECPayment> manages e-commerce payments.
For credit card payments, it accesses the Authorize.Net payment
gateway to submit the transactions via ADC direct response method.

Technical details can be found in
  http://secure.authorize.net/docs/developersguide.pml

TODO: Should payment gateway code go into another module??

=cut

#=IMPORTS
use Bivio::IO::Config;
use HTTP::Request;
use LWP::UserAgent;
use Bivio::IO::Config;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_USER_AGENT);
my($_GW_LOGIN);
my($_GW_PASSWORD);
my($_GW_TEST_MODE);
Bivio::IO::Config->register({
    Bivio::IO::Config->NAMED => {
        login => undef,
        password => undef,
        test_mode => 1,
    },
});

=head1 METHODS

=cut

=for html <a name="check_transaction_batch"></a>

=head2 check_transaction_batch(Bivio::Agent::Request req)

Download current batch from Authorize.Net and double-check
settled transactions. Ignores errors as those may be retried.
Format is one transaction per line (CR-LF), fields are TAB-separated.

TODO: Should the payment gateway status codes (1,2,3) be encapsulated?

=cut

sub check_transaction_batch {
    my($proto, $req) = @_;
    _setup_user_agent();
    my($hreq) = HTTP::Request->new(
	    POST => 'https://secure.authorize.net/Interface/minterface.dll?batchreport'
	   );
    $hreq->content_type('application/x-www-form-urlencoded');
    $hreq->content('x_Login='.$_GW_LOGIN.'&x_Password='.$_GW_PASSWORD.
            '&Action=DOWNLOAD&BATCHID=NULL');
    my($response) = $_USER_AGENT->request($hreq);
    foreach my $transaction (split(/\n/, $response->content)) {
        my(@fields) = split(/\t/, $transaction);
        my($status, $payment_id, $realm_id) = (@fields)[0,7,12];
        Bivio::IO::Alert->warn('missing field values in: ',
                join(',', @fields)), next unless
                        defined($status) && defined($payment_id);
        # clear credit card field
        $fields[5] = '';
        _trace('transaction data: ', join(',', @fields));
        # Skip errors as they will be retried if not fatal
        $status =~ /^[12]$/ || next;
        my($payment) =
                $proto->new($req)->unauth_load(ec_payment_id => $payment_id);
        Bivio::IO::Alert->warn('cannot load payment: ', $payment_id)
                    unless defined($payment);
        if ($status eq '1') {
            next if $payment->get('status')->is_approved;
            Bivio::IO::Alert->warn('fixing status of approved payment: ',
                    $payment_id);
            $payment->_update_status($status);
        } elsif ($status eq '2') {
            next if $payment->get('status')
                    == Bivio::Type::ECPaymentStatus::DECLINED();
            Bivio::IO::Alert->warn('fixing status of declined payment: ',
                    $payment_id);
            $payment->_update_status($status);
        }
    }
    return;
}

=for html <a name="execute_process"></a>

=head2 execute_process(Bivio::Agent::Request req) : boolean

Process credit card payment online by contacting the payment gateway.

=cut

sub execute_process {
    my($proto, $req) = @_;

    my($payment) = $req->unsafe_get('Bivio::Biz::Model::ECPayment');
    $payment = Bivio::Biz::Model::ECPayment->new($req)->load_from_request
            unless defined($payment);
    $payment->process_payment($req);
#TODO: This is kinda neat, but maybe too much of a hack?
    my($buffer) = $payment->get('processor_response');
    $req->get('reply')->set_output(\$buffer);
    return;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item login : string [undef]

=item password : string [undef]

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_GW_LOGIN = $cfg->{login};
    $_GW_PASSWORD = $cfg->{password};
    $_GW_TEST_MODE = $cfg->{test_mode};
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref


=cut

sub internal_initialize {
    return {
        version => 1,
        table_name => 'ec_payment_t',
        columns => {
            ec_payment_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            user_id => ['PrimaryId', 'NOT_NULL'],
            creation_date_time => ['DateTime', 'NOT_NULL'],
            payment_type => ['ECPayment', 'NOT_ZERO_ENUM'],
            amount => ['Amount', 'NOT_NULL'],
            method => ['ECPaymentMethod', 'NOT_ZERO_ENUM'],
            ec_subscription_id => ['PrimaryId', 'NONE'],
            ec_subscription_start_date => ['Date', 'NONE'],
            ec_subscription_period => ['DateInterval', 'NONE'],
            status => ['ECPaymentStatus', 'NOT_NULL'],
            processed_date_time => ['DateTime', 'NONE'],
            processor_response => ['Text', 'NONE'],
            transaction_id => ['Name', 'NONE'],
            credit_card_number => ['CreditCardNumber', 'NONE'],
            credit_card_expiration_date => ['Date', 'NONE'],
            credit_card_name => ['Line', 'NONE'],
            credit_card_zip => ['Name', 'NONE'],
            remark => ['Text', 'NONE'],
        },
        auth_id => 'realm_id',
    };
}

=for html <a name="process_payment"></a>

=head2 process_payment(Bivio::Agent::Request req)

Send transaction data to the payment gateway and process results.
See http://secure.authorize.net/docs/developersguide.pml for
details of required field names and values.

=cut

sub process_payment {
    my($self) = @_;
    my($properties) = $self->internal_get;
    return unless
            $properties->{method} == Bivio::Type::ECPaymentMethod::CREDIT_CARD();
    _setup_user_agent();
    my($hreq) = HTTP::Request->new(
	    POST => 'https://secure.authorize.net/gateway/transact.dll'
	   );
    $hreq->content_type('application/x-www-form-urlencoded');
    $hreq->content(_transact_form_data($self));
    _trace($hreq) if $_TRACE;
    my($response) = $_USER_AGENT->request($hreq);
    my($response_string) = $response->as_string;
    _trace($response_string) if $_TRACE;
#TODO: die message will contain login/password. OK?
    Bivio::Die->die('request failed: ', $hreq->as_string)
		unless $response->is_success;
    _trace('RESULT=', $response->content) if $_TRACE;
    my($result_code, @details) = split(',', $response->content);
    Bivio::Die->die('cannot parse result string: ', $response->content)
		unless defined($result_code);
    _update_status($self, $result_code, @details);
    return;
}

#=PRIVATE METHODS

# _setup_user_agent()
#
# Create a LWP user agent. Read proxy configuration from environment
# variable <I>http_proxy.
#
sub _setup_user_agent {
    unless (defined($_USER_AGENT)) {
        $_USER_AGENT = LWP::UserAgent->new;
        $_USER_AGENT->env_proxy;
        Bivio::Die->die('Missing payment gateway login configuration')
                    unless defined($_GW_LOGIN) and defined($_GW_PASSWORD);
    }
    return;
}

# _transact_form_data(self) : string
#
# Prepare payment transaction form data for capturing the amount.
# Will add x_Test_Request=TRUE if in test mode.
#
sub _transact_form_data {
    my($self) = @_;
    my($properties) = $self->internal_get;

    my(undef, undef, undef, undef, $m, $y) = Bivio::Type::Date->to_parts(
            $properties->{credit_card_expiration_date});
    my($exp_date) = sprintf('%02d/%04d', $m, $y);
    my($test_request) = '';
    my($credit_card_number);
    my($amount);
    if ($_GW_TEST_MODE) {
        $test_request = '&x_Test_Request=TRUE';
        $credit_card_number = '4222222222222';
        # Amount field used to trigger response:
        # 1=Approved, 2=Declined, 3=Error
        $amount = 1;
    } else {
#TODO: Need to replace with real credit card implementation
        $credit_card_number = $properties->{credit_card_number};
        $amount = $properties->{amount};
    }
    my($transaction_id) = $properties->{transaction_id} ?
            '&x_Trans_ID='.$properties->{transaction_id} : '';
    return 'x_ADC_Delim_Data=TRUE'.
            '&x_ADC_URL=FALSE'.
            '&x_Version=3.0'.
            '&x_Login='.$_GW_LOGIN.
            '&x_Password='.$_GW_PASSWORD.
            '&x_Type='.Bivio::Type::ECPaymentStatus
                    ->get_authorize_net_type($properties->{status}).
            $transaction_id.
            '&x_Amount='.$amount.
            '&x_Card_Num='.$credit_card_number.
            '&x_Exp_Date='.$exp_date.
            '&x_Cust_ID='.$properties->{realm_id}.
            '&x_Invoice_Num='.$properties->{ec_payment_id}.
            $test_request;
}

# _update_status(self, string result_code, string subcode, string error_code, array details)
#
# Update payment status given the gateway's result code.
# Look at Authorize.Net developer's guide, app. C, for a list of error codes.
#
#TODO: Need to send e-mail to user. Or a Notice?
#
sub _update_status {
    my($self, $result_code, @details) = @_;
    my($now) = Bivio::Type::DateTime->now;
    my($error_code, $msg, $transaction_id) = (@details)[1,2,5];
    if ($result_code eq '1') {
        $self->update({
            status => Bivio::Type::ECPaymentStatus->get_success_state(
                   $self->get('status')),
            processed_date_time => $now,
            processor_response => $msg,
            transaction_id => $transaction_id,
        });
    } elsif ($result_code eq '2') {
        $self->update({
            status => Bivio::Type::ECPaymentStatus::DECLINED(),
            processed_date_time => $now,
            processor_response => $msg,
            transaction_id => $transaction_id,
        });
    } elsif ($result_code eq '3') {
        $self->update({
            processed_date_time => $now,
            processor_response => $msg,
            transaction_id => $transaction_id,
        });
        # Error. Keep existing status except for the following fatal cases
        return unless $error_code =~ /^([5-9]|1[079]|2[01235678]|3[5])$/;
        $self->update({
            status => Bivio::Type::ECPaymentStatus::FAILED(),
        });
    } else {
        Bivio::Die->die('unknown processor result code: ', $result_code);
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
