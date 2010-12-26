# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::String;
use strict;
use Bivio::Base 'Bivio.Type';
use Text::Tabs ();
# char => [utf-8, windows-1252]
my($_TRANSLITERATE) = {
    '-' => [qr{[\x{2010}-\x{2013}]}, qr{\x96}],
    '--' => [qr{[\x{2014}-\x{2015}]}, qr{\x97}],
    "'" => [qr{[\x{2018}-\x{201B}]}, qr{[\x91\x92]}],
    '"' => [qr{[\x{201C}-\x{201F}]}, qr{[\x93\x94]}],
    '...' => [qr{\x{2026}}, qr{\x85}],
    '*' => [qr{[\x{2022}\x{20B7}]}, qr{[\x95\xB7]}],
    '(TM)' => [qr{\x{2122}}, qr{\x99}],
    ' ' => [qr{\x{00A0}}, qr{\xA0}],
    '(C)' => [qr{\x{00A9}}, qr{\xA9}],
    '<<' => [qr{\x{00AB}}, qr{\xAB}],
    '>>' => [qr{\x{00BB}}, qr{\xBB}],
    '(R)' => [qr{\x{00AE}}, qr{\xAE}],
    '+/-' => [qr{\x{00B1}}, qr{\xB1}],
    '1/4' => [qr{\x{00BC}}, qr{\xBC}],
    '1/2' => [qr{\x{00BD}}, qr{\xBD}],
    '3/4' => [qr{\x{00BE}}, qr{\xBE}],
};

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub canonicalize_and_excerpt {
    my($proto, $value, $max_words) = @_;
    $max_words ||= 45;
#TODO: Split on paragraphs first.  Google groups seems to do this
    my($words) = [grep(
	length($_),
	split(
	    ' ',
	    ${$proto->canonicalize_newlines(
		$proto->canonicalize_newlines($value),
	    )}, $max_words,
	),
    )];
    if (@$words >= $max_words) {
	pop(@$words);
	push(@$words, '...');
    }
    return join(' ', @$words);
}

sub canonicalize_charset {
    my(undef, $value) = @_;
    my($v) = ref($value) ? $value : \$value;
    return _clean_whitespace(_clean_utf8($v) || _clean_1252($v) || $v);
}

sub canonicalize_newlines {
    my(undef, $value) = @_;
    my($v) = ref($value) ? $value : \$value;
    $$v =~ s/\r\n|\r/\n/sg;
    $$v =~ s/^[ \t]+$//mg;
    $$v =~ s/\n+$//sg;
    $$v .= "\n"
	if length($$v);
    return $v;
}

sub clean_and_trim {
    my($proto, $value) = @_;
    b_die('value must be no-zero length')
	unless defined($value) && length($value);
    $value .= $value
	while length($value) < $proto->get_min_width;
    return substr($value, 0, $proto->get_width);
}

sub compare {
    my($proto, $left, $right) = @_;
    return $proto->compare_defined(
	defined($left) ? $left : '',
	defined($right) ? $right : '',
    );
}

sub from_literal {
    my($proto, $value) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return (undef, undef)
	unless defined($value) && length($value);
    if (my $mw = $proto->get_min_width) {
	return (undef, Bivio::TypeError->TOO_SHORT)
	    if length($value) < $mw;
    }
    return (undef, Bivio::TypeError->TOO_LONG)
	if length($value) > $proto->get_width;
    return $value;
}

sub get_min_width {
    return 0;
}

sub get_width {
    return 0x7fffffff;
}

sub to_camel_case {
    return _camel_case($_[1], ' ');
}

sub to_camel_case_identifier {
    return _camel_case($_[1], '');
}

sub wrap_lines {
    my($proto, $value, $width) = @_;
    $width = 72 unless $width;
    my(@lines) = (split /\n/, ref($value) ? $$value : $value);
    @lines = Text::Tabs::expand(@lines);
    my($formatted) = [];
    my($indent) = 0;
    foreach my $line (@lines) {
        $line =~ s/\s+$//;
        while (defined($line) && length($line) > $width) {
            _wrap_line($formatted, \$line, $indent, $width);
        }
        push(@$formatted, $line) if defined($line);
    }
    return join("\n", @$formatted, '');
}

sub _camel_case {
    my($value, $sep) = @_;
    return !$value ? $value
	: join($sep, map(ucfirst(lc($_)), split(/[\W_]+/, $value)));
}

sub _clean_1252 {
    # See http://en.wikipedia.org/wiki/WINDOWS-1252
    my($value) = @_;
    my($res) = _map_characters($value, 1);
    return undef unless $res;
    $$value =~ s/\x0D?\x0A?$//g;
    $$value =~ s/[\x00-\x09\x0B-\x1F\x7F\x81]//g;
    $$value =~ s/[\xB0\xB7]//g;
    $$value =~ s/[\xDE]//g;
    return $value;
}

sub _clean_utf8 {
    my($value) = @_;
    return undef
	unless utf8::valid($$value);
    utf8::decode($$value);
    my($res) = _map_characters($value, 0);
    return undef
	unless $res;
    utf8::encode($$value);
    return $value;
}

sub _clean_whitespace {
    my($value) = @_;
    $$value =~ s/\t/ /sg;
    $$value =~ s/\r\n/\n/sg;
    $$value =~ s/\r/\n/sg;
    $$value =~ s/ +$//mg;
    $$value =~ s/^\s*|\s*$//sg;
    return $value;
}

sub _map_characters {
    my($value, $map) = @_;
    my($match) = 0;
    while (my($to, $from) = each(%$_TRANSLITERATE)) {
        $match = 1
	    if $$value =~ s/$from->[$map]/$to/g;
    }
    return $match ? $value : undef;
}

sub _wrap_line {
    my($formatted, $line, $indent, $width) = @_;
    $$line =~ /(^\s*(|[\-\*])\s+)/;
    $indent = defined($1) ? substr($1, 0, $width) : '';
    my($white_pos) = rindex($$line, ' ', $width);
    $white_pos = index($$line, ' ', $width) if $white_pos < length($indent);
    # Line cannot be broken if no white-space found or quoted
    if ($white_pos == -1 || $$line =~ /^\s*[>]/) {
        push(@$formatted, $$line);
        undef($$line);
    }
    else {
        my($wrapped) = substr($$line, 0, $white_pos);
        push(@$formatted, $wrapped);
        $$line = substr($$line, $white_pos);
        $$line =~ s/^\s+/' ' x length($indent)/e;
    }
    return;
}

1;
