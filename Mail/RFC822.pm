# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Mail::RFC822;
use strict;
$Bivio::Mail::RFC822::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::RFC822 - Defines the proper syntax for mail message headers

=head1 SYNOPSIS

    use Bivio::Mail::RFC822;
    Bivio::Mail::RFC822->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::Mail::RFC822::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Mail::RFC822>

=cut


=head1 CONSTANTS

=cut

sub CHAR {
    return '[\\0-\\177]';
}
sub ALPHA {
    return '[\\101-\\132\\141-\\172]';
}
sub DIGIT {
    return '[\\060-\\071]';
}
sub CTL {
    return '[\\0-\\037\\177-\\377]';
}
sub LWSP {
    return '[ \\t]';
}
sub SPECIALS {
    return '[][()<>@,;:\\\\".]';
}
sub ATOM {
    return '[^][()<>@,;:\\\\". \\000-\\040\\177-\\377]+';
}
sub QUOTED_STRING {
    return '"(?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^\\\\"])*)"';
}
sub DOMAIN_LITERAL {
    return '\\[(?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^][\\\\])*)\\]';
}
# 822 comments can be nested.  We test for simple comments and if
# that fails, we have to get complex.
sub NOT_NESTED_COMMENT {
    return '\\((?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^()\\\\])*)\\)';
}
sub WORD {
    return "(?:".&ATOM."|".&QUOTED_STRING.")";
}
sub PHRASE {
    return &WORD."(?:\\s+".&WORD.")*";
}
sub ATOM_ONLY_PHRASE {
    return &ATOM."(?:\\s+".&ATOM.")*";
}
sub LOCAL_PART {
    return &WORD."(?:\\.".&WORD.")*";
}
sub DOTTED_ATOMS {
    return &ATOM."(?:\\.".&ATOM.")*";
}
sub SUB_DOMAIN {
    return "(?:".&ATOM."|".&DOMAIN_LITERAL.")";
}
sub DOMAIN {
    return &SUB_DOMAIN."(?:\\.".&SUB_DOMAIN.")*";
}
sub ADDR_SPEC {
    return &LOCAL_PART."\@".&DOMAIN."";
}
sub ATOM_ONLY_ADDR {
    return &DOTTED_ATOMS."\@".&DOTTED_ATOMS;
}
sub ROUTE {
    return "\@".&DOMAIN."(?:,\@".&DOMAIN.")*:";
}
sub ROUTE_ADDR {
    return "<(?:".&ROUTE.")?".&ADDR_SPEC.">";
}
sub MAILBOX {
    return "(?:".&ADDR_SPEC."|(?:".&PHRASE."\\s+)*".&ROUTE_ADDR.")";
}
sub GROUP {
    return &PHRASE.":(?:".&MAILBOX."(?:,".&MAILBOX.")*;";
}
sub ADDRESS {
    return "(?:".&MAILBOX."|".&GROUP.")";
}
sub FIELD_NAME {
    return '[\\041-\\071\\073-\\176]+:';
}
sub DAY {
    return "[a-zA-Z]{3}";
}
sub DATE {
    return '(\\d\\d?)\\s*([a-zA-Z]{3})\\s*(\\d{2,4})';
}
sub TIME {
    return '(\\d\\d?):(\\d\\d?):(\\d\\d?)\\s*([-+\\w]{1,5})';
}
sub DATE_TIME {
    return "(?:".&DAY."\\s*,)?\\s*".&DATE."\\s*".&TIME;
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
           };
}

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
