# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Mail::Incoming;
use strict;
$Bivio::Mail::Incoming::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Mail::Incoming - parses an incoming mail message

=head1 SYNOPSIS

    use Bivio::Mail::Incoming;
    Bivio::Mail::Incoming->new($rfc822_ref);
    Bivio::Mail::Incoming->uninitialize();
    Bivio::Mail::Incoming->initialize($rfc822_ref);

=cut

use Bivio::UNIVERSAL;
@Bivio::Mail::Incoming::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Mail::Incoming> parses and maintains the state of an incoming mail
message.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Time::Local ();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
# Bivio::IO::Config->register;

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
my($_822_MAILBOX) = "(?:$_822_ADDR_SPEC|$_822_PHRASE\s+$_822_ROUTE_ADDR)";
my($_822_GROUP) = "$_822_PHRASE:(?:$_822_MAILBOX(?:,$_822_MAILBOX)*;";
my($_822_ADDRESS) = "(?:$_822_MAILBOX|$_822_GROUP)";
my($_822_DAY) = "[a-zA-Z]{3}";
my($_822_DATE) = "(\d\d?)\s*([a-zA-Z]{3})\s*(\d{2,4})";
# Be flexible with times, as I have seen 17:9:12
my($_822_TIME) = "(\d\d?):(\d\d?):(\d\d?)\s*([-+\w]{1,5})";
my($_822_DATE_TIME) = "(?:$_822_DAY\s*,)?\s*$_822_DATE\s*$_822_TIME";
my(%_822_MONTHS) = {
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
};
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

Create an instance and L<initialize|"initialize"> with I<rfc822>.

Note: the reference to I<rfc822> will be retained, so do not modify this value
until L<uninitialize|"uninitialize"> has been called or the object is
destroyed.

=cut

