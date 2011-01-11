# Copyright (c) 2011 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::MIME::JSON;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

# Using BNF at http://www.json.org/
# expanded to allow strings in single quote and unquoted object keys

sub from_text {
    my($proto, $text) = @_;
    my($self) = $proto->new({
	text => ref($text) ? $text : \$text,
	char_count => 0,
    });
    my($res) = _parse_text($self);
    b_die('leftover data at char index: ', $self->get('char_count'))
	if length(_peek_char($self, 1));
    return $res;
}

sub _next_char {
    my($self) = @_;
    my($res) = _peek_char($self);
    b_die('unexpected end of input') unless length($res);
    $self->put(char_count => $self->get('char_count') + 1);
    return $res;
}

sub _parse_array {
    my($self) = @_;
    my($res) = [];
    b_die() unless _next_char($self) eq '[';

    while (_peek_char($self, 1) ne ']') {
	push(@$res, _parse_text($self));
	_parse_delim($self)
	    unless _peek_char($self, 1) eq ']';
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
    my($c) = _next_char($self);
    b_die('missing delimiter: ', $c)
	unless $c eq ',';
    return;
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
	$res .= _next_char($self);
    }
    $res .= _parse_digits($self);

    if (_peek_char($self) eq '.') {
	$res .= _next_char($self) . _parse_digits($self);
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
    b_die() unless _next_char($self) eq '{';

    while (_peek_char($self, 1) ne '}') {
	my($k) = _parse_string($self, ':');
	_skip_whitespace($self);
	b_die('missing colon') unless _next_char($self) eq ':';
	b_die('key exists: ', $k, ' object: ', $res)
	    if exists($res->{$k});
	$res->{$k} = _parse_text($self);
	_parse_delim($self)
	    unless _peek_char($self, 1) eq '}';
    }
    b_die() unless _next_char($self) eq '}';
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
    my($res) = '';

    while (_peek_char($self) ne $end_char) {
	my($c) = _next_char($self);

	if ($c eq '\\') {
	    $c = _next_char($self);

	    if ($c eq 'n') {
		$res .= "\n";
	    }
	    elsif ($c eq 't') {
		$res .= "\t";
	    }
	    elsif ($c =~ /b|f/) {
		# ignore formfeed or backspace
	    }
	    elsif ($c =~ /'|"|\\|\//) {
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

    if ($end_char =~ /'|"/) {
	b_die('missing end quote') unless _next_char($self) eq $end_char;
    }
    return $res;
}

sub _parse_text {
    my($self) = @_;
    my($c) = _peek_char($self, 1);
    return _parse_object($self)
	if $c eq '{';
    return _parse_array($self)
	if $c eq '[';
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
    b_die('missing value') unless length($c);
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

sub _peek_char {
    my($self, $skip_whitespace) = @_;
    _skip_whitespace($self)
	if $skip_whitespace;
    return $self->get('char_count') >= length(${$self->get('text')})
	? ''
	: substr(${$self->get('text')}, $self->get('char_count'), 1);
}

sub _skip_whitespace {
    my($self) = @_;

    while (_peek_char($self) =~ /\s/) {
	_next_char($self);
    }
    return;
}

1;
