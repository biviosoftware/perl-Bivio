# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ECPaymentProcessAll;
use strict;
use Bivio::Base 'Action.JobBase';

# ECPaymentProcessAll sets up a background job to
# process all pending credit card payments. The job will process and commit
# one payment at a time.


sub internal_execute {
    # Go through list of all payments which need to be processed.
    # For each payment, setup user and realm, then call ECCreditCardProcessor
    # to handle it.
    my($self, $req) = @_;
    b_use('Model.ECPayment')->new($req)->do_iterate(sub {
        my($ecp) = @_;
	$ecp->put_on_request;
        $req->set_user($ecp->get('user_id'));
        $req->set_realm($ecp->get('realm_id'));
	$ecp->get_model('ECCreditCardPayment')->get_payment_processor
	    ->execute_process($req);
	return 1;
    }, 'unauth_iterate_start', 'creation_date_time asc', {
	status => b_use('Type.ECPaymentStatus')->needs_processing_list,
    });
    return 0;
}

1;
