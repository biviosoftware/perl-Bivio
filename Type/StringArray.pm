# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::StringArray;
use strict;
use base 'Bivio::Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub new {
    my($proto, $value) = @_;
    return $proto->from_literal_or_die($value, 1) || $proto->new([])
	unless ref($value);
    my($self) = shift->SUPER::new;
    $self->[$_IDI]
	= (ref($value) eq 'ARRAY' ? _clean_copy($value) : $value->as_array)
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
    $left = _clean_copy($left);
    $right = _clean_copy($right);
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
    return (undef, undef)
	unless defined($value);
    $value =~ s/^\s+|\s+$//sg
	if defined($value);
    return (undef, undef)
	unless length($value);
    my($sep) = $value =~ /$;/ ? $; : ',';
    return _new($proto, [split(/\s*$sep\s*/s, $value)]);
}

sub from_sql_column {
    my($proto, $param) = @_;
    return defined($param) ? _new($proto, [split(/$;/, $param)]) : undef;
}

sub get_width {
    return 4000;
}

sub map_iterate {
    my($self, $op) = @_;
    return [map($op->($_), @{$self->as_array})];
}

sub to_literal {
    my(undef, $value) = @_;
    return join(', ', @{_clean_copy($value, ',') || []});
}

sub to_sql_param {
    my(undef, $param_value) = @_;
    return join($;, @{_clean_copy($param_value) || return undef});
}

sub to_string {
    my(undef, $value) = @_;
    # Different than to_literal so we can print arrays during debugging
    return '[' . join(',', @{_clean_copy($value) || []}) . ']';
}

sub _clean_copy {
    my($value, $sep) = @_;
    $sep ||= "$;";
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
    }
    else {
	$copy = $value->as_array;
    }
    Bivio::Die->die($copy, ": separator ($sep) in element")
        if grep(/$sep/, @$copy);
    return @$copy ? $copy : undef;
}

sub _new {
    my($proto, $value) = @_;
    return @$value ? $proto->new($value) : undef;
}

1;
