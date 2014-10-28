# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::String;
use strict;
use Bivio::Base 'Bivio.Type';
use Text::Tabs ();
# char => [utf-8, windows-1252]
my($_TRANSLITERATE) = {
    '-' => [qr{[\x{0096}\x{2010}-\x{2013}]}, qr{\x96}],
    '--' => [qr{[\x{0097}\x{2014}-\x{2015}]}, qr{\x97}],
    "'" => [qr{[\x{0091}\x{0092}\x{2018}-\x{201B}\x{2BC}\x{2032}]}, qr{[\x91\x92\xb4]}],
    '"' => [qr{[\x{0093}\x{0094}\x{201C}-\x{201F}\x{2033}]}, qr{[\x93\x94]}],
    '...' => [qr{[\x{0085}\x{2026}]}, qr{\x85}],
    '*' => [qr{[\x{0095}\x{2022}\x{20B7}]}, qr{[\x95\xB7]}],
    '(TM)' => [qr{[\x{2122}\x{0099}]}, qr{\x99}],
    ' ' => [qr{\x{00A0}}, qr{\xA0}],
    '(C)' => [qr{\x{00A9}}, qr{\xA9}],
    '<<' => [qr{\x{00AB}}, qr{\xAB}],
    '>>' => [qr{\x{00BB}}, qr{\xBB}],
    '<-' => [qr{\x{2190}}],
    '->' => [qr{\x{2192}}],
    '(R)' => [qr{\x{00AE}}, qr{\xAE}],
    '+/-' => [qr{\x{00B1}}, qr{\xB1}],
    '1/4' => [qr{\x{00BC}}, qr{\xBC}],
    '1/2' => [qr{\x{00BD}}, qr{\xBD}],
    '3/4' => [qr{\x{00BE}}, qr{\xBE}],
    ' ' => [qr{[\x{00A0}\x{2028}\x{2009}]}, qr{\xA0}],
    '' => [qr{[\x{00AD}\x{200B}]}, qr{\xAD}],
#TODO: remove these when we support unicode    
    'A' => [qr{[\x{00C0}-\x{00C5}]}, qr{[\xC0-\xC5]}],
    'AE' => [qr{\x00C6}, qr{[\xC6]}],
    'C' => [qw{\x00C7}, qr{[\xC7]}],
    'E' => [qr{[\x{00C8}-\x{00CB}]}, qr{[\xC8-\xCB]}],
    'I' => [qr{[\x{00CC}-\x{00CF}]}, qr{[\xCC-\xCF]}],
    'N' => [qr{[\x{00D1}]}, qr{[\xD1]}],
    'O' => [qr{[\x{00D2}-\x{00D6}]}, qr{[\xD2-\xD6]}],
    'U' => [qr{[\x{00D9}-\x{00DC}]}, qr{[\xD9-\xDC]}],
    'Y' => [qr{\x{00DD}}, qr{\xDD}],
    'a' => [qr{[\x{00E0}-\x{00E5}]}, qr{[\xE0-\xE5]}],
    'ae' => [qr{\x00E6}, qr{\xE6}],
    'c' => [qr{\x00E7}, qr{\xE7}],
    'e' => [qr{[\x{00E8}-\x{00EB}]}, qr{[\xE8-\xEB]}],
    'fi' => [qr{[\x{fb01}]}, qr{[\xDE]}],
    'fl' => [qr{[\x{fb02}]}, qr{[\xDF]}],
    'i' => [qr{[\x{00EC}-\x{00EF}]}, qr{[\xEC-\xEF]}],
    'n' => [qr{[\x{00F1}]}, qr{[\xF1]}],
    'o' => [qr{[\x{00F2}-\x{00F6}]}, qr{[\xF2-\xF6]}],
    'u' => [qr{[\x{00F9}-\x{00FC}]}, qr{[\xF9-\xFC]}],
    'y' => [qr{\x{00FD}}, qr{\xFD}],
};


sub canonicalize_and_excerpt {
    my($proto, $value, $max_words, $no_ellipsis) = @_;
    my($v, $return) = _ref($value);
    return $v
	if $return;
    # So we are re-entrant.  If there was an ellipsis in the actual text, so be it.
    $$v =~ s/\s+\.{3}$//;
    # remove repeating symbols, ex ---
    $$v =~ s/[#\$\%&*+\-.:^_~<=>@~]{3,}/ /g;
    $max_words ||= 45;
#TODO: Split on paragraphs first.  Google groups seems to do this
    my($words) = [grep(
	length($_),
	split(
	    ' ',
	    ${$proto->canonicalize_charset(
		$proto->canonicalize_newlines($v),
	    )},
	    $max_words + 1,
	),
    )];
    if (@$words > $max_words) {
	pop(@$words);
	push(@$words, '...')
	    unless $no_ellipsis;
    }
    return \(join(' ', @$words));
}

sub canonicalize_charset {
    my(undef, $value) = @_;
    my($v, $return) = _ref($value);
    return $v
	if $return;
    return _clean_whitespace(_clean_utf8($v) || _clean_1252($v) || $v);
}

sub canonicalize_newlines {
    my(undef, $value) = @_;
    my($v, $return) = _ref($value);
    return $v
	if $return;
    $$v =~ s/\r\n|\r/\n/sg;
    $$v =~ s/^[ \t]+$//mg;
    $$v =~ s/\n+$//sg;
    $$v .= "\n"
	if length($$v);
    return $v;
}

sub clean_and_trim {
    my($proto, $value) = @_;
    my($v, $return) = _ref($value);
    return $v
	if $return;
    $value .= $value
	while length($value) < $proto->get_min_width;
    return utf8::is_utf8($value)
	? _trim_utf8($proto, $value)
	: substr($value, 0, $proto->get_width);
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
	my($regexp) = $from->[$map];
	next unless $regexp;
        $match = 1
	    if $$value =~ s/$regexp/$to/g;
    }
    return $match ? $value : undef;
}

sub _ref {
    my($value) = @_;
    my($v) = ref($value) ? $value : \$value;
    return ($v, 0)
	if defined($$v) && length($$v);
    $$v = '';
    return ($v, 1);
}

sub _size_in_bytes {
    my($proto, $value) = @_;
    use bytes;
    return bytes::length($value);
}

sub _trim_utf8 {
    my($proto, $value) = @_;
    my($width) = $proto->get_width;
    my($current) = $width;

    while (_size_in_bytes($proto, $value) > $width) {
	$value = substr($value, 0, --$current);
    }
    return $value;
}

1;
