# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Mail::Common;
use strict;
$Bivio::Mail::Common::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::Common - utilities for mail modules

=head1 SYNOPSIS

    use Bivio::Mail::Common;
    Bivio::Mail::Common->send($recipients, $msg);
    $self->send();
    $self->enqueue_send();
    Bivio::Mail::Common->send_queued_messages();
    Bivio::Mail::Common->discard_queued_messages();

=cut

use Bivio::UNIVERSAL;
@Bivio::Mail::Common::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Mail::Common>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::Trace;
use User::pwent ();

#=VARIABLES
use vars qw($_TRACE);
my($_ERRORS_TO) = 'postmaster';
# Deliver in background so errors are sent via e-mail
my($_SENDMAIL) = '/usr/lib/sendmail -U -O ErrorMode=m -O DeliveryMode=b -i';
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
Bivio::IO::Config->register({
    'errors_to' => $_ERRORS_TO,
    'sendmail' => $_SENDMAIL,
});
my(@_QUEUE) = ();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UNIVERSAL

Pass through

=cut

sub new {
    return &Bivio::UNIVERSAL::new(@_);
}

=head1 METHODS

=cut

=for html <a name="discard_queued_messages"></a>

=head2 discard_queued_messages()

Empties the send queue, throwing away all messages in the queue.

=cut

sub discard_queued_messages () {
    @_QUEUE = ();
    return;
}

=for html <a name="enqueue_send"></a>

=head2 enqueue_send()

Queues this message for sending with
L<send_queued_messages|"send_queued_messages">.

=cut

sub enqueue_send {
    my($self) = @_;
    push(@_QUEUE, $self);
    return;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item errors_to : string [postmaster]

To whom should errors be sent.

=item sendmail : string [/usr/lib/sendmail -O DeliveryMode=b -i]

How to send mail.  Must accept a list of recipients on the
command line.  Arguments must be easily separated, i.e. no quoting.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $cfg->{errors_to} =~ /['\\]/
	    && die("$cfg->{errors_to}: invalid errors_to");
    $_ERRORS_TO = $cfg->{errors_to};
    $_SENDMAIL = $cfg->{sendmail};
    return;
}

=for html <a name="send"></a>

=head2 send(string recipients, string msg)

=head2 send(array_ref recipients, string msg)

=head2 send(string recipients, string_ref msg, int offset)

=head2 send(array_ref recipients, string_ref msg, int offset)

=head2 send(string recipients, string_ref msg, int offset, string $from)

=head2 send(array_ref recipients, string_ref msg, int offset, string $from)

Sends a message via configured C<sendmail> program.  Errors are
mailed back to configured C<errors_to>--except if no I<recipients>
iwc an exception is raised or no I<msg>.

Bounces are sent back to $from. $from is the envelope FROM, ie.
the -f argument given to sendmail.

=cut

sub send {
    my(undef, $recipients, $msg, $offset, $from) = @_;
    $offset ||= 0;
    $offset < 0 && die("negative offset \"$offset\"\n");
    defined($recipients) || die("no recipients\n");
    defined($msg) || die("no message\n");
    $from = defined($from) ? '-f'.$from : '';
    ref($recipients) && ($recipients = join(',', @$recipients));
    $recipients =~ s/(['\\])/\\$1/g;
    my($msg_ref) = ref($msg) ? $msg : \$msg;
    # Use only one handle to avoid leaks
    my($fh) = \*Bivio::Mail::Common::OUT;
    my($err);
#TODO: fork and exec, so can pass argument lists
#TODO: recipients may be very long(?).  If so either throw an error
#      or need to generate multiple sends.
    &_trace('sending from ', $from) if $_TRACE && $from;
    &_trace('sending to ', $recipients) if $_TRACE;
    unless (open($fh, "| $_SENDMAIL '$from' '$recipients'")) {
	$err = "open failed: $!";
	goto error;
    }
    while (length($$msg_ref) > $offset) {
	my($res) = syswrite($fh, $$msg_ref, length($$msg_ref) - $offset,
		$offset);
	unless (defined($res)) {
	    $err = "write failed: $!";
	    close($fh);
	    goto error;
	}
	$offset += $res;
    }
    close($fh) && $? == 0 && return;
    $err = "exit status non-zero ($?)";

 error:
#TODO: Make a MIME delivery/report
    &_trace('ERROR ', $err) if $_TRACE;
    my($u) = User::pwent::getpwuid($>);
    $u = defined($u) ? $u->name : 'uid' . $>;
    open($fh, "| $_SENDMAIL $_ERRORS_TO")
	    || die("open \"$_SENDMAIL $_ERRORS_TO\": $!\n");
    # From: filled in by sendmail
    print $fh <<"EOF" || die("print to \"$_SENDMAIL $_ERRORS_TO\": $!\n");
To: $_ERRORS_TO
Subject: ERROR: unable to send mail
Sender: "$0" <$u>
X-Pert-Module: $_PACKAGE

Error while trying to message to $recipients:
    $err
-------------------- Original Message Follows ----------------
${$msg_ref}
EOF
    close($fh) || die("close \"$_SENDMAIL $_ERRORS_TO\": $!\n");
    return;
}

=for html <a name="send_queued_messages"></a>

=head2 static send_queued_messages()

Sends messages that have been queued with L<enqueue|"enqueue">.  This should be
called after at the end of request processing.  Any errors are mailed to the
postmaster.

=cut

sub send_queued_messages {
    while (@_QUEUE) {
	shift(@_QUEUE)->send;
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
