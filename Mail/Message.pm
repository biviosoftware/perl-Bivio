# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Mail::Message;
use strict;
$Bivio::Mail::Message::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::Message - handle a mail message

=head1 SYNOPSIS

    use Bivio::Mail::Message;
    Bivio::Mail::Message->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::Mail::Message::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Mail::Message>

=cut

#=IMPORTS
use Carp;
use Time::Local ();
use MIME::Parser;
use Bivio::Mail::RFC822;
use Bivio::IO::Alert;
use Bivio::IO::Trace;
use Bivio::Mail::Address;
use Bivio::IO::Config;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_ERRORS_TO) = 'postmaster';
# Deliver in background so errors are sent via e-mail
my($_SENDMAIL) = '/usr/lib/sendmail -U -O ErrorMode=m -O DeliveryMode=b -i';
Bivio::IO::Config->register({
    'errors_to' => $_ERRORS_TO,
    'sendmail' => $_SENDMAIL,
});
my(@_QUEUE) = ();
my(@_REMOVE_FOR_LIST_RESEND) = qw(
    approved
    cc
    encoding
    errors-to flags
    message-id
    priority
    received
    references
    reply-to
    return-path
    return-receipt-to
    x-ack
    x-confirm-reading-to
    x-mozilla-status
    x-mozilla-status2
    x-pmrqc
);
# 822:
# Due to an artifact of the notational conventions, the syn-
# tax  indicates that, when present, some fields, must be in
# a particular order.  Header fields  are  NOT  required  to
# occur  in  any  particular  order, except that the message
# body must occur AFTER  the  headers.   It  is  recommended
# that,  if  present,  headers be sent in the order "Return-
# Path", "Received", "Date",  "From",  "Subject",  "Sender",
# "To", "cc", etc.
#
# This specification permits multiple  occurrences  of  most
# fields.   Except  as  noted,  their  interpretation is not
# specified here, and their use is discouraged.
#
# NOTE: This is list is sorted as described above!
my(@_FIRST_HEADERS) = qw(
    return-path
    received
    message-id
    date
    from
    subject
    sender
    to
    cc
    reply-to
    mime-version
    content-type
    content-transfer-encoding
    content-length
);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Mail::Message

=head2 static new(string_ref rfc822) : Bivio::Mail::Message

Create either an empty message or use a RFC822-conforming text to
work with an existing message.

=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    my(undef, $rfc822) = @_;
    my($parser) = MIME::Parser->new(output_to_core => 'ALL');
    $self->{$_PACKAGE} = {
	'time' => time,
        'parts' => $parser->parse_data($rfc822),
    };
    return $self;
}

=head1 METHODS

=cut

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

=for html <a name="get_entity"></a>

=head2 get_head() : MIME::Entity

Returns the header of this message.

=cut

sub get_entity {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{parts};
}

=for html <a name="get_head"></a>

=head2 get_head() : MIME::Head

Returns the header of this message.

=cut

sub get_head {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{parts}->head;
}

=for html <a name="get_body"></a>

=head2 get_body() : MIME::Body

Returns the body parts of this message.

=cut

