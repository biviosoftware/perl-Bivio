# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Mail::Incoming;
use IO::Scalar;
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
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Mail::Common;
use Time::Local ();
require 'ctime.pl';

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
# Bivio::IO::Config->register;

#TODO: Move to Bivio::Mail::RFC822
#TODO: Create Bivio::Mail::Address with parsing routines
my($_822_CHAR) = '[\\0-\\177]';
my($_822_ALPHA) = '[\\101-\\132\\141-\\172]';
my($_822_DIGIT) = '[\\060-\\071]';
my($_822_CTL) = '[\\0-\\037\\177-\\377]';
my($_822_LWSP) = '[ \\t]';
my($_822_SPECIALS) = '[][()<>@,;:\\\\".]';
my($_822_ATOM) = '[^][()<>@,;:\\\\". \\000-\\040\\177-\\377]+';
my($_822_QUOTED_STRING) = '"(?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^\\\\"])*)"';
my($_822_DOMAIN_LITERAL) = '\\[(?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^][\\\\])*)\\]';
# 822 comments can be nested.  We test for simple comments and if
# that fails, we have to get complex.
my($_822_NOT_NESTED_COMMENT)
	= '\\((?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^()\\\\])*)\\)';
my($_822_WORD) = "(?:$_822_ATOM|$_822_QUOTED_STRING)";
# Single space mandated between words, but relax for parsing
my($_822_PHRASE) = "$_822_WORD(?:\\s+$_822_WORD)*";
my($_822_ATOM_ONLY_PHRASE) = "$_822_ATOM(?:\\s+$_822_ATOM)*";
my($_822_LOCAL_PART) = "$_822_WORD(?:\\.$_822_WORD)*";
my($_822_DOTTED_ATOMS) = "$_822_ATOM(?:\\.$_822_ATOM)*";
my($_822_SUB_DOMAIN) = "(?:$_822_ATOM|$_822_DOMAIN_LITERAL)";
my($_822_DOMAIN) = "$_822_SUB_DOMAIN(?:\\.$_822_SUB_DOMAIN)*";
my($_822_ADDR_SPEC) = "$_822_LOCAL_PART\@$_822_DOMAIN";
my($_822_ATOM_ONLY_ADDR) = "$_822_DOTTED_ATOMS\@$_822_DOTTED_ATOMS";
my($_822_ROUTE) = "\@$_822_DOMAIN(?:,\@$_822_DOMAIN)*:";
my($_822_ROUTE_ADDR) = "<(?:$_822_ROUTE)?$_822_ADDR_SPEC>";
my($_822_MAILBOX) = "(?:$_822_ADDR_SPEC|(?:$_822_PHRASE\s+)*$_822_ROUTE_ADDR)";
my($_822_GROUP) = "$_822_PHRASE:(?:$_822_MAILBOX(?:,$_822_MAILBOX)*;";
my($_822_ADDRESS) = "(?:$_822_MAILBOX|$_822_GROUP)";
my($_822_FIELD_NAME) = '[\\041-\\071\\073-\\176]+:';
my($_822_DAY) = "[a-zA-Z]{3}";
my($_822_DATE) = '(\\d\\d?)\\s*([a-zA-Z]{3})\\s*(\\d{2,4})';
# Be flexible with times, as I have seen 17:9:12
my($_822_TIME) = '(\\d\\d?):(\\d\\d?):(\\d\\d?)\\s*([-+\\w]{1,5})';
my($_822_DATE_TIME) = "(?:$_822_DAY\s*,)?\\s*$_822_DATE\\s*$_822_TIME";
my(%_822_MONTHS) = (
    'JAN' => 0,
    'FEB' => 1,
    'MAR' => 2,
    'APR' => 3,
    'MAY' => 4,
    'JUN' => 5,
    'JUL' => 6,
    'AUG' => 7,
    'SEP' => 8,
    'OCT' => 9,
    'NOV' => 10,
    'DEC' => 11,
);
my(%_822_TIME_ZONES) = (
    'UT' => 0,
    'GMT' => 0,
    'Z' => 0,
    'EST' => -500,
    'EDT' => -400,
    'CST' => -600,
    'CDT' => -700,
    'MST' => -700,
    'MDT' => -800,
    'PST' => -800,
    'PDT' => -900,
    'A' => -100,
    'B' => -200,
    'C' => -300,
    'D' => -400,
    'E' => -500,
    'F' => -600,
    'G' => -700,
    'H' => -800,
    'I' => -900,
    # J not used
    'K' => -1000,
    'L' => -1100,
    'M' => -1200,
    'N' => +100,
    'O' => +200,
    'P' => +300,
    'Q' => +400,
    'R' => +500,
    'S' => +600,
    'T' => +700,
    'U' => +800,
    'V' => +900,
    'W' => +1000,
    'X' => +1100,
    'Y' => +1200,
);

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
	warn("no Date");
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
    exists($fields->{from_email}) && return $fields->{from_email};
    # 822: The  "Sender"  field  mailbox  should  NEVER  be  used
    #      automatically, in a recipient's reply message.
    my($from) = &_get_field($fields, 'from:')
	    || &_get_field($fields, 'apparently-from:');
    unless (defined($from)) {
	warn("no From");
	&_trace('no From') if $_TRACE;
	$fields->{from_email} = undef;
	$fields->{from_name} = undef;
	return wantarray ? (undef, undef) : undef;
    }
    ($fields->{from_email}, $fields->{from_name}) = &_parse_addr($from);
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
    foreach $f (split(/^(?=$_822_FIELD_NAME)/om, $fields->{header})) {
	my($n) = $f =~ /^($_822_FIELD_NAME)/;
	warn("invalid 822 field: $f"), next unless defined($n);
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
	warn("no message-id");
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
    exists($fields->{reply_to}) && return $fields->{reply_to};
    my($reply_to) = &_get_field($fields, 'reply-to:');
    unless (defined($reply_to)) {
	&_trace('no Reply-To') if $_TRACE;
	$fields->{reply_to_email} = undef;
	$fields->{reply_to_name} = undef;
	return wantarray ? (undef, undef) : undef;
    }
    ($fields->{reply_to_email}, $fields->{reply_to_name})
	    = &_parse_addr($reply_to);
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
	    $fields->{header_offset});
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

