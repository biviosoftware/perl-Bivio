# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::MIME::JSON;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

# Using BNF at http://www.json.org/

sub from_text {
    my($proto, $text) = @_;
    return _parse_text($proto->new({
	text => ref($text) ? $text : \$text,
	char_count => 0,
    }));
}

sub _next_char {
    my($self) = @_;
    my($res) = _peek_char($self);
    $self->put(char_count => $self->get('char_count') + 1 );
    return $res;
}

sub _parse_array {
    my($self) = @_;
    my($res) = [];
    b_die() unless _next_char($self) eq '[';
    _skip_whitespace($self);

    while (_peek_char($self) ne ']') {
	push(@$res, _parse_text($self));
	_skip_whitespace($self);
	_parse_delim($self)
	    unless _peek_char($self) eq ']';
    }
    b_die() unless _next_char($self) eq ']';
    return $res;
}

sub _parse_constant {
    my($self, $expected_value) = @_;

    foreach my $expected_char (split('', $expected_value)) {
	my($c) = _next_char($self);
	b_die('unexpected char: ', $c)
	    unless $c eq $expected_char;
    }
    return $expected_value;
}

sub _parse_delim {
    my($self) = @_;
    b_die('missing delimiter')
	unless _next_char($self) eq ',';
    _skip_whitespace($self);
    return;
}

sub _parse_digits {
    my($self) = @_;
    my($res) = _next_char($self);

    while (_peek_char($self) && _peek_char($self) =~ /^\d$/) {
	$res .= _next_char($self);
    }
    return $res;
}

sub _parse_exp {
    my($self) = @_;
    b_die() unless _next_char($self) =~ /^e$/i;
    my($res) = 'e';

    if (_peek_char($self) =~ /^\+|\-$/) {
	$res .= _peek_char($self);
    }
    return $res . _parse_digits($self);
}

sub _parse_frac {
    my($self) = @_;
    b_die() unless _next_char($self) eq '.';
    return '.' . _parse_digits($self);
}

sub _parse_int {
    my($self) = @_;
    my($res) = '';
    my($c) = _peek_char($self);

    if ($c eq '-') {
	$res .= _next_char($self);
    }
    return $res . _parse_digits($self);
}

sub _parse_number {
    my($self) = @_;
    my($res) = _parse_int($self);
    my($c) = _peek_char($self);
    return $res unless defined($c);

    if ($c eq '.') {
	$res .= _parse_frac($self);
	$c = _peek_char($self);
	return $res unless defined($c);
    }

    if ($c =~ /^e$/i) {
	return $res . _parse_exp($self);
    }
    return $res;
}

sub _parse_object {
    my($self) = @_;
    my($res) = {};
    b_die() unless _next_char($self) eq '{';
    _skip_whitespace($self);

    while (_peek_char($self) ne '}') {
	my($k) = _parse_string($self);
	_skip_whitespace($self);
	b_die() unless _next_char($self) eq ':';
	b_die('key exists: ', $k, ' object: ', $res)
	    if exists($res->{$k});
	$res->{$k} = _parse_text($self);
	_skip_whitespace($self);
	_parse_delim($self)
	    unless _peek_char($self) eq '}';
    }
    b_die() unless _next_char($self) eq '}';
    return $res;
}

sub _parse_string {
    my($self) = @_;
    b_die() unless _next_char($self) eq '"';
    my($res) = '';

    while (_peek_char($self) ne '"') {
	my($c) = _next_char($self);

	if ($c eq '\\') {
	    $c = _next_char($self);

	    if ($c eq 'n') {
		$res .= "\n";
	    }
	    elsif ($c eq 't') {
		$res .= "\t";
	    }
	    elsif ($c =~ /^b|f$/) {
		# ignore formfeed or backspace
	    }
	    elsif ($c =~ /^"|\\|\/$/) {
		$res .= $c;
	    }
	    elsif ($c eq 'u') {
		$res .= _parse_unicode_char($self);
	    }
	    else {
		b_die('unexpected char: ', $c);
	    }
	}
	else {
	    $res .= $c;
	}
    }
    b_die() unless _next_char($self) eq '"';
    return $res;
}

sub _parse_text {
    my($self) = @_;
    _skip_whitespace($self);
    my($c) = _peek_char($self);

    if ($c eq '{') {
	return _parse_object($self);
    }
    elsif ($c eq '[') {
	return _parse_array($self);
    }
    return _parse_value($self);
}

sub _parse_unicode_char {
    my($self) = @_;
    my($hex) = join('', map(_next_char($self), 1 .. 4));
    b_die('invalid hex value: ', $hex)
	unless $hex =~ /^[0-9a-f]{4}$/i;
    return pack('U', hex($hex));
}

sub _parse_value {
    my($self) = @_;
    my($c) = _peek_char($self);
    b_die('missing value') unless defined($c);

    if ($c eq '"') {
	return _parse_string($self);
    }
    elsif ($c eq 't') {
	return _parse_constant($self, 'true');
    }
    elsif ($c eq 'f') {
	return _parse_constant($self, 'false');
    }
    elsif ($c eq 'n') {
	return _parse_constant($self, 'null');
    }
    elsif ($c =~ /^\d$/) {
	return _parse_number($self);
    }
    b_die('invalid value start: ', $c);
}

sub _peek_char {
    my($self) = @_;
    return $self->get('char_count') > length(${$self->get('text')})
	? undef
	: substr(${$self->get('text')}, $self->get('char_count'), 1);
}

sub _skip_whitespace {
    my($self) = @_;

    while (_peek_char($self) && _peek_char($self) =~ /\s/) {
	_next_char($self);
    }
    return;
}

1;
