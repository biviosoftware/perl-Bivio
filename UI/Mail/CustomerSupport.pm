# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Mail::CustomerSupport;
use strict;
$Bivio::UI::Mail::CustomerSupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Mail::CustomerSupport - an outgoing mail message from support

=head1 SYNOPSIS

    use Bivio::UI::Mail::CustomerSupport;
    Bivio::UI::Mail::CustomerSupport->enqueue_message($req);

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::Mail::CustomerSupport::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::Mail::CustomerSupport> creates an outgoing email from support.

=cut

#=IMPORTS
use Bivio::Mail::Outgoing;

#=VARIABLES
my($_PHONE);
my($_FROM);

=head1 METHODS

=cut

=for html <a name="enqueue_message"></a>

=head2 static enqueue_message(Bivio::Agent::Request req, string recipient, string subject)

Enqueue_message the message and enqueue for sending.

=cut

sub enqueue_message {
    my(undef, $req, $recipient, $subject, $body) = @_;
    my($msg) = Bivio::Mail::Outgoing->new();
    unless ($_PHONE) {
	$_PHONE = $req->get('support_phone');
	$_FROM = 'bivio Customer Support <'.$req->get('support_email').'>';
    }
    $msg->set_recipients($recipient);
    $msg->set_header('From', $_FROM);
    $msg->set_header('To', $recipient);
    $msg->set_header('Subject', $subject);
    $body .= <<"EOF";

Thank you for using bivio,
Your Customer Support Team
________________________________________________________________
If you believe you have received this message in error, please
reply to this message or call $_PHONE and we will remove
your email address from our database.  We apologize for any
inconvenience.
EOF
    $msg->set_body($body);
    $msg->enqueue_send;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
