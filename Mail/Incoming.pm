# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Mail::Incoming;
use strict;
$Bivio::Mail::Incoming::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::Incoming - parses an incoming mail message

=head1 SYNOPSIS

    use Bivio::Mail::Incoming;
    my($bim) = Bivio::Mail::Incoming->new($rfc822_ref);
    Bivio::Mail::Incoming->uninitialize();
    Bivio::Mail::Incoming->initialize($rfc822_ref);
    $bim->get_from();
    $bim->get_reply_to();
    $bim->get_subject();
    $bim->get_message_id();
    $bim->get_date_time();

=cut

use Bivio::Mail::Common;
@Bivio::Mail::Incoming::ISA = qw(Bivio::Mail::Common);

=head1 DESCRIPTION

C<Bivio::Mail::Incoming> parses and maintains the state of an incoming mail
message.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use IO::Scalar;
use Bivio::IO::Config;
use Bivio::IO::Alert;
use Bivio::IO::Trace;
use Bivio::Mail::RFC822;
use Bivio::Mail::Common;
use Bivio::Mail::Address;
use Time::Local ();
require 'ctime.pl';

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
# Bivio::IO::Config->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string_ref rfc822) : Bivio::Mail::Incoming

=head2 static new(string_ref rfc822, int offset) : Bivio::Mail::Incoming

Create an instance and L<initialize|"initialize"> with I<rfc822>.
Default I<offset> is 0.

Note: the reference to I<rfc822> will be retained, so do not modify this value
until L<uninitialize|"uninitialize"> has been called or the object is
destroyed.

=cut

sub new {
    my($proto, $rfc822, $offset) = @_;
    my($self) = &Bivio::Mail::Common::new($proto);
    $self->initialize($rfc822, $offset);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_body"></a>

=head2 get_body() : string

=head2 get_body(string_ref body)

Returns the body of the message or puts a copy in I<body>.

=cut

sub get_body {
    my($self, $body) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined($body)) {
	$$body = substr(${$fields->{rfc822}}, $fields->{body_offset});
	return;
    }
    return substr(${$fields->{rfc822}}, $fields->{body_offset});
}

=for html <a name="get_date_time"></a>

=head2 get_date_time() : time

Returns the date specified by the message

=cut

sub get_date_time {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    exists($fields->{date_time}) && return $fields->{date_time};
    my($date) = &_get_field($fields, 'date:');
#TODO: If no Date: or bad Date: search Received: for valid dates
#hello
    unless (defined($date)) {
	Bivio::IO::Alert->warn("no Date");
	&_trace('no Date') if $_TRACE;
	return $fields->{date_time} = undef;
    }
    $fields->{date_time} = &_parse_date($date);
    &_trace($date, ' -> ', $fields->{date_time}) if $_TRACE;
    return $fields->{date_time};
}

=for html <a name="get_from"></a>

=head2 get_from() : (string addr, string name)

=head2 get_from() : string addr

Return <I>From:</I> email address and name or just email if not array context.

=cut

sub get_from {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (exists($fields->{from_email})) {
	return wantarray ? ($fields->{from_email}, $fields->{from_name})
	    : $fields->{from_email};
    }

    # 822: The  "Sender"  field  mailbox  should  NEVER  be  used
    #      automatically, in a recipient's reply message.
    my($from) = &_get_field($fields, 'from:')
	    || &_get_field($fields, 'apparently-from:');
    unless (defined($from)) {
	Bivio::IO::Alert->warn("no From");
	&_trace('no From') if $_TRACE;
	$fields->{from_email} = undef;
	$fields->{from_name} = undef;
	return wantarray ? (undef, undef) : undef;
    }
    ($fields->{from_email}, $fields->{from_name}) = Bivio::Mail::Address->parse($from);
    &_trace($from, ' -> (', $fields->{from_email}, ',',
	   $fields->{from_name}, ')') if $_TRACE;
    return wantarray ? ($fields->{from_email}, $fields->{from_name})
	    : $fields->{from_email};
}

=for html <a name="get_headers"></a>

=head2 get_headers() : hash

=head2 get_headers(hash headers) : hash

Returns a hash of headers.  The key is a the field name in lower case sans the
colon.  The value is the field name in original case followed by the field
value, i.e. the original text.  If a header appears multiple times, its
value will be a scalar contain all instances of the field.

Note: the field values include the terminating newline.

