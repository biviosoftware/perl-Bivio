# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::EnumSet;
use strict;
$Bivio::Type::EnumSet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
my($_PACKAGE) = __PACKAGE__;
my(%_INFO) = ();

=head1 METHODS

=cut

=for html <a name="clear"></a>

=head2 clear(string_ref vector, Bivio::Type::Enum bit, ...)

Clears I<bit>(s) in I<vector>.

=cut

sub clear {
    shift;
    my($vector) = shift;
    foreach my $bit (@_) {
	vec($$vector, $bit->as_int, 1) = 0;
    }
    return;
}

=for html <a name="from_literal"></a>

=head2 from_literal(string value) : string

Same as L<from_sql_column|"from_sql_column">.

=cut

sub from_literal {
    return shift->from_sql_column(@_);
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
    Bivio::Die->die($enum, ": EnumSet is narrower than Enum")
		if $width - length($max) < 0;
    foreach my $m ('min', 'max') {
	my($s) = unpack('h*', $_INFO{$class}->{$m});
	$s .= '0' x ($width - length($s));
	$_INFO{$class}->{$m} = pack('h*', $s);
    }
    return;
}

=for html <a name="is_set"></a>

=head2 is_set(string_ref vector, Bivio::Type::Enum bit, ...) : boolean

Returns true if all I<bit>(s) are set in I<vector>.

=cut

sub is_set {
    shift;
    my($vector) = shift;
    foreach my $bit (@_) {
	return 0 unless vec($$vector, $bit->as_int, 1);
    }
    return 1;
}

=for html <a name="set"></a>

=head2 set(string_ref vector, Bivio::Type::Enum bit, ....)

Sets I<bit>(s) in I<vector>.

=cut

sub set {
    shift;
    my($vector) = shift;
    foreach my $bit (@_) {
	vec($$vector, $bit->as_int, 1) = 1;
    }
    return;
}

=for html <a name="to_literal"></a>

=head2 to_literal(string value) : string

Same as L<to_sql_param|"to_sql_param">.

=cut

sub to_literal {
    return shift->to_sql_param(@_);
}

=for html <a name="to_sql_list"></a>

=head2 static to_sql_list(string_ref vector) : string

Returns a list of the form '(N,M,O,P)'.

=cut

sub to_sql_list {
    my($proto, $vector) = @_;
    return '()' unless ref($vector) && length($$vector);
    return '('.join(',',
	    map {vec($$vector, $_, 1) ? ($_) : ()} 0..length($$vector)*8-1)
	    .')';
}

=for html <a name="to_sql_param"></a>

=head2 static to_sql_param(Bivio::Type::Enum value) : int

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

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
