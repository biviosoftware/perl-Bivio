# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::HandleUnknownMail;
use strict;
$Bivio::Biz::Action::HandleUnknownMail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::HandleUnknownMail - handle unknown mail recipient

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::HandleUnknownMail::ISA = qw(Bivio::Biz::Action);

=head1 DESCRIPTION

C<Bivio::Biz::Action::HandleUnknownMail> handles mail sent to an
unknown user.  There are some standard names, e.g. C<owner-*> and
C<*-owner> which cause mail to be forwarded to the postmaster.
We will eventually forward these to the administrators of a club
and user space.  For now it as convenient handle.

We throw away mail sent to C<ignore-*>.

Other mail gets bounced with a not-found.

=cut

#=IMPORTS
use Bivio::DieCode;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Request req)

Looks at recipient to determine action: forward to postmaster,
toss, or bounce.

=cut

sub execute {
    my(undef, $req) = @_;
    my($msg) = $req->get('message');
    # There should only be one recipient
    my($who) = $msg->get_recipients->[0];
    if ($who =~ /^owner-|-owner$/i) {
	$msg->set_recipients('postmaster');
	$msg->enqueue_send;
	return;
    }
    if ($who =~ /^ignore-/i) {
	# Toss the message
	return;
    }
    $req->die(Bivio::DieCode::NOT_FOUND(), entity => $who);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