sub get_body {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{parts}->bodyhandle;
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

=for html <a name="send"></a>

=head2 send() : Bivio::Type::Enum

Sends a message via configured C<sendmail> program.  Errors are
mailed back to configured C<errors_to>--except if no I<recipients>
iwc an exception is raised or no I<msg>.

=cut

sub send {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    defined(@{$fields->{recipients}}) || die("no recipients\n");

    &_trace('Sending msg to ', @{$fields->{recipients}}) if $_TRACE;
    my($err);
    # Use only one handle to avoid leaks
    my($fh) = \*Bivio::Mail::Message::OUT;
    my($pid) = open($fh, '|-');
    unless (defined($pid)) {
	Bivio::Die->die(Bivio::DieCode::NO_RESOURCES(), "open('|-') failed: $!");
    }
    if ($pid) { # parent
        print $fh $fields->{parts}->as_string;
        close($fh);
        $? == 0 || Bivio::Die->die(Bivio::DieCode::IO_ERROR(),
                "close(): status non-zero ($?)");
    } else { # child
        my(@cmd) = split(/\s+/, $_SENDMAIL);
        defined($fields->{from}) && push(@cmd, '-f', $fields->{from});
        exec(@cmd, @{$fields->{recipients}}) || die("$_SENDMAIL: $!");
    }
    return;
}

=for html <a name="set_headers_for_list_send"></a>

=head2 set_headers_for_list_send(string list_name, string list_title, boolean reply_to_list, boolean list_in_subject)

Removes the headers that are either to be replaced or are uninteresting on a
resend.  This is used for mailing list resends, not simple alias forwarding.
For example, Received:, To:, Cc:, and Message-Id: are removed.

Sets the I<list_name> in the C<To>. Sets From to owner-I<list_name> if C<From:>
not already set.  Inserts the I<list_name> in the C<Subject:> if
I<list_in_subject>.  Sets I<Reply-To:> to I<list_name> if I<reply_to_list>.

ASSUMES: Header addresses are rewritten with appropriate domain name
by MTA (sendmail).

=cut

sub set_headers_for_list_send {
    my($self, $list_name, $list_title, $reply_to_list, $list_in_subject) = @_;
    my($head) = $self->get_head;
#TODO: Being too restrictive on list_name syntax?
    $list_name =~ /^[-\w]+$/s || die("$list_name: invalid list name");
    $list_title =~ /^[^\n]+$/s || die("$list_title: invalid list title");
    $list_title =~ s/(["\\])/\\$1/g;
    my($name);
    foreach $name (@_REMOVE_FOR_LIST_RESEND) {
	$head->delete($name);
    }
    my($sender) = "$list_name-owner";
    $head->replace('Sender', $sender);
    $head->replace('Precedence', 'list');
    $self->set_from($sender);
    $head->replace('To', "\"$list_title\" <$list_name>");
    $reply_to_list && $head->replace('Reply-To', $head->get('To'));
    # If there is no From:, add it now.
    $head->get('From') || $head->add('From', $sender);
    # Insert the list in the subject, if not already there
    if ($list_in_subject) {
        my($s) = $head->get('Subject');
        if (defined($s)) {
            $s =~ s/^(?!(\s*Re:\s*)*$list_name:)/$list_name:/is;
	    $head->replace('Subject', $s);
	}
	else {
	    $head->add('Subject', "$list_name: ");
	}
    }
    return;
}

=for html <a name="set_from"></a>

=head2 set_from(string from)

Sets the from envelope of this message to I<from>. Note, this is different
from the I<From:> header setting which is what the recipients will see.

=cut

sub set_from {
    my($self, $from) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{from} = $from;
    return;
}

=for html <a name="set_recipients"></a>

=head2 set_recipients(string recipients)

=head2 set_recipients(array_ref recipients)

Sets the recipients of this message to I<recipients>.  The recipients
are part of the "envelope" associated with the message.

=cut

sub set_recipients {
    my($self, $r) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{recipients} = ref($r) eq 'ARRAY' ? $r : [$r];
    return;
}

=for html <a name="get_recipients"></a>

=head2 get_recipients() : array

Returns the "envelope" recipients that were set with
L<set_recipients|"set_recipients">.

=cut

sub get_recipients {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($r) = $fields->{recipients};
    return $r;
}

=for html <a name="get_reply_to"></a>

=head2 get_reply_to() : (string addr, string name)

=head2 get_reply_to() : string addr

Return I<Reply-To:> email address and name or just email
if not array context.

=cut

sub get_reply_to {
    my($self) = @_;
    my($reply_to) = $self->get_head->get('reply-to');
    if (defined($reply_to)) {
        my($email, $name) = Bivio::Mail::Address::parse($reply_to);
        &_trace($reply_to, ' -> (', $email, ',', $name, ')') if $_TRACE;
        return wantarray ? ($email, $name) : $email;
    } else {
        return wantarray ? (undef, undef) : undef;
    }
}

=for html <a name="get_from"></a>

=head2 get_from() : (string addr, string name)

=head2 get_from() : string addr

Return (email, name) or just email if not array context.

=cut

sub get_from {
    my($self) = @_;
    my($head) = $self->get_head;
    my($from) = $head->get('from') || $head->get('apparently-from');
    if (defined($from)) {
        my($email, $name) = Bivio::Mail::Address::parse($from);
        &_trace($from, ' -> (', $email, ',', $name, ')') if $_TRACE;
        return wantarray ? ($email, $name) : $email;
    } else {
	Bivio::IO::Alert->warn('Missing From');
	&_trace('no From') if $_TRACE;
        return wantarray ? (undef, undef) : undef;
    }
}

=for html <a name="get_date_time"></a>

=head2 get_date_time() : time

Returns the date specified by the message

=cut

sub get_date_time {
    my($self) = @_;
    my($date) = $self->get_field('date') || $self->get_field('received');
    if (defined($date)) {
        my($date_time) = _parse_date($date);
        &_trace($date, ' -> ', $date_time) if $_TRACE;
        return $date_time;
    } else {
	Bivio::IO::Alert->warn("no Date");
	&_trace('no Date or Received field avalable') if $_TRACE;
	return undef;
    }
}

=for html <a name="get_field"></a>

=head2 get_field(string name) : string

Returns the value for field "name", or undef if field does not exist

=cut

sub get_field {
    my($self, $name) = @_;
    my($value) = $self->get_head->get($name);
    return undef unless defined($value);
    chomp($value);
    # Return unfolded value
    $value =~ s/\r?\n[ \t]/ /gs;
    return $value;
}

=for html <a name="set_field"></a>

=head2 set_field(string name, string value) :

Sets a new value for field "name". Creates field if it doesn't exist.

=cut

sub set_field {
    my($self, $name, $value) = @_;
    $value =~ /\n$/ || ($value .= "\n");
    $self->get_head->replace($name, $value);
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

#=PRIVATE METHODS

# _parse_header(string_ref header) : hash_ref
#
# Parse header section and return all fields and their values.
# Leaves linebreaks in values intact.
#
sub _parse_header {
    my($header) = @_;
    my($fields) = {};
    my($FIELD_NAME) = Bivio::Mail::RFC822->FIELD_NAME;
    my($f, $n);
    foreach $f (split(/^(?=$FIELD_NAME)/om, $$header)) {
	($n, $f) = $f =~ /^($FIELD_NAME)\s*(.*)$/os;
	Bivio::IO::Alert->warn("invalid 822 field: $f"), next
		    unless defined($n);
	chop($n);
	$fields->{lc($n)} .= $f;
    }
    return $fields;
}

# _parse_date(string date) : int
#
# Parse a date/time string including a timezone and
# returns the corresponding UNIX time.
#
sub _parse_date {
    local($_) = @_;
    my($DATE_TIME) = Bivio::Mail::RFC822->DATE_TIME;
    my($mday, $mon, $year, $hour, $min, $sec, $tz) = /$DATE_TIME/os;
    defined($mday)
            || (Bivio::IO::Alert->warn('Cannot parse: ', $_), return undef);
    $mon = uc($mon);
    if (defined(Bivio::Mail::RFC822::MONTHS->{$mon})) {
        $mon = Bivio::Mail::RFC822::MONTHS->{$mon};
    }
    else {
        Bivio::IO::Alert->warn("month \"$mon\" unknown in \"$_\"");
        $mon = 0;
    }
    $tz = uc($tz);
    if (defined(Bivio::Mail::RFC822::TIME_ZONES->{$tz})) {
        $tz = Bivio::Mail::RFC822::TIME_ZONES->{$tz};
    }
    my($date_time) = Time::Local::timegm($sec, $min, $hour, $mday, $mon, $year);
    if ($tz =~ /^(-|\+?)(\d\d?)(\d\d)/s) {
        $date_time -= ($1 eq '-' ? -1 : +1) * 60 * ($2 * 60 + $3);
    } elsif ($tz != 0) {
        Bivio::IO::Alert->warn("timezone \"$tz\" unknown in \"$_\"");
    }
    return $date_time;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