If I<headers> is undefined, a new hash will be created.  If I<headers> is
defined, fills in and returns I<headers>.

=cut

sub get_headers {
    my($self, $headers) = @_;
    $headers ||= {};
    my($fields) = $self->{$_PACKAGE};
    # Important to include the newline
    my($f);
    my($FIELD_NAME) = Bivio::Mail::RFC822->FIELD_NAME;
    foreach $f (split(/^(?=$FIELD_NAME)/om, $fields->{header})) {
	my($n) = $f =~ /^($FIELD_NAME)/o;
	Bivio::IO::Alert->warn("invalid 822 field: $f"), next
		    unless defined($n);
	chop($n);
	$headers->{lc($n)} .= $f;
    }
    return $headers;
}

=for html <a name="get_message_id"></a>

=head2 get_message_id() : string

Returns the Message-Id for this message.

=cut

sub get_message_id {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    exists($fields->{message_id}) && return $fields->{message_id};
    my($id) = &_get_field($fields, 'message-id:');
    unless (defined($id)) {
	Bivio::IO::Alert->warn("no message-id");
	&_trace('no Message-Id') if $_TRACE;
	return $fields->{message_id} = undef;
    }
#TODO: Should really parse this, but I mean RIIILLY....
    $id =~ s!^\s+!!s;
    $id =~ s!\s+$!!s;
    $fields->{message_id} = $id;
    &_trace($fields->{message_id}) if $_TRACE;
    return $id;
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
    if (ref($r) ne 'ARRAY' && defined($r)) {
	# Force to be an array for convenience of caller
	$fields->{recipients} = $r = [$r];
    }
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
    my($fields) = $self->{$_PACKAGE};
    if (exists($fields->{reply_to})) {
	return wantarray
		? ($fields->{reply_to_email}, $fields->{reply_to_name})
		: $fields->{reply_to_email};
    }
    my($reply_to) = &_get_field($fields, 'reply-to:');
    unless (defined($reply_to)) {
	&_trace('no Reply-To') if $_TRACE;
	$fields->{reply_to_email} = undef;
	$fields->{reply_to_name} = undef;
	return wantarray ? (undef, undef) : undef;
    }
    ($fields->{reply_to_email}, $fields->{reply_to_name})
	    = Bivio::Mail::Address->parse($reply_to);
    &_trace($reply_to, ' -> (', $fields->{reply_to_email}, ',',
	   $fields->{reply_to_name}, ')') if $_TRACE;
    return wantarray ? ($fields->{reply_to_email}, $fields->{reply_to_name})
	    : $fields->{reply_to_email};
}

=for html <a name="get_rfc822"></a>

=head2 get_rfc822() : string

I was not sure what to call this method. Basically, you want it to return
the entire RFC822, offset by the header_offset.

=cut

sub get_rfc822 {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return substr(${$fields->{rfc822}}, $fields->{header_offset});
}

=for html <a name="get_rfc822_io"></a>

=head2 get_rfc822_io() : 



=cut

sub get_rfc822_io {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my $file = IO::Scalar->new($fields->{rfc822});
    $file->setpos($fields->{header_offset});
    return $file;

}

=for html <a name="get_rfc822_length"></a>

=head2 get_rfc822_length() : int

Returns length of C<rfc822>.

=cut

sub get_rfc822_length {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return length(${$fields->{rfc822}}) - $fields->{header_offset};
}

=for html <a name="get_subject"></a>

=head2 get_subject() : string

Returns I<Subject> of message or C<undef>.

=cut

sub get_subject {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    exists($fields->{subject}) && return $fields->{subject};
    my($subject) = &_get_field($fields, 'subject:');
    unless (defined($subject)) {
	&_trace('no Subject') if $_TRACE;
	return $fields->{subject} = undef;
    }
    $subject =~ s/^\s+//s;
    $subject =~ s/\s+$//s;
    $fields->{subject} = $subject;
    &_trace($fields->{subject}) if $_TRACE;
    return $subject;
}

=for html <a name="get_unix_mailbox"></a>

=head2 get_unix_mailbox() : string

Returns the message in unix mailbox format.  Always ends in a newline.

=cut

sub get_unix_mailbox {
    my($self, $buffer, $offset) = @_;
    my($fields) = $self->{$_PACKAGE};
    # ctime already has newline
    return 'From unknown ' . ctime($fields->{time})
	    . substr(${$fields->{rfc822}}, $fields->{header_offset})
	    . (substr(${$fields->{rfc822}}, -1) eq "\n" ? '' : "\n");
}

