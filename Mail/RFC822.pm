# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Mail::RFC822;
use strict;
$Bivio::Mail::RFC822::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::RFC822 - Defines the proper syntax for mail message headers

=head1 SYNOPSIS

    use Bivio::Mail::RFC822;

=cut

use Bivio::UNIVERSAL;
@Bivio::Mail::RFC822::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Mail::RFC822> offers regular expressions which are derived from the
augmented BNF specified in RFC 822.

=cut

=head1 CONSTANTS

=cut

=for html <a name="CHAR"></a>

=head2 CHAR : string

any ASCII character

=cut

sub CHAR {
    return '[\\0-\\177]';
}

=for html <a name="ALPHA"></a>

=head2 ALPHA : string

any ASCII alphabetic character

=cut

sub ALPHA {
    return '[\\101-\\132\\141-\\172]';
}

=for html <a name="DIGIT"></a>

=head2 DIGIT : string

any ASCII decimal digit

=cut

sub DIGIT {
    return '[\\060-\\071]';
}

=for html <a name="CTL"></a>

=head2 CTL : string

any ASCII control character and DEL

=cut

sub CTL {
    return '[\\0-\\037\\177]';
}

=for html <a name="LWSP"></a>

=head2 LWSP : string

Linear white-space

=cut

sub LWSP {
    return '[ \\t]';
}

=for html <a name="SPECIALS"></a>

=head2 SPECIALS : string

Special characters which must be in quoted-string, to use within a word.

=cut

sub SPECIALS {
    return '[][()<>@,;:\\\\".]';
}

=for html <a name="TSPECIALS"></a>

=head2 TSPECIALS : string

Tspecial characters which must be in quoted-string, to use within a token.

=cut

sub TSPECIALS {
    return '[][()<>@,;:\\\\/".]';
}

=for html <a name="ATOM"></a>

=head2 ATOM : string

any CHAR except specials, SPACE and CTLs

=cut

sub ATOM {
    return '[^][()<>@,;:\\\\". \\000-\\040\\177]+';
}

=for html <a name="QUOTED_STRING"></a>

=head2 QUOTED_STRING : string

Regular qouted text or quoted chars

=cut

sub QUOTED_STRING {
    return '"(?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^\\\\"])*)"';
}

=for html <a name="DOMAIN_LITERAL"></a>

=head2 DOMAIN_LITERAL : string

dtext          = any CHAR excluding "[", ]", "\" & CR, & including linear-white-space
quoted-pair    = "\" CHAR
domain-literal = "[" *(dtext / quoted-pair) "]"

=cut

sub DOMAIN_LITERAL {
    return '\\[(?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^][\\\\])*)\\]';
}

=for html <a name="NOT_NESTED_COMMENT"></a>

=head2 NOT_NESTED_COMMENT : string

822 comments can be nested.  We test for simple comments and if
that fails, we have to get complex.

ctext   = any CHAR excluding "[", ]", "\" & CR, & including linear-white-space
comment = "(" *(ctext / quoted-pair / comment) ")"

=cut

sub NOT_NESTED_COMMENT {
    return '\\((?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^()\\\\])*)\\)';
}

=for html <a name="WORD"></a>

=head2 WORD : string

word = atom / quoted-string

=cut

sub WORD {
    return "(?:". ATOM() . "|" . QUOTED_STRING() .")";
}

=for html <a name="PHRASE"></a>

=head2 PHRASE : string

sequence of words

=cut

sub PHRASE {
    return WORD() . "(?:\\s+" . WORD() .")*";
}

=for html <a name="ATOM_ONLY_PHRASE"></a>

=head2 ATOM_ONLY_PHRASE : string

sequence of atoms

=cut

sub ATOM_ONLY_PHRASE {
    return ATOM() . "(?:\\s+" . ATOM() . ")*";
}

=for html <a name="LOCAL_PART"></a>

=head2 LOCAL_PART : string

sequence of dotted words

=cut

sub LOCAL_PART {
    return WORD() . "(?:\\." . WORD() .")*";
}

=for html <a name="DOTTED_ATOMS"></a>

=head2 DOTTED_ATOMS : string

sequence of dotted atoms

=cut

sub DOTTED_ATOMS {
    return ATOM() . "(?:\\." . ATOM() . ")*";
}

=for html <a name="SUB_DOMAIN"></a>

=head2 SUB_DOMAIN : string

domain-ref = atom
sub-domain = domain-ref / domain-literal

=cut

sub SUB_DOMAIN {
    return "(?:" . ATOM() . "|" . DOMAIN_LITERAL() . ")";
}

