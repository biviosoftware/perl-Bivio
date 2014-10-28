# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::MIME::JSON;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

my($_IDI) = __PACKAGE__->instance_data_index;

# Using BNF at http://www.json.org/
# expanded to allow strings in single quote and unquoted object keys

sub from_text {
    my($proto, $text, $options) = @_;
    my($self) = $proto->new;
    my($fields) = $self->[$_IDI] = {
	text => ref($text) ? $text : \$text,
	char_count => 0,
	options => $options || {},
    };
    my($res) = _parse_text($self);
    b_die('leftover data at char index: ', $fields->{char_count})
	if length(_peek_char($self, 1));
    return $res;
}

sub to_text {
    b_die('must pass value')
	if @_ < 2;
    my($proto, $value) = @_;
    my($res);

    if (! defined($value)) {
	$res = 'null';
    }
    elsif (! ref($value)) {
	$value =~ s{("|\\|/)}{\\$1}g;
#TODO: Why is this a join
	$res = join('', '"', $value, '"');
    }
    elsif (ref($value) eq 'HASH') {
	$res = '{'
	    . join(',',
		   map(join(':', ${$proto->to_text($_)},
		       ${$proto->to_text($value->{$_})}), keys(%$value)),
	    ) . '}';
    }
    elsif (ref($value) eq 'ARRAY') {
	$res = '['
	    . join(',', map(${$proto->to_text($_)}, @$value))
	    . ']';
    }
    elsif (Bivio::UNIVERSAL->b_can('as_json', $value)) {
	$res = $value->as_json;
    }
    else {
	b_die($value);
    }
    return \$res;
}

sub _next_char {
    my($self, $expected_char) = @_;
    my($fields) = $self->[$_IDI];
    my($res) = _peek_char($self);
    b_die('unexpected end of input') unless length($res);
    b_die('unexpected char: ', $res, ' != ', $expected_char)
	if defined($expected_char) && $res ne $expected_char;
    $fields->{char_count}++;
    return $res;
}

sub _parse_array {
    my($self) = @_;
    my($res) = [];
    _next_char($self, '[');

    while (_peek_char($self, 1) ne ']') {
	push(@$res, _parse_text($self));
	_next_char($self, ',')
	    unless _peek_char($self, 1) eq ']';
    }
    _next_char($self, ']');
    return $res;
}

sub _parse_constant {
    my($self, $expected_value) = @_;
    my($fields) = $self->[$_IDI];
    my($literal_values) = $fields->{options}->{literal_values} || {};
    foreach my $expected_char (split('', $expected_value)) {
	_next_char($self, $expected_char);
    }
    return $literal_values->{$expected_value}
	if exists($literal_values->{$expected_value});
    return $expected_value;
}

sub _parse_digits {
    my($self) = @_;
    my($res) = _next_char($self);
    b_die('expecting digit but found: ', $res)
	unless $res =~ /\d/;

    while (_peek_char($self) =~ /\d/) {
	$res .= _next_char($self);
    }
    return $res;
}

sub _parse_number {
    my($self) = @_;
    my($res) = '';

    if (_peek_char($self) eq '-') {
	$res .= _next_char($self, '-');
    }
    $res .= _parse_digits($self);

    if (_peek_char($self) eq '.') {
	$res .= _next_char($self, '.') . _parse_digits($self);
    }

    if (_peek_char($self) =~ /e/i) {
	$res .= lc(_next_char($self))
	    . (_peek_char($self) =~ /\+|\-/
	        ? _next_char($self)
		: '')
	    . _parse_digits($self);
    }
    return $res;
}

sub _parse_object {
    my($self) = @_;
    my($res) = {};
    _next_char($self, '{');

    while (_peek_char($self, 1) ne '}') {
	my($k) = _parse_string($self, ':');
	_skip_whitespace($self);
	_next_char($self, ':');
	b_die('key exists: ', $k, ' object: ', $res)
	    if exists($res->{$k});
	$res->{$k} = _parse_text($self);
	_next_char($self, ',')
	    unless _peek_char($self, 1) eq '}';
    }
    _next_char($self, '}');
    return $res;
}

sub _parse_string {
    my($self, $end_char) = @_;
    if (_peek_char($self) =~ /'|"/) {
	$end_char = _next_char($self);
    }
    else {
	b_die('invalid quote char')
	    unless $end_char;
    }
    my($res) = _parse_unescaped_string($self, $end_char);
    unless (defined($res)) {
        $res = '';
        while (_peek_char($self) ne $end_char) {
            my($c) = _next_char($self);

            if ($c eq '\\') {
                $c = _next_char($self);

                if ($c eq 'n') {
                    $res .= "\n";
                } elsif ($c eq 't') {
                    $res .= "\t";
                } elsif ($c =~ /b|f|r/) {
                    # ignore backspace, formfeed, or cr
                } elsif ($c =~ m{"|\\|/}) {
                    $res .= $c;
                } elsif ($c eq 'u') {
                    $res .= _parse_unicode_char($self);
		} elsif ($c eq "'" && $end_char eq "'") {
                    $res .= $c;
                } else {
                    b_die('unexpected char prefixed with backslash: ', $c);
                }
            } else {
                $res .= $c;
            }
        }
    }
    _next_char($self, $end_char)
	if $end_char =~ /'|"/;
    return $res;
}

sub _parse_text {
    my($self) = @_;
    my($c) = _peek_char($self, 1);
    return _parse_object($self)
	if $c eq '{';
    return _parse_array($self)
	if $c eq '[';
    return _parse_string($self)
	if $c =~ /'|"/;
    return _parse_constant($self, 'true')
	if $c eq 't';
    return _parse_constant($self, 'false')
	if $c eq 'f';
    return _parse_constant($self, 'null')
	if $c eq 'n';
    return _parse_number($self)
	if $c =~ /\d|\-/;
    b_die('invalid value start: ', $c);
}

sub _parse_unescaped_string {
    # optimization for e.g. large base64 strings
    my($self, $end_char) = @_;
    my($fields) = $self->[$_IDI];
    my($value, $terminator) = substr(${$fields->{text}}, $fields->{char_count})
        =~ /^([^\\$end_char]*)([\\$end_char])/;
    return
        unless $terminator && ($terminator eq $end_char);
    $fields->{char_count} += length($value);
    return $value;
}

sub _parse_unicode_char {
    my($self) = @_;
    my($hex) = join('', map(_next_char($self), 1 .. 4));
    b_die('invalid hex value: ', $hex)
	unless $hex =~ /^[0-9a-f]{4}$/i;
    return pack('U', hex($hex));
}

sub _peek_char {
    my($self, $skip_whitespace) = @_;
    my($fields) = $self->[$_IDI];
    _skip_whitespace($self)
	if $skip_whitespace;
    return $fields->{char_count} >= length(${$fields->{text}})
	? ''
	: substr(${$fields->{text}}, $fields->{char_count}, 1);
}


sub _skip_whitespace {
    my($self) = @_;

    while (_peek_char($self) =~ /\s/) {
	_next_char($self);
    }
    return;
}

1;