=for html <a name="initialize"></a>

=head2 initialize(string_ref $rfc822)

=head2 initialize(string_ref $rfc822, int offset)

Initializes the object with the reference supplied.

Note: the reference to I<rfc822> will be retained, so do not modify this value
until L<uninitialize|"uninitialize"> has been called or the object is
destroyed.

=cut

sub initialize {
    my($self, $rfc822, $offset) = @_;
    $offset ||= 0;
    my($i) = index($$rfc822, "\n\n", $offset);
    my($h);
    if (substr($$rfc822, $offset, 5) eq 'From ') {
	# Skip Unix From line
	$offset = index($$rfc822, "\n", $offset) + 1;
    }
    if ($i >= 0) {
	$i -= $offset;
	$h = substr($$rfc822, $offset, $i + 1);
	# Account for \n\n
	$i += 2 + $offset;
    }
    else {
	$i = length($$rfc822) - $offset;
	$h = substr($$rfc822, $offset, $i + 1);
    }
#TODO: Handle "From " start lines.
#TODO: Don't unfold headers in advance.  Unfold headers as they
#      are parsed.  This makes resent mail messages cleaner.
    # unfold all headers in advance.  Makes other code simpler.
    #
    # [rfc882] Unfolding is accomplished by regarding CRLF immediately
    # followed by a LWSP-char as equivalent to the LWSP-char.
    # Can't use \s, because isn't locale specific.
    # TODO: Not handling quoted CRLF sequences which appear to be legitimate.
    #      The effect will be to lose quoted LF and replace it with a
    #      quoted space.
    $h =~ s/\r?\n[ \t]/ /gs;
    $self->{$_PACKAGE} = {
	'rfc822' => $rfc822,
	'header' => $h,
	'header_offset' => $offset,
	# If there is no body, get_body will return empty string.
	'body_offset' => $i,
	'time' => time,
    };
    return;
}

=for html <a name="send"></a>

=head2 send()

Send the mail message to the specified recipients (see
L<set_recipients|"set_recipients">).  The headers
and body remain unchanged, even C<Sender:>.   This should be used
for "alias-like" forwarding only.

=cut

sub send {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    Bivio::Mail::Common->send($fields->{recipients}, $fields->{rfc822},
	    $fields->{header_offset}, $self->get_from());
}

=for html <a name="set_recipients"></a>

=head2 set_recipients(string recipients)

=head2 set_recipients(array_ref recipients)

Sets the recipients of this message to I<recipients>.  The recipients
are part of the "envelope" associated with the message.

=cut

sub set_recipients {
    my($self, $recipients) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{recipients} = $recipients;
    return;
}

=for html <a name="uninitialize"></a>

=head2 uninitialize()

Clear any state associated with this object.

=cut

sub uninitialize {
    my($self) = @_;
    delete($self->{$_PACKAGE});
    return;
}

#=PRIVATE METHODS

# $name must be lc and ending with a ':'
sub _get_field {
    my($fields, $name) = @_;
    # May be that the field is undefined.
    unless (exists($fields->{$name})) {
        # Must not be \s, because maps to newline.  If the field is
        # empty, will grab next field (line).
        # CPERL-BUG: (?: |\t) is necessary because $name[ \t] would be bad
        ($fields->{$name}) = $fields->{header} =~ /^$name(?: |\t)*(.*)/im;
    }
    return $fields->{$name};
}

sub _parse_date {
    local($_) = @_;
    my($DATE_TIME) = Bivio::Mail::RFC822->DATE_TIME;
    my($mday, $mon, $year, $hour, $min, $sec, $tz) = /^$DATE_TIME/os;
    defined($mday) || return &_parse_complex_date($_);
    $mon = uc($mon);
    if (defined(Bivio::Mail::RFC822::MONTHS->{$mon})) {
        $mon = Bivio::Mail::RFC822::MONTHS->{$mon};
    }
    else {
        Bivio::IO::Alert->warn("month \"$mon\" unknown in date \"$_\"");
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
        Bivio::IO::Alert->warn("timezone \"$tz\" unknown in date \"$_\"");
    }
    return $date_time;
}

# strips out comments
sub _parse_complex_date {
#TODO: NEED TO IMPLEMENT!
    local($_) = @_;
    Bivio::IO::Alert->warn('unable to parse date: ', $_);
    return time;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
