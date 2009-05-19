# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::StringArray;
use strict;
use Bivio::Base 'Bivio.Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_S) = b_use('Type.String');

sub ANY_SEPARATOR_REGEX {
    my($proto) = @_;
    return qr{@{[$proto->LITERAL_SEPARATOR_REGEX]}|@{[$proto->SQL_SEPARATOR_REGEX]}};
}

sub LITERAL_SEPARATOR {
    return ', ';
}

sub LITERAL_SEPARATOR_REGEX {
    return qr{\s*,\s*}s;
}

sub SQL_SEPARATOR {
    return $;;
}

sub SQL_SEPARATOR_REGEX {
    return qr{\s*$;\s*}s;
}

sub UNDERLYING_TYPE {
    return $_S;
}

sub WANT_SORTED {
    return 0;
}

sub append {
    my($self, $value) = @_;
    return $self->new([@{$self->as_array}, @{$self->new($value)->as_array}]);
}

sub as_array {
    return [@{shift->[$_IDI]}];
}

sub as_html {
    my($self) = @_;
    return $self->to_html($self);
}

sub as_list {
    return @{shift->[$_IDI]};
}

sub as_literal {
    my($self) = @_;
    return $self->to_literal($self);
}

sub as_string {
    my($self) = @_;
    return $self->simple_package_name . '[' . $self->to_string($self) . ']';
}

sub compare_defined {
    my($proto, $left, $right) = @_;
    $left = _clean_copy($proto, $left);
    $right = _clean_copy($proto, $right);
    my($underlying) = $proto->UNDERLYING_TYPE;
    foreach my $i (0 .. ($#$left < $#$right ? $#$left : $#$right)) {
	my($x) = $underlying->compare($left->[$i], $right->[$i]);
	return $x
	    if $x;
    }
    return @$left <=> @$right;
}

sub intersect {
    my($self, $that) = @_;
    $that = $self->from_literal_or_die($that, 1);
    return $self->new([grep($that->contains($_), @{$self->as_array})]);
}

sub contains {
    my($self, $value) = @_;
    b_die($value, ': must be a string')
	if ref($value);
    b_die('value must be defined')
	unless defined($value);
    return grep($value eq $_, @{$self->as_array}) ? 1 : 0;
}

sub do_iterate {
    my($self, $op) = @_;
    my($a) = $self->as_array;
    foreach my $v (@$a) {
	return unless $op->($v);
    }
    return;
}

sub equals {
    my($self, $that) = @_;
    return $self->is_equal($self, $that);
}

sub exclude {
    my($self, $value) = @_;
    my($exclude) = $self->from_literal_or_die($value, 1);
    return $self->new([grep(!$exclude->contains($_), @{$self->as_array})]);
}

sub from_literal {
    my($proto, $value) = @_;
    return ($proto->new($value), undef)
	if ref($value);
    return ($proto->new([]), undef)
	unless defined($value) && length($value);
    $value = $proto->from_literal_stripper($value);
    return ($proto->new([]), undef)
	unless length($value);
    my($values, $error)
	= _parse($proto, [split($proto->ANY_SEPARATOR_REGEX, $value)]);
    return $error ? (undef, $error) : (_new($proto, $values), undef);
}

sub from_literal_stripper {
    my(undef, $value) = @_;
    $value =~ s/^\s+|\s+$//sg;
    return $value;
}

sub from_literal_validator {
    return shift->UNDERLYING_TYPE->from_literal(@_);
}

sub from_sql_column {
    my($proto, $param) = @_;
    return $proto->new([split(
	$proto->ANY_SEPARATOR_REGEX, defined($param) ? $param : '',
    )]);
}

sub get_width {
    return 4000;
}

sub is_specified {
    my($value) = _value(@_);
    return @{$value->as_array} ? 1 : 0;
}

sub map_iterate {
    my($self, $op) = @_;
    return [map($op->($_), @{$self->as_array})];
}

sub new {
    my($proto, $value) = @_;
    return $proto->from_literal_or_die($value)
	unless ref($value);
    return _new($proto, _clean_copy($proto, $value));
}

sub sort_unique {
    my($value) = _value(@_);
    return ref($value) eq 'ARRAY'
	? [sort(keys(%{+{map(($_ => undef), @$value)}}))]
	: $value->new($value->sort_unique($value->as_array));
}

sub to_literal {
    my($proto, $value) = @_;
    return join(
	$proto->LITERAL_SEPARATOR,
	@{_clean_copy($proto, $value)});
}

sub to_sql_param {
    my($proto, $param_value) = @_;
    my($res) = join($proto->SQL_SEPARATOR, @{_clean_copy($proto, $param_value)});
    return length($res) ? $res : undef;
}

sub _clean_copy {
    my($proto, $value) = @_;
    return []
	unless defined($value);
    if (__PACKAGE__->is_blessed($value)) {
	return $value->as_array
	    if ref($value) eq ref($proto);
	$value = $value->as_array;
    }
    my($copy, $error) = _parse($proto, $value);
    b_die($value, ": invalid literal: ", $error)
	if $error;
    return $copy;
}

sub _new {
    my($self) = shift->SUPER::new;
    $self->[$_IDI] = shift;
    return $self;
}

sub _parse {
    my($proto, $value) = @_;
    my($error);
    my($sep) = $proto->ANY_SEPARATOR_REGEX;
    $value = [map({
	my($v, $e) = $proto->from_literal_validator($_);
	$error ||= $e;
	b_die($v, ": separator ($sep) in element")
	    if ($v || '') =~ $sep;
	defined($v) && length($v) ? $v : '';
    } @$value)];
    pop(@$value)
	while @$value && !length($value->[$#$value]);
    return (
	$proto->WANT_SORTED ? [sort($proto->compare($a, $b), @$value)] : $value,
	$error,
    );
}

sub _value {
    my($self, $value) = @_;
    return @_ > 1 ? $value : $self;
}

1;
