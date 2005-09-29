# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Mail::Common;
use strict;
$Bivio::Mail::Common::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Mail::Common::VERSION;

=head1 NAME

Bivio::Mail::Common - utilities for mail modules

=head1 RELEASE SCOPE

bOP

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
use Bivio::Agent::Request;
use Bivio::Die;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use IO::File ();
use User::pwent ();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
Bivio::IO::Config->register(my $_CFG = {
    errors_to => 'postmaster',
    # Deliver in background so errors are sent via e-mail
    sendmail => '/usr/lib/sendmail -U -oem -odb -i',
    reroute_address => undef,
});
#TODO: get rid of global state - put it on the request instead
my($_QUEUE) = [];

=head1 METHODS

=cut

=for html <a name="discard_queued_messages"></a>

=head2 static discard_queued_messages()

Empties the send queue, throwing away all messages in the queue.

=cut

sub discard_queued_messages () {
    $_QUEUE = [];
    return;
}

=for html <a name="enqueue_send"></a>

=head2 enqueue_send(Bivio::Agent::Request req)

Queues this message for sending with
L<send_queued_messages|"send_queued_messages">.

=cut

sub enqueue_send {
    my($self, $req) = shift->internal_req(@_);
    if (int(@$_QUEUE)) {
        $req->push_txn_resource(ref($self))
            if _txn_resources_corrupted($self, $req);
    }
    else {
        $req->push_txn_resource(ref($self));
    }
    push(@$_QUEUE, $self);
    return;
}

=for html <a name="format_as_bounce"></a>

=head2 static format_as_bounce(string err, string recipients, string_ref msg, string errors_to) : string_ref

Creates an error message to be sent to 'errors_to'.  I<recipients> will
be retrieved with I<unsafe_get_recipients> if not supplied.
I<msg> will be retrieved with I<as_string> if not supplied.
I<errors_to> will be retrieved from I<errors_to> config if not supplied.

=cut

sub format_as_bounce {
    my($proto, $err, $recipients, $msg, $errors_to) = @_;
    $msg ||= \($proto->as_string);
    $recipients ||= $proto->unsafe_get_recipients || '<>';
    my($u) = User::pwent::getpwuid($>);
    $u = defined($u) ? $u->name : 'uid' . $>;
    $errors_to ||= $_CFG->{errors_to};
    return \(<<"EOF");
To: $errors_to
Subject: ERROR: unable to send mail
Sender: "$0" <$u>

Error while trying to message to $recipients:
    $err
-------------------- Original Message Follows ----------------
$$msg
EOF
}


=for html <a name="get_last_queued_message"></a>

=head2 get_last_queued_message() : Bivio::Mail::Outgoing

Return the last queued message.

=cut

sub get_last_queued_message {
    return $_QUEUE->[-1];
}

=for html <a name="handle_commit"></a>

=head2 handle_commit()

Commit called, delete lock from request before DB commit

=cut

sub handle_commit {
    my($proto) = @_;
    $proto->send_queued_messages;
    return;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item errors_to : string [postmaster]

To whom should errors be sent.

=item reroute_address : string []

The email address to send all mail to. Used for testing.

=item sendmail : string [/usr/lib/sendmail -O DeliveryMode=b -i]

How to send mail.  Must accept a list of recipients on the
command line.  Arguments must be easily separated, i.e. no quoting.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    Bivio::Die->die($cfg->{errors_to}, ': invalid errors_to')
        if $cfg->{errors_to} =~ /['\\]/;
    $_CFG = $cfg;
    return;
}

=for html <a name="handle_rollback"></a>

=head2 handle_rollback()

Rollback called, calls L<discard_queued_messages|"discard_queued_messages">.

=cut

sub handle_rollback {
    my($proto) = @_;
    $proto->discard_queued_messages;
    return;
}

=for html <a name="internal_req"></a>

=head2 internal_req(Bivio::Agent::Request req) : Bivio::Agent::Request

Returns request.  Warns deprecated if I<req> not supplied

=cut

sub internal_req {
    my($self, $req) = @_;
    return (
	$self,
	$req ? $req : (
	    Bivio::Agent::Request->get_current_or_new,
	    Bivio::IO::Alert->warn_deprecated('request is a required parameter')
    ));
}

=for html <a name="send"></a>

=head2 static send(string or array_ref recipients, string msg)

=head2 static send(string or array_ref recipients, string_ref msg, int offset)

=head2 static send(string or array_ref recipients, string_ref msg, int offset, string from)

Sends a message via configured C<sendmail> program.  Errors are
mailed back to configured C<errors_to>--except if no I<recipients>
or no I<msg> iwc an exception is raised.

Bounces are sent back to $from. $from is the envelope FROM, ie.
the -f argument given to sendmail.

=cut

sub send {
    my($proto, $recipients, $msg, $offset, $from) = @_;
    Bivio::Die->die('no recipients')
        unless defined($recipients);
    Bivio::Die->die('no message')
        unless defined($msg);
    my($msg_ref) = ref($msg) ? $msg : \$msg;
    $recipients = join(',', @$recipients)
	if ref($recipients);
    $recipients =~ s/'/'\\''/g;
    $offset ||= 0;
    Bivio::Die->die('negative offset: ', $offset)
        if $offset < 0;
    $from = defined($from) ? '-f' . $from : '';
    $from =~ s/'/'\\''/g;
    my($err) = _send($proto, $recipients, $msg_ref, $offset, $from);
    if ($err) {
        $err = _send(
	    $proto,
	    $_CFG->{errors_to},
            $proto->format_as_bounce($err, $recipients, $msg_ref),
	    0,
	    '',
	);
        Bivio::Die->die('errors_to mail failed: ', $err, "\n", $msg_ref)
            if $err;
    }
    return;
}

=for html <a name="send_queued_messages"></a>

=head2 static send_queued_messages()

Sends messages that have been queued with L<enqueue|"enqueue">.  This should be
called after at the end of request processing.  Any errors are mailed to the
postmaster.

=cut

sub send_queued_messages {
    while (@$_QUEUE) {
	shift(@$_QUEUE)->send;
    }
    return;
}

#=PRIVATE METHODS

# _send(proto, string recipients, string_ref msg, int offset, string from) : string
#
# Attempts to send the message. Returns an error string on failure.
#
sub _send {
    my($proto, $recipients, $msg, $offset, $from) = @_;
    _trace('sending to ', $recipients) if $_TRACE;
    $$msg = 'X-Bivio-Reroute-Address: '.$_CFG->{reroute_address}."\n".$$msg
	if $_CFG->{reroute_address};
    my($command) = '| ' . $_CFG->{sendmail}
	. ($from ? " '$from'" : '')
	. " '"
	. ($_CFG->{reroute_address} || $recipients)
	. "'";
    _trace($command) if $_TRACE;
    my($fh) = IO::File->new($command);
    return "$command failed: $!"
	unless $fh;
    while (length($$msg) > $offset) {
	my($res) = $fh->syswrite($$msg, length($$msg) - $offset, $offset);
	unless (defined($res)) {
	    $fh->close;
	    return "write failed: $!";
	}
	$offset += $res;
    }
    $fh->close;
    return $? == 0 ? '' : "exit status non-zero ($?)";
}

# _txn_resources_corrupted() : boolean
#
# Returns true if the request's transaction resources do not include
# self.
#
sub _txn_resources_corrupted {
    my($self, $req) = @_;

    foreach my $resource (@{$req->get('txn_resources')}) {
        return 0 if $resource eq ref($self);
    }
    $req->warn('Mail queue has items, but is not a txn resource: ', $self);
    return 1;
}

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
