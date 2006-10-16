# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ECPaymentProcessAll;
use strict;
$Bivio::Biz::Action::ECPaymentProcessAll::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::ECPaymentProcessAll::VERSION;

=head1 NAME

Bivio::Biz::Action::ECPaymentProcessAll - process all pending payments

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::ECPaymentProcessAll;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action::JobBase>

=cut

use Bivio::Biz::Action::JobBase;
@Bivio::Biz::Action::ECPaymentProcessAll::ISA = ('Bivio::Biz::Action::JobBase');

=head1 DESCRIPTION

C<Bivio::Biz::Action::ECPaymentProcessAll> sets up a background job to
process all pending credit card payments. The job will process and commit
one payment at a time.

=cut

#=IMPORTS
use Bivio::Agent::Task;
use Bivio::Agent::TaskId;
use Bivio::IO::ClassLoader;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Type::ECPaymentStatus;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PROCESSOR);
Bivio::IO::Config->register({
    processor => 'Bivio::Biz::Action::ECCreditCardProcessor',
});

=head1 METHODS

=cut

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item processor : string [Bivio::Biz::Action::ECCreditCardProcessor]

The module which handles the credit card processing.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_PROCESSOR = $cfg->{processor};
    Bivio::IO::ClassLoader->simple_require($_PROCESSOR);
    return;
}

=for html <a name="internal_execute"></a>

=head2 internal_execute(Bivio::Agent::Request req) : any

Go through list of all payments which need to be processed.
For each payment, setup user and realm, then call ECCreditCardProcessor
to handle it.

=cut

sub internal_execute {
    my($self, $req) = @_;
    # check batch before.  Sometimes there is an error downloading
    # the status, and we have accidentally resubmitted a payments.
    $_PROCESSOR->check_transaction_batch($req);
    my($ecp) = Bivio::Biz::Model->new($req, 'ECPayment');
    my($it) = $ecp->unauth_iterate_start('creation_date_time asc',
	{status => Bivio::Type::ECPaymentStatus->needs_processing_list});
    while ($ecp->iterate_next_and_load($it)) {
        $req->set_user($ecp->get('user_id'));
        $req->set_realm($ecp->get('realm_id'));
        $_PROCESSOR->execute_process($req);
    }
    $ecp->iterate_end($it);
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