=for html <a name="DOMAIN"></a>

=head2 DOMAIN : string

sequence of sub-domains

=cut

sub DOMAIN {
    return SUB_DOMAIN() . "(?:\\." . SUB_DOMAIN() . ")*";
}

=for html <a name="ADDR_SPEC"></a>

=head2 ADDR_SPEC : string

global address

=cut

sub ADDR_SPEC {
    return LOCAL_PART() . "\@" . DOMAIN() . "";
}

=for html <a name="ATOM_ONLY_ADDR"></a>

=head2 ATOM_ONLY_ADDR : string



=cut

sub ATOM_ONLY_ADDR {
    return DOTTED_ATOMS() . "\@" . DOTTED_ATOMS();
}

=for html <a name="ROUTE"></a>

=head2 ROUTE : string

path-relative route

=cut

sub ROUTE {
    return "\@" . &DOMAIN . "(?:,\@" . &DOMAIN .")*:";
}

=for html <a name="ROUTE_ADDR"></a>

=head2 ROUTE_ADDR : string

route-addr = "<" [route] addr-spec ">"

=cut

sub ROUTE_ADDR {
    return "<(?:" . ROUTE() . ")?" . ADDR_SPEC() .">";
}

=for html <a name="MAILBOX"></a>

=head2 MAILBOX : string

simple address name & addr-spec

=cut

sub MAILBOX {
    return "(?:" . ADDR_SPEC() . "|(?:" . PHRASE() . "\\s+)*" . ROUTE_ADDR() . ")";
}

=for html <a name="GROUP"></a>

=head2 GROUP : string

group = phrase ":" [#mailbox] ";"

=cut

sub GROUP {
    return PHRASE() . ":(?:" . MAILBOX() . "(?:," . MAILBOX() . ")*;";
}

=for html <a name="ADDRESS"></a>

=head2 ADDRESS : string

one addressee named list

=cut

sub ADDRESS {
    return "(?:" . MAILBOX() . "|" . GROUP() .")";
}

=for html <a name="FIELD_NAME"></a>

=head2 FIELD_NAME : string

Header field name, any CHAR, excluding CTLs, SPACE, and ":"

=cut

sub FIELD_NAME {
    return '[\\041-\\071\\073-\\176]+:';
}

=for html <a name="DAY"></a>

=head2 DAY : string

day of week

=cut

sub DAY {
    return "[a-zA-Z]{3}";
}

=for html <a name="DATE"></a>

=head2 DATE : string

day month year

=cut

sub DATE {
    return '(\\d\\d?)\\s*([a-zA-Z]{3})\\s*(\\d{2,4})';
}

=for html <a name="TIME"></a>

=head2 TIME : string

hour timezone

Modifications to original spec:
 - Allow doublequotes in timezone field

TODO: Parse the following variations:

Thu Sep 21 16:15:07 2000

=cut

sub TIME {
    return '(\\d\\d?):(\\d\\d?)(?:|:(\\d\\d?))\\s+([\\(\\)\\-+"\\w]{1,5})';
}

=for html <a name="TIME2"></a>

=head2 TIME2 : string

hour (allow missing timezone field, return 0 instead)

Sat, 23 Sep 2000 17:27:48

=cut

sub TIME2 {
    return '(\\d\\d?):(\\d\\d?)(\\d\\d?)()';
}

=for html <a name="DATE_TIME"></a>

=head2 DATE_TIME : string

date-time  = [ day "," ] date time

=cut

sub DATE_TIME {
    return "(?:" . DAY() . "\\s*,)?\\s*" . DATE() . "\\s*" . TIME();
}

=for html <a name="DATE_TIME2"></a>

=head2 DATE_TIME2 : string

date-time2  = [ day "," ] date time2

Handle more variations with a separate TIME2 regexp

=cut

sub DATE_TIME2 {
    return "(?:" . DAY() . "\\s*,)?\\s*" . DATE() . "\\s*" . TIME2();
}

=for html <a name="MONTHS"></a>

=head2 MONTHS : hash_ref

Month names mapped to value 0-11

=cut

sub MONTHS {
    return {
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
}

=for html <a name="TIME_ZONES"></a>

=head2 TIME_ZONES : hash_ref

Time zone names mapped to GMT time offsets

=cut

sub TIME_ZONES {
    return {
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
        'HST' => -1100,
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
        'CET' => +100,
        'MET' => +100,
        'GST' => +1000,
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
    };
}

#=IMPORTS

#=VARIABLES

=head1 METHODS

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
