# Copyright (c) 2000-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Mail::RFC822;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ATOM_ONLY_PHRASE) = ATOM_ONLY_PHRASE();

sub ADDRESS {
    return "(?:" . MAILBOX() . "|" . GROUP() .")";
}

sub ADDR_SPEC {
    return LOCAL_PART() . "\@" . DOMAIN() . "";
}

sub ALPHA {
    return '[\\101-\\132\\141-\\172]';
}

sub ATOM {
    return '[^][()<>@,;:\\\\". \\000-\\040\\177]+';
}

sub ATOM_ONLY_ADDR {
    return DOTTED_ATOMS() . "\@" . DOTTED_ATOMS();
}

sub ATOM_ONLY_PHRASE {
    return ATOM() . "(?:\\s+" . ATOM() . ")*";
}

sub CHAR {
    return '[\\0-\\177]';
}

sub CTL {
    return '[\\0-\\037\\177]';
}

sub DATE {
    return '(\\d\\d?)\\s*([a-zA-Z]{3})\\s*(\\d{2,4})';
}

sub DATE_TIME {
    return "(?:" . DAY() . "\\s*,)?\\s*" . DATE() . "\\s*" . TIME();
}

sub DATE_TIME2 {
    # Handle more variations with a separate TIME2 regexp
    return "(?:" . DAY() . "\\s*,)?\\s*" . DATE() . "\\s*" . TIME2();
}

sub DAY {
    return "[a-zA-Z]{3}";
}

sub DIGIT {
    return '[\\060-\\071]';
}

sub DOMAIN {
    return SUB_DOMAIN() . "(?:\\." . SUB_DOMAIN() . ")*";
}

sub DOMAIN_LITERAL {
    return '\\[(?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^][\\\\])*)\\]';
}

sub DOTTED_ATOMS {
    return ATOM() . "(?:\\." . ATOM() . ")*";
}

sub FIELD_NAME {
    return '[\\041-\\071\\073-\\176]+:';
}

sub GROUP {
    return PHRASE() . ":(?:" . MAILBOX() . "(?:," . MAILBOX() . ")*;";
}

sub LOCAL_PART {
    return WORD() . "(?:\\." . WORD() .")*";
}

sub LWSP {
    return '[ \\t]';
}

sub MAILBOX {
    return "(?:" . ADDR_SPEC() . "|(?:" . PHRASE() . "\\s+)*" . ROUTE_ADDR() . ")";
}

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

sub NOT_NESTED_COMMENT {
    return '\\((?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^()\\\\])*)\\)';
}

sub PHRASE {
    return WORD() . "(?:\\s+" . WORD() .")*";
}

sub QUOTED_STRING {
    return '"(?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^\\\\"])*)"';
}

sub ROUTE {
    return "\@" . &DOMAIN . "(?:,\@" . &DOMAIN .")*:";
}

sub ROUTE_ADDR {
    return "<(?:" . ROUTE() . ")?" . ADDR_SPEC() .">";
}

sub SPECIALS {
    return '[][()<>@,;:\\\\".]';
}

sub SUB_DOMAIN {
    return "(?:" . ATOM() . "|" . DOMAIN_LITERAL() . ")";
}

sub TIME {
    return '(\\d\\d?):(\\d\\d?)(?:|:(\\d\\d?))\\s+([\\(\\)\\-+"\\w]{1,5})';
}

sub TIME2 {
    return '(\\d\\d?):(\\d\\d?)(\\d\\d?)()';
}

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

sub TSPECIALS {
    return '[][()<>@,;:\\\\/".]';
}

sub WORD {
    return "(?:". ATOM() . "|" . QUOTED_STRING() .")";
}

sub escape_header_phrase {
    my(undef, $value) = @_;
    return ''
	unless defined($value);
    $value =~ s/^\s+|\s+$//g;
    return ''
	unless length($value);
    return $value
	if $value =~ /^$_ATOM_ONLY_PHRASE$/o;
    $value =~ s/(["\\])/\\$1/g;
    return '"'.$value.'"';
}

1;
