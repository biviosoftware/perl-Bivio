# Copyright (c) 2001 bivio Inc.  All Rights reserved.
# $Id$
package Bivio::Biz::Action::TaxesSubscriptionRedirect;
use strict;
$Bivio::Biz::Action::TaxesSubscriptionRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::TaxesSubscriptionRedirect::VERSION;

=head1 NAME

Bivio::Biz::Action::TaxesSubscriptionRedirect - checks taxes permissions

=head1 RELEASE SCOPE

Societas

=head1 SYNOPSIS

    use Bivio::Biz::Action::TaxesSubscriptionRedirect;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::TaxesSubscriptionRedirect::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::TaxesSubscriptionRedirect> redirects to a
subscription page if taxes aren't enabled.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : boolean

Redirects to the Taxes Subscription page if TAXES permission isn't
enabled.

Always returns false.

=cut

sub execute {
    my($proto, $req) = @_;

    $req->server_redirect(
	Bivio::Agent::TaskId->CLUB_ACCOUNTING_TAXES_SUBSCRIPTION)
	unless $req->get('auth_realm')->can_user_execute_task(
	    Bivio::Agent::Task->get_by_id(
		Bivio::Agent::TaskId->CLUB_ACCOUNTING_TAXES_F1065), $req);

    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
