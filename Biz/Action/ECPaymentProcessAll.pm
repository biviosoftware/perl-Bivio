# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ECPaymentProcessAll;
use strict;
$Bivio::Biz::Action::ECPaymentProcessAll::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::ECPaymentProcessAll::VERSION;

=head1 NAME

Bivio::Biz::Action::ECPaymentProcessAll - process all pending payments

=head1 SYNOPSIS

    use Bivio::Biz::Action::ECPaymentProcessAll;

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::ECPaymentProcessAll::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::ECPaymentProcessAll> sets up a background job to
process all pending credit card payments. The job will process and commit
one payment at a time.

=cut

#=IMPORTS
use Bivio::Biz::Model::ECPayment;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req) : boolean

Creates a job to start processing the pending credit card
payments in the background.

=cut

sub execute {
    my($self, $req) = @_;

    return _process_all($self, $req) if $req->unsafe_get('process_all');

    # Setup job to call this method again
    Bivio::Agent::Job::Dispatcher->enqueue($req,
            Bivio::Agent::TaskId::EC_PAYMENTS_PROCESS_ALL(),
            {process_all => 1});
    # Nothing returned to client
    my($buffer) = '';
    $req->get('reply')->set_output(\$buffer);
    return 0;
}

#=PRIVATE METHODS

# _process_all(Bivio::Biz::Action::ECPaymentProcess self, Bivio::Agent::Request req) : boolean
#
# Go through list of all payments which need to be processed.
# For each payment, setup user and realm, then execute a separate
# task to process it.
#
sub _process_all {
    my($self, $req) = @_;

    my($task) = Bivio::Agent::Task->get_by_id(
            Bivio::Agent::TaskId::CLUB_ADMIN_EC_PROCESS_PAYMENT());
    my($payment_list) = Bivio::Biz::Model->new($req, 'AdmECPaymentList');
#TODO: How to pass a WHERE clause?? Only want certain records from the list.
    $payment_list->load_all;
    while ($payment_list->next_row) {
        my($payment) = $payment_list->get_model('ECPayment');
        next unless $payment->get('status')->needs_processing;
        $req->set_user($payment->get('user_id'));
        $req->set_realm($payment->get('realm_id'));
        $task->execute($req);
    }
    Bivio::Biz::Model::ECPayment->check_transaction_batch;
    return 0;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
