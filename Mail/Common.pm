# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
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

=cut

use base 'Bivio::Collection::Attributes';

=head1 DESCRIPTION

C<Bivio::Mail::Common>

=cut

=head1 CONSTANTS

=cut

=for html <a name="TEST_RECIPIENT_HDR"></a>

=head2 static TEST_RECIPIENT_HDR()

Returns header where recipient is inserted into msg.  Only if
$req.is_test.

=cut

sub TEST_RECIPIENT_HDR {
    return 'X-Bivio-Test-Recipient';
}

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
    sendmail => `/usr/sbin/sendmail -U devnull < /dev/null 2>&1` =~ /illegal/
	? '/usr/sbin/sendmail -oem -odb -i'
	: '/usr/sbin/sendmail -U -oem -odb -i',
});
#TODO: get rid of global state - put it on the request instead
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 METHODS

=cut

=for html <a name="enqueue_send"></a>

=head2 enqueue_send(Bivio::Agent::Request req) : self

Queues I<self> for sending on commit.

=cut

sub enqueue_send {
    my($self, $req) = shift->internal_req(@_);
    $req->push_txn_resource($self);
    return $self;
}

=for html <a name="format_as_bounce"></a>

=head2 static format_as_bounce(string err, string recipients, string_ref msg, string errors_to, Bivio::Agent::Request req) : string_ref

Creates an error message to be sent to 'errors_to'.  I<recipients> will
be retrieved with I<unsafe_get_recipients> if not supplied.
I<msg> will be retrieved with I<as_string> if not supplied.
I<errors_to> will be retrieved from I<errors_to> config if not supplied.

=cut

sub format_as_bounce {
    my($proto, $err, $recipients, $msg, $errors_to, $req) = @_;
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

=for html <a name="get_last_queued_message"></a>

=head2 get_last_queued_message(Bivio::Agent::Request req) : Bivio::Mail::Common

Return the last message queued.

=cut

sub get_last_queued_message {
    my($self, $req) = @_;
    return pop(@{[
        grep(UNIVERSAL::isa($_, $self), @{$req->get('txn_resources')})]});
}


=for html <a name="handle_commit"></a>

=head2 handle_commit(Bivio::Agent::Request req)

Send self.

=cut

sub handle_commit {
    shift->send(shift);
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
    Bivio::Die->die($cfg->{errors_to}, ': invalid errors_to')
        if $cfg->{errors_to} =~ /['\\]/;
    $_CFG = $cfg;
    return;
}

=for html <a name="handle_rollback"></a>

=head2 handle_rollback()

Do nothing.

=cut

sub handle_rollback {
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

=head2 static send(string or array_ref recipients, string msg) : self

=head2 static send(string or array_ref recipients, string_ref msg, int offset, Bivio::Agent::Request req) : self

=head2 static send(string or array_ref recipients, string_ref msg, int offset, string from, Bivio::Agent::Request req) : self

Sends a message via configured C<sendmail> program.  Errors are
mailed back to configured C<errors_to>--except if no I<recipients>
or no I<msg> iwc an exception is raised.

Bounces are sent back to $from. $from is the envelope FROM, ie.
the -f argument given to sendmail.

=cut

sub send {
    my($self, $recipients, $msg, $offset, $from, $req) = @_;
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

=for html <a name="set_recipients"></a>

=head2 set_recipients(string email_list) : self

=head2 set_recipients(array_ref email_list) : self

Sets the recipient of this mail message.  It does not modify the
headers, i.e. To:, etc.  I<email_list> may be a single scalar
containing multiple addresses (separated by commas)
or an array whose elements may contain scalar lists.

=cut

sub set_recipients {
    my($self, $email_list) = @_;
    return $self->put(recipients => join(
	',',
	map(@{Bivio::Mail::Address->parse_list($_)},
	    ref($email_list) ? @$email_list : $email_list,
        ),
    ));
}

=for html <a name="unsafe_get_recipients"></a>

=head2 unsafe_get_recipients() : string

Returns recipients.

=cut

sub unsafe_get_recipients {
    return shift->unsafe_get('recipients');
}


=for html <a name="user_email"></a>

=head2 user_email(Bivio::Agent::Request req) : array

Returns ($email, $name)

=cut

sub user_email {
    my(undef, $req) = @_;
    my($name) = getpwuid($>) || 'intruder';
    return ($req->format_email($name), $name);
}

#=PRIVATE METHODS

# _send(proto, string recipients, string_ref msg, int offset, string from) : string
#
# Attempts to send the message. Returns an error string on failure.
#
sub _send {
    my($proto, $recipients, $msg, $offset, $from, $req) = @_;
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

=head1 COPYRIGHT

Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
