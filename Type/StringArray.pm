# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::StringArray;
use strict;
use base 'Bivio::Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

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

sub WANT_SORTED {
    return 0;
}

sub new {
    my($proto, $value) = @_;
    return $proto->from_literal_or_die($value, 1) || $proto->new([])
	unless ref($value);
    my($self) = shift->SUPER::new;
    $self->[$_IDI]
	= (ref($value) eq 'ARRAY' ? _clean_copy($proto, $value) : $value->as_array)
	|| [];
    return $self;
}

sub as_array {
    return [@{shift->[$_IDI]}];
}

sub as_html {
    my($self) = @_;
    return $self->to_html($self);
}

sub as_string {
    my($self) = @_;
    return $self->simple_package_name . $self->to_string($self);
}

sub compare_defined {
    my($proto, $left, $right) = @_;
    $left = _clean_copy($proto, $left);
    $right = _clean_copy($proto, $right);
    foreach my $i (0 .. ($#$left < $#$right ? $#$left : $#$right)) {
	my($x) = $left->[$i] cmp $right->[$i];
	return $x
	    if $x;
    }
    return @$left <=> @$right;
}

sub equals {
    my($self, $other) = @_;
    return $self->is_equal($self, $other);
}

sub from_literal {
    my($proto, $value) = @_;
    if (ref($value)) {
	$value = $proto->new($value);
	return $value->equals([]) ? (undef, undef) : $value;
    }
    return (undef, undef)
	unless defined($value);
    $value =~ s/^\s+|\s+$//sg
	if defined($value);
    return (undef, undef)
	unless length($value);
    my($sep) = $proto->SQL_SEPARATOR_REGEX;
    $sep = $proto->LITERAL_SEPARATOR_REGEX
	unless $value =~ $sep;
    return _new($proto, [split($sep, $value)]);
}

sub from_sql_column {
    my($proto, $param) = @_;
    return !defined($param) ? undef
	: _new($proto, [split($proto->SQL_SEPARATOR_REGEX, $param)]);
}

sub get_width {
    return 4000;
}

sub map_iterate {
    my($self, $op) = @_;
    return [map($op->($_), @{$self->as_array})];
}

sub sort_unique {
    my(undef, $value) = @_;
    return [sort(keys(%{+{map(($_ => undef), @$value)}}))];
}

sub to_literal {
    my($proto, $value) = @_;
    return join(
	$proto->LITERAL_SEPARATOR,
	@{_clean_copy($proto, $value, $proto->LITERAL_SEPARATOR_REGEX) || []});
}

sub to_sql_param {
    my($proto, $param_value) = @_;
    return join(
	$proto->SQL_SEPARATOR,
	@{_clean_copy($proto, $param_value) || return undef});
}

sub to_string {
    my($proto, $value) = @_;
    # Different than to_literal so we can print arrays during debugging
    return '['
	. join($proto->LITERAL_SEPARATOR, @{_clean_copy($proto, $value) || []})
	. ']';
}

sub _clean_copy {
    my($proto, $value, $sep) = @_;
    $sep ||= $proto->SQL_SEPARATOR_REGEX;
    return undef
	unless defined($value);
    my($copy);
    if (ref($value) eq 'ARRAY') {
	$copy = [map({
	    $_ =~ s/^\s+|\s+$//gs
		if defined($_);
	    defined($_) && length($_) ? $_ : '';
	} @$value)];
	pop(@$copy)
	    while @$copy && !length($copy->[$#$copy]);
	$copy = [sort(@$copy)]
	    if $proto->WANT_SORTED;
    }
    else {
	$copy = $value->as_array;
    }
    Bivio::Die->die($copy, ": separator ($sep) in element")
        if grep($_ =~ $sep, @$copy);
    return @$copy ? $copy : undef;
}

sub _new {
    my($proto, $value) = @_;
    return @$value ? $proto->new($value) : undef;
}

1;