sub new {
    my($self) = &Bivio::UNIVERSAL::new(@_);
    my(undef, $rfc822) = @_;
    $self->initialize($rfc822);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_body_ref"></a>

=head2 get_body_ref() : string

=head2 get_body_ref(string_ref body)

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

=for html <a name="get_dttm"></a>

=head2 get_dttm() : time

Returns the date specified by the message

=cut

sub get_dttm {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return;
}

=for html <a name="get_errors_to"></a>

=head2 get_errors_to() : string

Returns the sender of the message, i.e. where errors should be sent to.

=cut

sub get_errors_to {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
#            o   The "Sender" field mailbox should be sent  notices  of
#                any  problems in transport or delivery of the original
#                messages.  If there is no  "Sender"  field,  then  the
#                "From" field mailbox should be used.

    return;
}

=for html <a name="get_from_email"></a>

=head2 get_from_email() : string

Return the email address of the message.

=cut

sub get_from_email {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    exists($fields->{from_email}) && return $fields->{from_email};
    # 822: The  "Sender"  field  mailbox  should  NEVER  be  used
    #      automatically, in a recipient's reply message.
    my($from) = &_get_field($fields, 'from:')
	    || &_get_field($fields, 'apparently-from:');
    unless (defined($from)) {
	warn("no from in message");
	$fields->{from_name} = undef;
	return $fields->{from_email} = undef;
    }
    ($fields->{from_email}, $fields->{from_name}) = &_parse_addr($from);
    return $fields->{from_email};
}

=for html <a name="get_message_id"></a>

=head2 get_message_id() : string

Returns the Message-Id for this message.

=cut

sub get_message_id {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    exists($fields->{message_id}) && return $fields->{message_id};
    my($id) = &_get_field($fields, 'message_id');
    unless (defined($id)) {
	warn("no message-id");
	return $fields->{message_id} = undef;
    }
#RJN: Should really parse this, but I mean RIIILLY....
    $id =~ s/^\s+//;
    $id =~ s/\s+$//;
    return $fields->{message_id} = $id;
}

=for html <a name="get_recv_dttm"></a>

=head2 get_recv_dttm() : time

Returns the time the message was initialized.

=cut

sub get_recv_dttm {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{recv_dttm};
}

=for html <a name="get_reply_to_email"></a>

=head2 get_reply_to_email() : string

Returns the reply-to.  May be undef if no reply-to.

=cut

sub get_reply_to_email {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    exists($fields->{reply_to}) && return $fields->{reply_to};
    my($reply_to) = &_get_field($fields, 'reply-to:');
    unless (defined($reply_to)) {
	return $fields->{reply_to_email} = undef;
    }
    ($fields->{reply_to_email}, $fields->{reply_to_name})
	    = &_parse_addr($reply_to);
    return $fields->{reply_to_email};
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

=for html <a name="initialize"></a>

=head2 initialize(string_ref $rfc822)

Initializes the object with the reference supplied.

Note: the reference to I<rfc822> will be retained, so do not modify this value
until L<uninitialize|"uninitialize"> has been called or the object is
destroyed.

=cut

sub initialize {
    my($self, $rfc822) = @_;
# RJN: Turns out this is about the fastest way, since any way you
# clear a hash is expensive.  This is likely to generate more
# memory churn, but the objects are small..
    my($i) = index($$rfc822, "\n\n");
    my($h);
    if ($i >= 0) {
	$h = substr($$rfc822, 0, $i);
	# Account for \n\n
	$i += 2;
    }
    else {
	$h = $$rfc822;
	$i = length($$rfc822);
    }
    # unfold all headers in advance.  Makes other code simpler.
    #
    # [rfc882] Unfolding is accomplished by regarding CRLF immediately
    # followed by a LWSP-char as equivalent to the LWSP-char.
    # Can't use \s, because isn't locale specific.
    # RJN: Not handling quoted CRLF sequences which appear to be legitimate.
    #      The effect will be to lose quoted LF and replace it with a space.
    $h =~ s/\r?\n[ \t]/ /gs;
    $self->{$_PACKAGE} = {
	'rfc822' => $rfc822,
	# If there is no body, get_body will return empty string.
	'body_offset' => $i,
	# Must include the \n\n
	'header' => $h,
	'recv_dttm' => time,
    };
    return;
}

#=PRIVATE METHODS

sub _clean_comment {
    local($_) = @_;
    s/^\(// || die("not a comment");
    chop;
    s/\\(.)/$1/g;
    return $_;
}

sub _clean_quoted_string {
    local($_) = @_;
    s/^"// || die("not a quoted string");
    chop;
    s/\\(.)/$1/g;
    return $_;
}

# $name must be lc and ending with a ':'
sub _get_field {
    my($fields, $name) = @_;
    # May be that the field is undefined.
    unless (exists($fields->{$name})) {
	($fields->{$name}) = $fields->{header} =~ /^$name\s*(.*)/im;
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
# Probably part of Outlook
#
# Parses the first address in the field. If there are multiple
# addresses, only grabs the first one.
sub _parse_addr {
    local($_) = @_;
    s/^\s+//;
    my($n, $a);
    # Cases are optimized by their statistical counts.
    # Joe Bob <joe@bob.com>
    if (($n, $a) = /^($_822_ATOM_ONLY_PHRASE)\s*\<($_822_ATOM_ONLY_ADDR)\>/o) {
	return ($a, $n);
    }
    # "Joe Bob" <joe@bob.com>
    if (($n, $a) = /^$_822_QUOTED_STRING\s*\<($_822_ATOM_ONLY_ADDR)\>/o) {
	return ($a, &_clean_quoted_string($n));
    }
    # joe@bob.com -- grab first addr, not allowing comment
    if (($n, $a) = /^($_822_ATOM_ONLY_PHRASE)\s*(?:,|$)/o) {
	return ($a, $n);
    }
    # joe@bob.com (Joe Bob)
    if (($a, $n) = /^($_822_ATOM_ONLY_ADDR)\s*$_822_NOT_NESTED_COMMENT/o) {
	return ($a, &_clean_comment($n));
    }
    &_parse_complex_addr($_);
}

sub _parse_complex_addr {
#RJN: NEED TO IMPLEMENT!
    local($_) = @_;
    die("unable to parse address: $_");
}

sub _parse_date {
    local($_) = @_;
    my($mday, $mon, $year, $hour, $min, $sec, $tz) = /^$_822_DATE_TIME/o;
    defined($mday) || return &_parse_complex_addr($_);
    $mon = uc($mon);
    if (defined($_822_MONTHS{$mon})) {
	$mon = $_822_MONTHS{$mon};
    }
    else {
	warn("month \"$mon\" unknown in date \"$_\"");
	$mon = 0;
    }
    $tz = uc($mon);
    if (defined($_822_TIME_ZONES{$tz})) {
	$tz = $_822_TIME_ZONES{$tz};
    }
    my($dttm) = Time::Local::timegm($sec, $min, $hour, $mday, $mon, $year);
    if ($tz =~ /^(-|+?)(\d\d?)(\d\d)/) {
	$dttm = ($1 eq '-' ? +1 : -1) * ($2 * 60 + $3);
    } else {
	warn("timezone \"$tz\" unknown in date \"$_\"");
    }
    &_trace($_, ' -> ', $dttm) if $_TRACE;
    return $dttm;
}

# strips out comments
sub _parse_complex_date {
#RJN: NEED TO IMPLEMENT!
    local($_) = @_;
    die("unable to parse date: $_");
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
