# Copyright (c) 2000 bivio, Inc.  All rights reserved.
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
my($_PACKAGE) = __PACKAGE__;
# Copy constant strings into locals, can't use subroutine calls in regexps
my($ATOM_ONLY_PHRASE) = Bivio::Mail::RFC822->ATOM_ONLY_PHRASE;
my($ATOM_ONLY_ADDR) = Bivio::Mail::RFC822->ATOM_ONLY_ADDR;
my($QUOTED_STRING) = Bivio::Mail::RFC822->QUOTED_STRING;
my($NOT_NESTED_COMMENT) = Bivio::Mail::RFC822->NOT_NESTED_COMMENT;
my($MAILBOX) = Bivio::Mail::RFC822->MAILBOX;
my($ADDR_SPEC) = Bivio::Mail::RFC822->ADDR_SPEC;
my($ROUTE_ADDR) = Bivio::Mail::RFC822->ROUTE_ADDR;
my($PHRASE) = Bivio::Mail::RFC822->PHRASE;

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
    local($_) = $addr;
    s/^\s+//s;
    my($n, $a);
    # Cases are optimized by their statistical counts.
    # Joe Bob <joe@bob.com>
    if (($n, $a) = /^($ATOM_ONLY_PHRASE)\s*\<($ATOM_ONLY_ADDR)\>/os) {
	return ($a, $n);
    }
    # "Joe Bob" <joe@bob.com>
    if (($n, $a) = /^($QUOTED_STRING)\s*\<($ATOM_ONLY_ADDR)\>/os) {
	return ($a, &_clean_quoted_string($n));
    }
    # joe@bob.com -- grab first addr, not allowing comment
    if (($a) = m!^($ATOM_ONLY_ADDR)\s*(?:,|$)!os) {
	return ($a, undef);
    }
    # joe@bob.com (Joe Bob)
    if (($a, $n) = m!^($ATOM_ONLY_ADDR)\s*($NOT_NESTED_COMMENT)!os) {
	return ($a, &_clean_comment($n));
    }
    if (($a, $n) = /^($MAILBOX)\s*((?:$NOT_NESTED_COMMENT)*)/os) {
#TODO: Need to make sure we hit 99.99% of addresses with this
#      We don't handle groups. ok?  What about "Undisclosed Recipients:;"?
	# complex@addr (My comment) AND complex@addr
	if ($a =~ /^$ADDR_SPEC$/) {
	    # $a is an address, no further parsing necessary
	    return ($a, length($n) ? &_clean_comment($n) : $n);
	}
	# $MAILBOX: <complex@addr>
	if (($a) = /^($ROUTE_ADDR)/) {
	    return (&_clean_route_addr($a), undef);
	}
	# $MAILBOX: My Comment <complex@addr>
	if (($n, $a) = /^($PHRASE)\s+($ROUTE_ADDR)/) {
	    return (&_clean_route_addr($a), $n);
	}
#TODO: error or assert_fail
	Bivio::Die->die('regexps incorrect, cannot parse: ', $_);
    }
    Bivio::IO::Alert->warn('Unable to parse address: ', $_);
    return (undef, undef);
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

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
