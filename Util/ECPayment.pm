# Copyright (c) 2018 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::ECPayment;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use File::Find ();
b_use('IO.ClassLoaderAUTOLOAD');

sub USAGE {
    return <<'EOF';
usage: bivio Project [options] command [args..]
commands
  info - list payments for realm
  process_all - run Action.ECPaymentProcessAll
EOF
}

sub info {
    # Return subscription info for the current club.
    #
    # type, start - end
    #     pay date, method, amount [CC #, CC exp date]
    #     ...
    # ...
    my($self) = @_;
    my($payments) = $self->model('ECPaymentList')->load_all;
    my($info) = join(', ', $self->req(qw(auth_realm owner))
        ->get(qw(name display_name))) . "\n";

    while ($payments->next_row) {
	$info .= $payments->get('ECPayment.ec_payment_id')
	    . ' ' . $payments->get('ECPayment.service')->get_short_desc.', ';

	if ($payments->get('ECSubscription.start_date')) {
	    $info .= Type_Date()->to_literal(
		$payments->get('ECSubscription.start_date')) . ' - '
		. Type_Date()->to_literal($payments->get('ECSubscription.end_date'))
		. "\n";
	}
	else {
	    $info .= "no subscription\n";
	}
	$info .= "\t" . Type_Date()->to_literal(
	    $payments->get('ECPayment.creation_date_time'))
	    . ' ' . $payments->get('ECPayment.method')->get_short_desc
	    . ' $' . $payments->get('ECPayment.amount')
	    . ' ' . $payments->get('ECPayment.status')->get_short_desc
	    . "\n";

	if ($payments->get('ECPayment.method')->eq_credit_card) {
	    $info .= "\t\tCC# " . $payments->get_model('ECCreditCardPayment')
		->get('card_number')
		. ' expires: ' . Type_Date()->to_literal($payments->get(
		    'ECCreditCardPayment.card_expiration_date')) . "\n";
	}
    }
    return $info;
}

sub process_all {
    my($self) = @_;
    $self->initialize_fully;
    # No global lock is needed
    b_use('Action.ECPaymentProcessAll')->execute(shift->req);
    return;
}

1;
