# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Enum;
use strict;
$Bivio::Type::Enum::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Enum - base class for enumerated types

=head1 SYNOPSIS

    use Bivio::Type::Enum;
    @<PACKAGE>:ISA = qw(Bivio::Type::Enum);
    __PACKAGE__->compile(
        'NAME' => {
            0,
            'short description',
            'long description',
        },
    );
    __PACKAGE__->NAME;
    __PACKAGE__->NAME->as_string;
    __PACKAGE__->NAME->as_int;
    __PACKAGE__->NAME->get_short_desc;
    __PACKAGE__->NAME->get_long_desc;
    __PACKAGE__->from_int(0);
    __PACKAGE__->from_any('NAME');
    __PACKAGE__->from_any(0);
    __PACKAGE__->from_any(__PACKAGE__->from_int(0));

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type::Number;
@Bivio::Type::Enum::ISA = qw(Bivio::Type::Number);

=head1 DESCRIPTION

C<Bivio::Type::Enum> is the base class for enumerated types.  An enumerated
type is dynamically compiled from a description by L<compile|"compile">.
L<compile|"compile"> defines a new subroutine in the for each name in the
enumerated type.  The subroutines are blessed, so the routines
L<as_int|"as_int">, L<as_string|"as_string">, etc. can be called using
method lookup syntax.

An enum is L<Bivio::Type::Number|Bivio::Type::Number>.

=cut

=head1 CONSTANTS

=cut

=for html <a name="DECIMALS"></a>

=head2 DECIMALS : int

Returns 0.

=cut

sub DECIMALS {
    return 0;
}

=for html <a name="IS_CONTINUOUS"></a>

=head2 static IS_CONTINUOUS() : 1

Is this enumeration an unbroken sequence?  By default, this is true.
Enumerations which don't want to be continous should override this method.

=cut

sub IS_CONTINUOUS {
    return 1;
}

=for html <a name="LIST"></a>

=head2 abstract static LIST : array

Return the list of all enumerated types.  These are not returned in
any particular order.

=cut

sub LIST {
    die('abstract method');
}

=for html <a name="WIDTH"></a>

=head2 abstract WIDTH : int

Defines the maximum width of L<get_name|"get_name">.

=cut

sub WIDTH {
    die('abstract method');
}

#=IMPORTS
use Carp ();

#=VARIABLES
my(%_MAP);

=head1 FACTORIES

=cut

=for html <a name="from_any"></a>

=head2 static from_any(any thing) : Bivio::Type::Enum

Returns enum value for specified string, enum, or integer.

=cut

sub from_any {
    return &_get_info(shift(@_), shift(@_))->[5];
}

=for html <a name="from_int"></a>

=head2 static from_int(int num) : Bivio::Type::Enum

Returns enum value for specified integer.

=cut

sub from_int {
    return &_get_info(shift(@_), shift(@_) + 0)->[5];
}

=head1 METHODS

=cut

=for html <a name="as_int"></a>

=head2 as_int() : int

Returns integer value for enum value

=cut

sub as_int {
    return &_get_info(shift(@_), undef)->[0];
}

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns fully-qualified string representation of enum value.

=cut

sub as_string {
    my($self) = shift;
    return &_get_info($self, undef)->[4];
}

=for html <a name="compile"></a>

=head2 static compile(hash declaration)

Hash of enum names pointing to array containing number, short
description, and, long description.  If the long description
is not supplied, the short description will be used.  If the
short description is not supplied, the name will be downcased
and all underscores (_) will be replaced with space.

=cut