sub _clean_comment {
    local($_) = @_;
    s/^\(//s && s/\)$//s || Carp::cluck("not a comment: $_");
    s/\\(.)/$1/gs;
    return $_;
}

sub _clean_route_addr {
    local($_) = @_;
    s/^\<//s && s/\>$//s || die("not a route address: $_");
    return $_;
}

sub _clean_quoted_string {
    local($_) = @_;
    s/^\"//s && s/\"$//s || die("not a quoted string: $_");
    s/\\(.)/$1/gs;
    return $_;
}

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

# 822:
#     For purposes of display, and when passing  such  struc-
#     tured information to other systems, such as mail proto-
#     col  services,  there  must  be  NO  linear-white-space
#     between  <word>s  that are separated by period (".") or
#     at-sign ("@") and exactly one SPACE between  all  other
#     <word>s.  Also, headers should be in a folded form.
#
#     There is one type of bracket which must occur in matched pairs
#     and may have pairs nested within each other:
#
#	 o   Parentheses ("(" and ")") are used  to  indicate  com-
#	     ments.
#
#     There are three types of brackets which must occur in  matched
#     pairs, and which may NOT be nested:
#
#	 o   Colon/semi-colon (":" and ";") are   used  in  address
#	     specifications  to  indicate that the included list of
#	     addresses are to be treated as a group.
#
#	 o   Angle brackets ("<" and ">")  are  generally  used  to
#	     indicate  the  presence of a one machine-usable refer-
#	     ence (e.g., delimiting mailboxes), possibly  including
#	     source-routing to the machine.
#
#	 o   Square brackets ("[" and "]") are used to indicate the
#	     presence  of  a  domain-literal, which the appropriate
#	     name-domain  is  to  use  directly,  bypassing  normal
#	     name-resolution mechanisms.
#
# These appear after -----Original Message-----
#     From: Jeffrey Richer [SMTP:jricher@inet.net]
#     From: . <winsv@ix.netcom.com>
#     From: <MNatto@aol.com>
# Probably part of Outlook.  Not a problem for us as the "Original Message"
# is not an 822 thing.
#
# Parses the first address in the field. If there are multiple
# addresses, only grabs the first one.
sub _parse_addr {
    local($_) = @_;
    s/^\s+//s;
    my($n, $a);
    # Cases are optimized by their statistical counts.
    # Joe Bob <joe@bob.com>
    if (($n, $a)
	    = /^($_822_ATOM_ONLY_PHRASE)\s*\<($_822_ATOM_ONLY_ADDR)\>/os) {
	return ($a, $n);
    }
    # "Joe Bob" <joe@bob.com>
    if (($n, $a) = /^($_822_QUOTED_STRING)\s*\<($_822_ATOM_ONLY_ADDR)\>/os) {
	return ($a, &_clean_quoted_string($n));
    }
    # joe@bob.com -- grab first addr, not allowing comment
    if (($a) = m!^($_822_ATOM_ONLY_ADDR)\s*(?:,|$)!os) {
	return ($a, undef);
    }
    # joe@bob.com (Joe Bob)
    if (($a, $n) = m!^($_822_ATOM_ONLY_ADDR)\s*($_822_NOT_NESTED_COMMENT)!os) {
	return ($a, &_clean_comment($n));
    }
    if (($a, $n) = /^($_822_MAILBOX)\s*((?:$_822_NOT_NESTED_COMMENT)*)/os) {
#TODO: Need to make sure we hit 99.99% of addresses with this
#      We don't handle groups. ok?  What about "Undisclosed Recipients:;"?
	# complex@addr (My comment) AND complex@addr
	if ($a =~ /^$_822_ADDR_SPEC$/) {
	    # $a is an address, no further parsing necessary
	    return ($a, length($n) ? &_clean_comment($n) : $n);
	}
	# $_822_MAILBOX: <complex@addr>
	if (($a) = /^($_822_ROUTE_ADDR)/) {
	    return (&_clean_route_addr($a), undef);
	}
	# $_822_MAILBOX: My Comment <complex@addr>
	if (($n, $a) = /^($_822_PHRASE)\s+($_822_ROUTE_ADDR)/) {
	    return (&_clean_route_addr($a), $n);
	}
#TODO: error or assert_fail
	die("822 regular expressions incorrect");
    }
    die("unable to parse address: $_");
}

sub _parse_date {
    local($_) = @_;
    my($mday, $mon, $year, $hour, $min, $sec, $tz) = /^$_822_DATE_TIME/os;
    defined($mday) || return &_parse_complex_date($_);
    $mon = uc($mon);
    if (defined($_822_MONTHS{$mon})) {
	$mon = $_822_MONTHS{$mon};
    }
    else {
	warn("month \"$mon\" unknown in date \"$_\"");
	$mon = 0;
    }
    $tz = uc($tz);
    if (defined($_822_TIME_ZONES{$tz})) {
	$tz = $_822_TIME_ZONES{$tz};
    }
    my($date_time) = Time::Local::timegm($sec, $min, $hour, $mday, $mon, $year);
    if ($tz =~ /^(-|\+?)(\d\d?)(\d\d)/s) {
	$date_time -= ($1 eq '-' ? -1 : +1) * 60 * ($2 * 60 + $3);
    } else {
	warn("timezone \"$tz\" unknown in date \"$_\"");
    }
    return $date_time;
}

# strips out comments
sub _parse_complex_date {
#TODO: NEED TO IMPLEMENT!
    local($_) = @_;
    die("unable to parse date: $_");
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
