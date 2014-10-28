# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Regexp;
use strict;
use Bivio::Base 'Bivio::Type';


sub add_regexp_modifiers {
    my($self, $value, $modifiers) = @_;
    $value = $self->from_literal_or_die($value) . '';
    $value =~ s{\(\?\^([a-z]*)}{\(?${1}d-xism}sg;
    $value =~ s{\(\?([a-z]*)(?:-([a-z]+))?}{'(?' . _add_regexp_modifiers($1, $2, $modifiers)}e;
    return $self->from_literal_or_die($value);
}

sub from_literal {
    my($self, $value) = @_;
    return !defined($value) || !length($value) ? (undef, undef)
	: ref($value) eq 'Regexp' ? $value : _compile($value);
    return;
}

sub from_sql_column {
    return shift->from_literal_or_die(@_);
}

sub to_literal {
    my(undef, $value) = @_;
    return $value ? "$value" : '';
}

sub get_width {
    return 500;
}

sub is_stringified_regexp {
    my(undef, $value) = @_;
    return !$value ? 0
	: $value =~ /^\(\?.*\)$/s ? 1 : 0;
}

sub quote_string {
    my(undef, $value) = @_;
    $value =~ s/(\W)/\\$1/sg;
    return $value;
}

sub to_sql_param {
    return shift->to_literal(@_);
}

sub to_string {
    return shift->to_literal(@_);
}

sub _add_regexp_modifiers {
    my($curr_plus, $curr_minus, $add) = @_;
    $curr_minus ||= '';
    $add .= $curr_plus || '';
    return join(
	'',
	map($curr_minus =~ s{([$add])}{} && $1, 1 .. length($add)),
	$curr_minus ? "-$curr_minus" : (),
    );
}

sub _compile {
    my($value) = @_;
    # Perl puts an extra (?-xism:) or (?^:) [perl 5.14+] in front of all
    # variables converted to
    # regular expressions.  This is problematic as the value would grow
    # every time from_sql_column is called.  This prevents this, but
    # depends on the fact that the unique leading value is (?-xism: or (?^
    $value =~ s/^\(\?(?:\-xism|\^)\:(.*)\)$/$1/si;
    return (undef, Bivio::TypeError->PERMISSION_DENIED)
	if $value =~ /\(\?(?!\<\!|\<\=|\!|=|\w|\:|\#|\-|\^)/;
    return (undef, undef)
	unless length($value);
    my($res) = Bivio::Die->eval(sub {qr{$value}});
    return (undef, Bivio::TypeError->SYNTAX_ERROR)
	unless $res;
    return $res;
}

1;
