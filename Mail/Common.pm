# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Mail::Common;
use strict;
use Bivio::Agent::Request;
use Bivio::Base 'Bivio::Collection::Attributes';
use Bivio::Die;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use IO::File ();
use User::pwent ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
Bivio::IO::Config->register(my $_CFG = {
    errors_to => 'postmaster',
    # Deliver in background so errors are sent via e-mail
    sendmail => '/usr/sbin/sendmail -oem -odb -i',
});
#TODO: get rid of global state - put it on the request instead
my($_IDI) = __PACKAGE__->instance_data_index;

sub TEST_RECIPIENT_HDR {
    # Returns header where recipient is inserted into msg.  Only if
    # $req.is_test.
    return 'X-Bivio-Test-Recipient';
}

sub enqueue_send {
    my($self, $req) = shift->internal_req(@_);
    # Queues I<self> for sending on commit.
    $req->push_txn_resource($self);
    return $self;
}

sub format_as_bounce {
    my($proto, $err, $recipients, $msg, $errors_to, $req) = @_;
    # Creates an error message to be sent to 'errors_to'.  I<recipients> will
    # be retrieved with I<unsafe_get_recipients> if not supplied.
    # I<msg> will be retrieved with I<as_string> if not supplied.
    # I<errors_to> will be retrieved from I<errors_to> config if not supplied.
    $msg ||= \($proto->as_string);
    $recipients ||= $proto->unsafe_get_recipients || '<>';
    my($u) = User::pwent::getpwuid($>);
    $u = defined($u) ? $u->name : 'uid' . $>;
    $errors_to ||= $_CFG->{errors_to};
    my($email, $name) = $proto->user_email($req);
    return \(<<"EOF");
From: "$name" <$email>
To: $errors_to
Subject: ERROR: unable to send mail
Sender: "$0" <$u>

Error while trying to message to $recipients:

    (reason: $err)

-------------------- Original Message Follows ----------------
$$msg
EOF
}

sub get_last_queued_message {
    my($self, $req) = @_;
    # Return the last message queued.
    return pop(@{[
        grep(UNIVERSAL::isa($_, $self), @{$req->get('txn_resources')})]});
}

sub handle_commit {
    # Send self.
    shift->send(shift);
    return;
}

sub handle_config {
    my(undef, $cfg) = @_;
    # errors_to : string [postmaster]
    #
    # To whom should errors be sent.
    #
    # sendmail : string [/usr/lib/sendmail -O DeliveryMode=b -i]
    #
    # How to send mail.  Must accept a list of recipients on the
    # command line.  Arguments must be easily separated, i.e. no quoting.
    Bivio::Die->die($cfg->{errors_to}, ': invalid errors_to')
        if $cfg->{errors_to} =~ /['\\]/;
    $_CFG = $cfg;
    return;
}

sub handle_rollback {
    # Do nothing.
    return;
}

sub internal_req {
    my($self, $req) = @_;
    # Returns request.  Warns deprecated if I<req> not supplied
    return (
	$self,
	$req ? $req : (
	    Bivio::Agent::Request->get_current_or_new,
	    Bivio::IO::Alert->warn_deprecated('request is a required parameter')
    ));
}

sub send {
    my($self, $recipients, $msg, $offset, $from, $req) = @_;
    # Sends a message via configured C<sendmail> program.  Errors are
    # mailed back to configured C<errors_to>--except if no I<recipients>
    # or no I<msg> iwc an exception is raised.
    #
    # Bounces are sent back to $from. $from is the envelope FROM, ie.
    # the -f argument given to sendmail.
    $recipients ||= $self->unsafe_get_recipients
	|| Bivio::Die->die('no recipients');
    $recipients = join(',', @$recipients)
	if ref($recipients);
    $msg ||= $self->as_string;
    my($msg_ref) = ref($msg) ? $msg : \$msg;
    $offset ||= 0;
    $from = defined($from) ? '-f' . $from : '';
    $recipients =~ s/'/'\\''/g;
    Bivio::Die->die('negative offset: ', $offset)
        if $offset < 0;
    $from =~ s/'/'\\''/g;
    $req ||= Bivio::Agent::Request->get_current_or_new;
    my($err) = _send($self, $recipients, $msg_ref, $offset, $from, $req);
    if ($err) {
        $err = _send(
	    $self,
	    $_CFG->{errors_to},
            $self->format_as_bounce(
		$err, $recipients, $msg_ref, undef,
		$req,
	    ),
	    0,
	    '',
	    $req,
	);
        Bivio::Die->die('errors_to mail failed: ', $err, "\n", $msg_ref)
            if $err;
    }
    return $self;
}

sub set_recipients {
    my($self, $email_list) = @_;
    # Sets the recipient of this mail message.  It does not modify the
    # headers, i.e. To:, etc.  I<email_list> may be a single scalar
    # containing multiple addresses (separated by commas)
    # or an array whose elements may contain scalar lists.
    return $self->put(recipients => join(
	',',
	map(@{Bivio::Mail::Address->parse_list($_)},
	    ref($email_list) ? @$email_list : $email_list,
        ),
    ));
}

sub unsafe_get_recipients {
    # Returns recipients.
    return shift->unsafe_get('recipients');
}

sub user_email {
    my(undef, $req) = @_;
    # Returns ($email, $name)
    my($name) = getpwuid($>) || 'intruder';
    return ($req->format_email($name), $name);
}

sub _send {
    my($proto, $recipients, $msg, $offset, $from, $req) = @_;
    # Attempts to send the message. Returns an error string on failure.
    _trace('sending to ', $recipients) if $_TRACE;
    if ($req->is_test) {
	return grep(
	    _send($proto, $_, $msg, $offset, $from, $req),
	    split(/,/, $recipients),
	) if $recipients =~ /,/;
	my($m) = $$msg;
	$msg = \$m;
	substr($$msg, $offset, 0)
	    = $proto->TEST_RECIPIENT_HDR . ": $recipients\n";
    }
    my($command) = '| ' . $_CFG->{sendmail}
	. ($from ? " '$from'" : '')
	. " '$recipients'";
    _trace($command) if $_TRACE;
    return unless my $die = Bivio::Die->catch(sub {
	Bivio::IO::File->write(
	    IO::File->new($command) || die("$command: open failed"),
	    $msg,
	    $offset,
	);
    }) or $?;
    Bivio::IO::Alert->warn($die ? $die->as_string : "$command: status = $?");
    return 'I/O error';
}

1;
