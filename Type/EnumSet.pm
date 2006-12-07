# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::EnumSet;
use strict;
$Bivio::Type::EnumSet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::EnumSet::VERSION;

=head1 NAME

Bivio::Type::EnumSet - describes a bit vector whose elements are an Enum

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::EnumSet;

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type;
@Bivio::Type::EnumSet::ISA = ('Bivio::Type');

=head1 DESCRIPTION

C<Bivio::Type::EnumSet> describes a bit vector whose elements are defined
by an Enum.  This class must be subclassed.

=cut

#=IMPORTS

#=VARIABLES
my(%_INFO) = ();

=head1 METHODS

=cut

=for html <a name="clear"></a>

=head2 clear(string_ref vector, Bivio::Type::Enum bit, ...) : string_ref

=head2 clear(string vector, Bivio::Type::Enum bit, ...) : string_ref

Clears I<bit>(s) in I<vector>.  Returns I<vector> as a string_ref (always).

=cut

sub clear {
    my($vector, $bits) = _parse_args(\@_);
    foreach my $bit (@$bits) {
	vec($$vector, $bit->as_int, 1) = 0;
    }
    return $vector;
}

=for html <a name="from_array"></a>

=head2 static from_literal(array_ref enums) : string_ref

Returns set from an array of enum values (numbers, names, or enums).

=cut

sub from_array {
    my($proto, $enums) = @_;
    my($t) = $proto->get_enum_type;
    return $proto->set($proto->get_min, map($t->from_any($_), @$enums));
}

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : string_ref

Returns set from a string.

=cut

sub from_literal {
    my($proto, $value) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return $proto->from_sql_column($value);
}

=for html <a name="from_sql_column"></a>

=head2 static from_sql_column(string value) : string

Returns the bit vector for the database value (a hex string)

=cut

sub from_sql_column {
    my($proto, $value) = @_;
    return undef unless defined($value);
    # Just in case there is blank padding
    $value =~ s/\s/0/g;
    return pack('h*', $value);
}

=for html <a name="get_empty"></a>

=head2 get_empty() : string_ref

Return an empty EnumSet.

=cut

sub get_empty {
    my($proto) = @_;
    my($enum) = $proto->get_enum_type;
    my($length) = $enum->get_max->as_int + 1;
    my($vector) = '';
    foreach my $i (0..$length) {
	vec($vector, $i, 1) = 0;
    }
    return \$vector;
}

=for html <a name="get_enum_type"></a>

=head2 static abstract get_enum_type() : Bivio::Type::Enum

Returns the enumerated type this set uses.

=cut

sub get_enum_type {
    die('abstract method');
}

=for html <a name="get_max"></a>

=head2 static get_max : string

Returns the bit vector with all the bits set to one.

=cut

sub get_max {
    my($proto) = @_;
    my($class) = ref($proto) || $proto;
    return $_INFO{$class}->{max};
}

=for html <a name="get_min"></a>

=head2 static get_min : string

Returns the bit vector with all the bits set to zero.

=cut

sub get_min {
    my($proto) = @_;
    my($class) = ref($proto) || $proto;
    return $_INFO{$class}->{min};
}

=for html <a name="get_width"></a>

=head2 static abstract get_width : int

Must return width of database CHAR field.

=cut

sub get_width {
    die('abstract method');
}

=for html <a name="initialize"></a>

=head2 static initialize()

Initializes state for the particular enum.

=cut

sub initialize {
    my($proto) = @_;
    my($class) = ref($proto) || $proto;
    return if $_INFO{$class};
    my($enum) = $proto->get_enum_type;
    Bivio::Die->die($enum, ': not an enum')
		unless UNIVERSAL::isa($enum, 'Bivio::Type::Enum');
    Bivio::Die->die($enum, ": can't be an EnumSet, because can be negative")
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
    Bivio::Die->die($enum, ": EnumSet ($width) is narrower than Enum (",
	length($max), ")",
    ) if $width - length($max) < 0;
    foreach my $m ('min', 'max') {
	my($s) = unpack('h*', $_INFO{$class}->{$m});
	$s .= '0' x ($width - length($s));
	$_INFO{$class}->{$m} = pack('h*', $s);
    }
    return;
}

=for html <a name="is_set"></a>

=head2 is_set(string_ref vector, Bivio::Type::Enum bit, ...) : boolean

=head2 is_set(string vector, Bivio::Type::Enum bit, ...) : boolean

Returns true if all I<bit>(s) are set in I<vector>.

=cut

sub is_set {
    my($vector, $bits) = _parse_args(\@_);
    foreach my $bit (@$bits) {
	return 0 unless vec($$vector, $bit->as_int, 1);
    }
    return 1;
}

=for html <a name="set"></a>

=head2 set(string_ref vector, Bivio::Type::Enum bit, ....) : string_ref

=head2 set(string vector, Bivio::Type::Enum bit, ....) : string_ref

Sets I<bit>(s) in I<vector>.  Returns I<vector> as string_ref (always).

=cut

sub set {
    my($vector, $bits) = _parse_args(\@_);
    foreach my $bit (@$bits) {
	vec($$vector, $bit->as_int, 1) = 1;
    }
    return $vector;
}

=for html <a name="to_array"></a>

=head2 static to_array(string value) : array_ref

Converts to an array of enums.

=cut

sub to_array {
    my($proto) = @_;
    my($v) = _parse_args(\@_);
    return [map(
	$proto->is_set($v, $_) ? $_ : (),
	$proto->get_enum_type->get_list,
    )];
}

=for html <a name="to_literal"></a>

=head2 static to_literal(string value) : string

Same as L<to_sql_param|"to_sql_param">.

=cut

sub to_literal {
    my(undef, $value) = @_;
    return shift->SUPER::to_literal(@_)
	unless defined($value);
    return shift->to_sql_param(@_);
}

=for html <a name="to_sql_list"></a>

=head2 static to_sql_list(string_ref vector) : string

Returns a list of the form '(N,M,O,P)'.

=cut

sub to_sql_list {
    my($vector) = _parse_args(\@_);
    return '()' unless ref($vector) && length($$vector);
    return '('.join(',',
	    map {vec($$vector, $_, 1) ? ($_) : ()} 0..length($$vector)*8-1)
	    .')';
}

=for html <a name="to_sql_param"></a>

=head2 static to_sql_param(string value) : int

Returns the database representation (lower nybble first, hex string)
of the bit vector.
Note: Two characters are required _per_ byte.

=cut

sub to_sql_param {
    my($proto, $value) = @_;
    return undef unless defined($value) && length($value);
    my($res) = unpack('h*', $value);
    my($width) = 2 * $proto->get_width;
    # Exact match means field is correct.
    return $res if length($res) == $width;
    die('field too long') if length($res) > $width;
    # Pad with zeroes
    $res .= '0' x ($width - length($res));
    return $res;
}

#=PRIVATE METHODS

# _parse_args(array_ref args) : array
#
# Returns ($vector, $bits) based on @$args.
#
# Could technically typecheck @$bits.
#
sub _parse_args {
    my($args) = @_;
    shift(@$args);
    my($vector) = shift(@$args);
    return ((ref($vector) ? $vector : \$vector), $args);
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
