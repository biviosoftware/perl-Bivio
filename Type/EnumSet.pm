# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::EnumSet;
use strict;
use Bivio::Base 'Bivio::Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my(%_INFO) = ();

sub clear {
    my($vector, $bits) = _parse_args(\@_);
    # Clears I<bit>(s) in I<vector>.  Returns I<vector> as a string_ref (always).
    foreach my $bit (@$bits) {
	vec($$vector, $bit->as_int, 1) = 0;
    }
    return $vector;
}

sub compare_defined {
    my($proto) = shift;
    my($left, $right) = map((_parse_args([$proto, $_]))[0], @_);
    my($bits) = [$proto->get_enum_type->get_list];
    return $$left eq $$right ? 0
	: grep($proto->is_set(\$left, $_), @$bits)
	<=> grep($proto->is_set(\$right, $_), @$bits);
}

sub from_array {
    my($proto, $enums) = @_;
    # Returns set from an array of enum values (numbers, names, or enums).
    my($t) = $proto->get_enum_type;
    return $proto->set($proto->get_min, map($t->from_any($_), @$enums));
}

sub from_literal {
    my($proto, $value) = @_;
    # Returns set from a string.	
    $proto->internal_from_literal_warning
        unless wantarray;
    return $proto->from_sql_column($value);
}

sub from_sql_column {
    my($proto, $value) = @_;
    # Returns the bit vector for the database value (a hex string)
    return undef unless defined($value);
    # Just in case there is blank padding
    $value =~ s/\s/0/g;
    return pack('h*', $value);
}

sub get_empty {
    my($proto) = @_;
    # Return an empty EnumSet.
    my($enum) = $proto->get_enum_type;
    my($length) = $enum->get_max->as_int + 1;
    my($vector) = '';
    foreach my $i (0..$length) {
	vec($vector, $i, 1) = 0;
    }
    return \$vector;
}

sub get_enum_type {
    # Returns the enumerated type this set uses.
    b_die('abstract method');
}

sub get_max {
    my($proto) = @_;
    # Returns the bit vector with all the bits set to one.
    my($class) = ref($proto) || $proto;
    return $_INFO{$class}->{max};
}

sub get_min {
    my($proto) = @_;
    # Returns the bit vector with all the bits set to zero.
    my($class) = ref($proto) || $proto;
    return $_INFO{$class}->{min};
}

sub get_width {
    # Must return width of database CHAR field.
    b_die('abstract method');
}

sub initialize {
    my($proto) = @_;
    # Initializes state for the particular enum.
    my($class) = ref($proto) || $proto;
    return if $_INFO{$class};
    my($enum) = $proto->get_enum_type;
    b_die($enum, ': not an enum')
	unless UNIVERSAL::isa($enum, 'Bivio::Type::Enum');
    b_die($enum, ": can't be an EnumSet, because can be negative")
	if $enum->can_be_negative;
    my($length) = $enum->get_max->as_int + 1;
    my($min) = '';
    vec($min, $length - 1, 1) = 0;
    my($max) = '';
    foreach my $i (0..$length-1) {
	vec($max, $i, 1) = 1;
    }
    $_INFO{$class} = {
	min => $min,
	max => $max,
    };

    # Pad appropriately, because the enum may be smaller than the enumset.
    my($width) = 2 * $proto->get_width;
    b_die($enum, ": EnumSet ($width) is narrower than Enum (",
	length($max), ")",
    ) if $width - length($max) < 0;
    foreach my $m ('min', 'max') {
	my($s) = unpack('h*', $_INFO{$class}->{$m});
	$s .= '0' x ($width - length($s));
	$_INFO{$class}->{$m} = pack('h*', $s);
    }
    return;
}

sub is_set {
    my($vector, $bits) = _parse_args(\@_);
    # Returns true if all I<bit>(s) are set in I<vector>.
    foreach my $bit (@$bits) {
	return 0 unless vec($$vector, $bit->as_int, 1);
    }
    return 1;
}

sub set {
    my($vector, $bits) = _parse_args(\@_);
    # Sets I<bit>(s) in I<vector>.  Returns I<vector> as string_ref (always).
    foreach my $bit (@$bits) {
	vec($$vector, $bit->as_int, 1) = 1;
    }
    return $vector;
}

sub to_array {
    my($proto) = @_;
    # Converts to an array of enums.
    my($v) = _parse_args(\@_);
    return [map(
	$proto->is_set($v, $_) ? $_ : (),
	$proto->get_enum_type->get_list,
    )];
}

sub to_literal {
    my(undef, $value) = @_;
    # Same as L<to_sql_param|"to_sql_param">.
    return shift->SUPER::to_literal(@_)
	unless defined($value);
    return shift->to_sql_param(@_);
}

sub to_sql_list {
    my($vector) = _parse_args(\@_);
    # Returns a list of the form '(N,M,O,P)'.
    return '()' unless ref($vector) && length($$vector);
    return '('.join(',',
	    map {vec($$vector, $_, 1) ? ($_) : ()} 0..length($$vector)*8-1)
	    .')';
}

sub to_sql_param {
    my($proto, $value) = @_;
    # Returns the database representation (lower nybble first, hex string)
    # of the bit vector.
    # Note: Two characters are required _per_ byte.
    return undef unless defined($value) && length($value);
    b_die('value must be non ref') if ref($value);
    my($res) = unpack('h*', $value);
    my($width) = 2 * $proto->get_width;
    # Exact match means field is correct.
    return $res if length($res) == $width;
    b_die('field too long') if length($res) > $width;
    # Pad with zeroes
    $res .= '0' x ($width - length($res));
    return $res;
}

sub _parse_args {
    my($args) = @_;
    # Returns ($vector, $bits) based on @$args.
    #
    # Could technically typecheck @$bits.
    my($proto) = shift(@$args);
    my($t);
    my($vector) = shift(@$args);
    return (
	(ref($vector) ? $vector : \$vector),
	[map(ref($_) ? $_ : ($t ||= $proto->get_enum_type)->from_any($_),
	    map(ref($_) eq 'ARRAY' ? @$_ : $_,
		@$args))],
    );
}

1;