sub compile {
    my($proto, %info) = @_;
    my($pkg) = caller;
    defined($_MAP{$pkg}) && Carp::croak('already compiled');
    my($name);
    my($eval) = "package $pkg;\nmy(\$_INFO) = \\\%info;\n";
    # Make a copy, because we're going to grow $decl.
    my($min, $max);
    my(@list);
    my(%info_copy) = %info;
    my($width) = 0;
    my($can_be_zero) = 0;
    while (my($name, $d) = each(%info_copy)) {
	Carp::croak("$name: is a reserved word") if $proto->can($name);
	Carp::croak("$name: does not point to an array")
		    unless ref($d) eq 'ARRAY';
	if (int(@$d) == 1) {
	    # Turn TEST_VIEW into Test View.
	    my($n) = ucfirst(lc($name));
	    $n =~ s/_(\w?)/ \u$1/g;
	    push(@$d, $n, $n);
	}
	elsif (int(@$d) == 2) {
	    push(@$d, $d->[1]);
	}
	elsif (int(@$d) != 3) {
	    Carp::croak("$name: incorrect array length (should be 1 to 3)");
	}
	Carp::croak("$name: invalid number \"$d->[0]\"")
		    unless defined($d->[0]) && $d->[0] =~ /^[-+]?\d+$/;
	Carp::croak("$name: invalid enum name")
		    unless $name =~ /^[A-Z][A-Z0-9_]*$/;
	# Fill out declaration to reverse map number to name (index 3)
	push(@$d, $name);
	$width = length($name) if length($name) > $width;
	my($as_string) = $pkg.'::'.$name;
	# Index 4: as_string
	push(@$d, $as_string);
	push(@list, $as_string.'()');
	# ALSO Ensures we convert $d->[0] into an integer!
	if (defined($min)) {
	    $d->[0] < $min->[0] && ($min = $d);
	    $d->[0] > $max->[0] && ($max = $d);
	}
	else {
	    $min = $max = $d;
	}
	$can_be_zero = 1 if $d->[0] == 0;
	Carp::croak($d->[0], ': duplicate int value (',
		$d->[3], ' and ', $info{$d->[0]}->[3], ')')
		    if defined($info{$d->[0]});
	$info{$d->[0]} = $d;
	# Index 5: enum instance
	$eval .= <<"EOF";
	    sub $name {return \\&$name;}
	    push(\@{\$_INFO->{'$name'}}, bless(&$name));
	    \$_INFO->{&$name} = \$_INFO->{'$name'};
EOF
    }
    defined($min) || Carp::croak('no values');
    if ($pkg->IS_CONTINUOUS) {
	my($n);
	foreach $n ($min->[0] .. $max->[0]) {
	    defined($info{$n}) || Carp::croak("missing number $n");
	}
    }
    eval($eval . '; 1')
	    || Carp::croak("compilation failed: $@");
    $_MAP{$pkg} = \%info;
    # Must happen last after enum references are defined.
    my($can_be_negative) = $min->[0] < 0;
    my($can_be_positive) = $max->[0] > 0;
    # Compute number of digits in maximum sized integer
    my($precision) = abs($max->[0]);
    $precision = abs($min->[0]) if abs($min->[0]) > $precision;
    $precision = length($precision);
    $min = $min->[3];
    $max = $max->[3];
    my($list) = join(',', @list);
    eval <<"EOF" || Carp::Croak("compilation failed: $@");
        package $pkg;
        sub CAN_BE_NEGATIVE {return $can_be_negative;}
        sub CAN_BE_POSITIVE {return $can_be_positive;}
        sub CAN_BE_ZERO {return $can_be_zero;}
	sub LIST {return ($list);}
        sub MAX {return ${pkg}::$max();}
        sub MIN {return ${pkg}::$min();}
        sub PRECISION {return $precision;}
        sub WIDTH {return $width;}
        1;
EOF
    return;
}

=for html <a name="from_sql_column"></a>

=head2 static from_sql_column(int value) : Bivio::Type::Enum

Returns the enum for this type.

=cut

sub from_sql_column {
    return &_get_info(shift(@_), shift(@_) + 0)->[5];
}

=for html <a name="get_long_desc"></a>

=head2 get_long_desc() : string

Returns the long description for the enum value.

=cut

sub get_long_desc {
    return &_get_info(shift(@_), undef)->[2];
}

=for html <a name="get_name"></a>

=head2 get_name() : string

Returns the string name of the enumerated value.

=cut

sub get_name {
    return &_get_info(shift(@_), undef)->[3];
}

=for html <a name="get_self"></a>

=head2 get_self() : Bivio::Type::Enum

Returns C<$self>.  Convenience routine.

=cut

sub get_self {
    return shift;
}

=for html <a name="get_short_desc"></a>

=head2 get_short_desc() : string

Returns the short description for the enum value.

=cut

sub get_short_desc {
    return &_get_info(shift(@_), undef)->[1];
}

=for html <a name="get_widget_value"></a>

=head2 get_widget_value(string method) : any

=head2 get_widget_value(string method, string formatter, ...) : any

Calls I<method> on I<self>.

If a formatter is specified, the formatter will be called with the value
and the rest of the arguments.

=cut

sub get_widget_value {
    my($self, $method) = (shift, shift);
    my($value) = $self->$method();
    return @_ ? shift(@_)->get_widget_value($value, @_) : $value;
}

=for html <a name="to_sql_param"></a>

=head2 static to_sql_param(Bivio::Type::Enum value) : int

Returns integer representation of I<value>

=cut

sub to_sql_param {
    return &_get_info(shift(@_), shift(@_))->[0];
}

#=PRIVATE METHODS

# _get_info self name -> value
#
# Finds info for I<name> in I<self> (can be a proto) or dies.
# Returns the field specified or the hole array if field undefined.
sub _get_info {
    my($self, $name, $field) = @_;
    my($info) = $_MAP{ref($self) || $self};
    Carp::croak($self, ': not an enumerated type') unless defined($info);
    return $info->{defined($name) ? $name : $self};
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
