# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ECPaymentProcessAll;
use strict;
use Bivio::Base 'Action.JobBase';

# C<Bivio::Biz::Action::ECPaymentProcessAll> sets up a background job to
# process all pending credit card payments. The job will process and commit
# one payment at a time.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_PROCESSOR);
Bivio::IO::Config->register({
    processor => 'Bivio::Biz::Action::ECCreditCardProcessor',
});

sub handle_config {
    my(undef, $cfg) = @_;
    $_PROCESSOR = $cfg->{processor};
    b_use($_PROCESSOR);
    return;
}

sub internal_execute {
    # Go through list of all payments which need to be processed.
    # For each payment, setup user and realm, then call ECCreditCardProcessor
    # to handle it.
    my($self, $req) = @_;
    # check batch before.  Sometimes there is an error downloading
    # the status, and we have accidentally resubmitted a payments.
    $_PROCESSOR->check_transaction_batch($req);
    b_use('Model.ECPayment')->new($req)->do_iterate(sub {
        my($ecp) = @_;
	$ecp->put_on_request;
        $req->set_user($ecp->get('user_id'));
        $req->set_realm($ecp->get('realm_id'));
        $_PROCESSOR->execute_process($req);
	return 1;
    }, 'creation_date_time asc', {
	status => b_use('Type.ECPaymentStatus')->needs_processing_list,
    });
    return 0;
}

1;
