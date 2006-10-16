# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Mail::Address;
use strict;
$Bivio::Mail::Address::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::Address - parses e-mail addresses according to RFC 822

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Mail::Address;

=cut

use Bivio::UNIVERSAL;
@Bivio::Mail::Address::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Mail::Address> parses e-mail addresses as specified in the
BNF syntax in RFC 822.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::Mail::RFC822;

#=VARIABLES
# Copy constant strings into locals, can't use subroutine calls in regexps
my($ATOM_ONLY_PHRASE) = Bivio::Mail::RFC822->ATOM_ONLY_PHRASE;
my($ATOM_ONLY_ADDR) = Bivio::Mail::RFC822->ATOM_ONLY_ADDR;
my($QUOTED_STRING) = Bivio::Mail::RFC822->QUOTED_STRING;
my($NOT_NESTED_COMMENT) = Bivio::Mail::RFC822->NOT_NESTED_COMMENT;
my($MAILBOX) = Bivio::Mail::RFC822->MAILBOX;
my($ADDR_SPEC) = Bivio::Mail::RFC822->ADDR_SPEC;
my($ROUTE_ADDR) = Bivio::Mail::RFC822->ROUTE_ADDR;
my($PHRASE) = Bivio::Mail::RFC822->PHRASE;
my($LOCAL_PART) = Bivio::Mail::RFC822->LOCAL_PART;

=head1 METHODS

=cut

=for html <a name="parse"></a>

=head2 static parse(string addr) : array

822:
    For purposes of display, and when passing  such  struc-
    tured information to other systems, such as mail proto-
    col  services,  there  must  be  NO  linear-white-space
    between  <word>s  that are separated by period (".") or
    at-sign ("@") and exactly one SPACE between  all  other
    <word>s.  Also, headers should be in a folded form.

    There is one type of bracket which must occur in matched pairs
    and may have pairs nested within each other:

	 o   Parentheses ("(" and ")") are used  to  indicate  com-
	     ments.

    There are three types of brackets which must occur in  matched
    pairs, and which may NOT be nested:

	 o   Colon/semi-colon (":" and ";") are   used  in  address
	     specifications  to  indicate that the included list of
	     addresses are to be treated as a group.

	 o   Angle brackets ("<" and ">")  are  generally  used  to
	     indicate  the  presence of a one machine-usable refer-
	     ence (e.g., delimiting mailboxes), possibly  including
	     source-routing to the machine.

	 o   Square brackets ("[" and "]") are used to indicate the
	     presence  of  a  domain-literal, which the appropriate
	     name-domain  is  to  use  directly,  bypassing  normal
	     name-resolution mechanisms.

These appear after -----Original Message-----
    From: Jeffrey Richer [SMTP:jricher@inet.net]
    From: . <winsv@ix.netcom.com>
    From: <MNatto@aol.com>
Probably part of Outlook.  Not a problem for us as the "Original Message"
is not an 822 thing.

Parses the first address in the field. If there are multiple
addresses, only grabs the first one.

Returns an array (address, name) or (undef, undef) if the input
could not be parse successfully.

=cut

sub parse {
    my(undef, $addr) = @_;
    my($REST) = '\s*(?:,\s*(.*)?)?$';
    local($_) = $addr;
    s/^\s+//s;
    my($n, $a, $r);
    # Cases are optimized by their statistical counts.
    # Joe Bob <joe@bob.com>
    if (($n, $a, $r) = /^($ATOM_ONLY_PHRASE)\s*\<($ATOM_ONLY_ADDR)\>$REST/os) {
	return ($a, $n, $r);
    }
    # "Joe Bob" <joe@bob.com>
    if (($n, $a, $r) = /^($QUOTED_STRING)\s*\<($ATOM_ONLY_ADDR)\>$REST/os) {
	return ($a, _clean_quoted_string($n), $r);
    }
    # joe@bob.com -- grab first addr, not allowing comment
    if (($a, $r) = m!^($ATOM_ONLY_ADDR)$REST!os) {
	return ($a, undef, $r);
    }
    # joe@bob.com (Joe Bob)
    if (($a, $n, $r) = m!^($ATOM_ONLY_ADDR)\s*($NOT_NESTED_COMMENT)$REST!os) {
	return ($a, _clean_comment($n), $r);
    }
    if (($a, $n, $r) = /^($MAILBOX)\s*((?:$NOT_NESTED_COMMENT)*)$REST/os) {
#TODO: Need to make sure we hit 99.99% of addresses with this
#      We don't handle groups. ok?  What about "Undisclosed Recipients:;"?
	# complex@addr (My comment) AND complex@addr
	if ($a =~ /^$ADDR_SPEC$/os) {
	    # $a is an address, no further parsing necessary
	    return ($a, length($n) ? _clean_comment($n) : undef, $r);
	}
#TODO: Die if $REST not empty?
	# $MAILBOX: <complex@addr>
	if (($a) = /^($ROUTE_ADDR)/) {
	    return (_clean_route_addr($a), undef, undef);
	}
	# $MAILBOX: My Comment <complex@addr>
	if (($n, $a) = /^($PHRASE)\s+($ROUTE_ADDR)/) {
	    return (_clean_route_addr($a), $n, undef);
	}
#TODO: error or assert_fail
	Bivio::Die->die('regexps incorrect, cannot parse: ', $_);
    }

    # Local delivery: root
    if (($a, $r) = m!^($LOCAL_PART)$REST!os) {
	return ($a, undef, $r);
    }

    # Illegal implementations follow:
    #
    # PoorImpl.com <hackers@foo.com>
    if (($n, $a, $r) = /^([^<>"]+)\s*\<($ATOM_ONLY_ADDR)\>$REST/os) {
	$n =~ s/\s+$//;
	return ($a, _clean_quoted_string(qq{"$n"}), $r);
    }

    Bivio::IO::Alert->warn('Unable to parse address: ', $_);
    return (undef, undef, undef);
}

=for html <a name="parse_list"></a>

=head2 static parse_list(string addr_list) : array_ref

Parse a list of email addresses.  Dies on invalid address.

=cut

sub parse_list {
    my($proto, $addr_list) = @_;
    return []
	unless $addr_list;
    my($addrs) = [];
    my($addr);
    while (1) {
	my($old_list) = $addr_list;
	($addr, undef, $addr_list) = $proto->parse($addr_list);
	Bivio::Die->die($old_list, ': invalid address')
	    unless $addr;
	push(@$addrs, $addr);
	last unless $addr_list;
	Bivio::Die->die($old_list, ': parse() did not trim addr_list')
	    if length($addr_list) > length($old_list);
    }
    return $addrs;
}

=for html <a name="parse_list_strict"></a>

=head2 static parse_list_strict(string list_string, array_ref error_list) : arrary_ref

Parse a string into a list of email addresses. Only literal email
addresses are allowed--RFC822 comments and extensions are not
supported.

Errors will be pushed onto error_list, if present.

=cut

sub parse_list_strict {
    my($proto, $list_string, $error_list) = @_;
    my($email_list) = [];

    foreach my $email ($list_string =~ /([^\s,]+)/gs) {
        my($parsed) = Bivio::Type::Email->from_literal($email);
        if ($parsed) {
            push(@$email_list, $parsed);
        }
	elsif (ref($error_list) eq 'ARRAY') {
	    push(@$error_list, $email . ' is not a valid email address.');
	}
    }
    return $email_list;
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

=head1 COPYRIGHT

Copyright (c) 2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
