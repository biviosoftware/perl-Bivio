# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Enum;
use strict;
$Bivio::Type::Enum::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Enum - base class for enumerated types

=head1 SYNOPSIS

    use Bivio::Type::Enum;

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type::Number;
@Bivio::Type::Enum::ISA = ('Bivio::Type::Number');

=head1 DESCRIPTION

C<Bivio::Type::Enum> is the base class for enumerated types.  An enumerated
type is dynamically compiled from a description by L<compile|"compile">.
L<compile|"compile"> defines a new subroutine in the for each name in the
enumerated type.  The subroutines are blessed, so the routines
L<as_int|"as_int">, L<as_string|"as_string">, etc. can be called using
method lookup syntax.

An enum is L<Bivio::Type::Number|Bivio::Type::Number>.

=cut

#=IMPORTS
# Don't import "die".
use Bivio::IO::Alert;
#Avoid circular reference and pray east someone is using TypeError.
#use Bivio::TypeError;

#=VARIABLES
my(%_MAP);

=head1 FACTORIES

=cut

=for html <a name="from_any"></a>

=head2 static from_any(any thing) : Bivio::Type::Enum

Returns enum value for specified name, short description, long description,
enum, or integer in a case-insensitive manner.

=cut

sub from_any {
    my($proto, $thing) = @_;
    ref($thing) || ($thing = uc($thing));
    return _get_info($proto, $thing)->[5];
}

=for html <a name="from_int"></a>

=head2 static from_int(int num) : Bivio::Type::Enum

Returns enum value for specified integer.

=cut

sub from_int {
    return _get_info(shift(@_), shift(@_) + 0)->[5];
}

=for html <a name="from_name"></a>

=head2 static from_name(string name) : Bivio::Type::Enum

Returns enum value for specified name in a case-insensitive manner.

=cut

sub from_name {
    my($proto, $name) = @_;
    die($name, ': is not a string') if ref($name);
    $name = uc($name);
    my($info) = _get_info($proto, $name);
    Bivio::IO::Alert->die($name, ': is not the name of an ',
	    ref($proto) || $proto) unless $name eq $info->[3];
    return $info->[5];
}

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::Type::Enum

Returns I<proto>, i.e. class method invoked on.

=cut

sub get_instance {
    my($proto) = @_;
    return $proto;
}

=for html <a name="unsafe_from_any"></a>

=head2 static unsafe_from_any(any thing) : Bivio::Type::Enum

Returns enum value for specified name, short description, long description,
enum, or integer in a case-insensitive manner.  If not found, returns
C<undef>.

=cut

sub unsafe_from_any {
    my($proto, $thing) = @_;
    ref($thing) || ($thing = uc($thing));
    my($info) = _get_info($proto, $thing, 1);
    return $info ? $info->[5] : undef;
}

=for html <a name="unsafe_from_name"></a>

=head2 static unsafe_from_name(string name) : Bivio::Type::Enum

Returns enum value for specified I<name> in a case-insensitive manner.
If not found, returns C<undef>.

ASSERTS: I<name> is not a ref.

=cut

sub unsafe_from_name {
    my($proto, $name) = @_;
    Bivio::IO::Alert->die($name, ': is not a string') if ref($name);
    my($info) = _get_info($proto, uc($name), 1);
    return $info ? $info->[5] : undef;
}

=head1 METHODS

=cut

=for html <a name="as_int"></a>

=head2 as_int() : int

Returns integer value for enum value

=cut

sub as_int {
    return _get_info(shift(@_), undef)->[0];
}

=for html <a name="as_sql_param"></a>

=head2 as_sql_param() : int

Returns integer representation of this value.

=cut

sub as_sql_param {
    return _get_info(shift(@_), undef)->[0];
}

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns fully-qualified string representation of enum value.

=cut

sub as_string {
    my($self) = shift;
    return _get_info($self, undef)->[4];
}

=for html <a name="compare"></a>

=head2 static compare(any left, any right) : int

Performs the numeric comparison of the enum values.

=cut

sub compare {
    my(undef, $left, $right) = @_;
    Bivio::IO::Alert->die(ref($left), ' != ', ref($right),
	    ': type mismatch') unless ref($left) eq ref($right);
    return $left->as_int <=> $right->as_int;
}

=for html <a name="compile"></a>

=head2 static compile(array_ref declaration)

Hash of enum names pointing to array containing number, short
description, and, long description.  If the long description
is not supplied or is C<undef>, the short description will be used.  If the
short description is not supplied or is C<undef>, the name will be downcased
and all underscores (_) will be replaced with space and the first letter
of each word will be capitalized.

The descriptions should be unique, but may match the other descriptions or
names for a particular enum.  L<from_any|"from_any"> can map from descriptions
to enums in a case-insensitive manner.

As many aliases as you like may be provided.  However, duplicates
will cause an error.

Example compile:

    __PACKAGE__->compile([
        'NAME1' => [
            1,
            'short description',
            'long description',
            'alias 1',
            '...',
            'alias N',
        ],
        'NAME2' => [
            2,
        ],
    ]);

An array_ref is used, so this module can check for duplicate names.

Reference an Enum value with:

    __PACKAGE__->NAME1;

=cut

sub compile {
    my($pkg, $args) = @_;
    defined($_MAP{$pkg}) && Bivio::IO::Alert->die($pkg, ': already compiled');
    Bivio::IO::Alert->die($pkg, ': first argument must be an array_ref')
		if ref($args) ne 'ARRAY';
    # Will warn if odd number of elements
    my($info) = {@$args};

    # Check for dup keys, because the hash has lost them.
    if (int(@$args)/2 != int(keys(%$info))) {
	# The value of %$info is being checked here as well, but this makes the
	# code simpler.  We know that all array_refs are uniquely named.
	my(%found);
	foreach my $k (@$args) {
	    Bivio::IO::Alert->die($k, ': duplicate entry')
			if $found{$k}++;
	}
    }

    my($name);
    my($eval) = "package $pkg;\nmy(\$_INFO) = \$info;\n";
    # Make a copy, because we're going to grow the list.
    my($min, $max);
    my(@list);
    my(%info_copy) = %$info;
    my($name_width) = 0;
    my($short_width) = 0;
    my($long_width) = 0;
    my($can_be_zero) = 0;
    while (my($name, $d) = each(%info_copy)) {
	Bivio::IO::Alert->die($pkg, '::', $name, ': is a reserved word')
		    if $pkg->can($name);
	Bivio::IO::Alert->die($pkg, '::', $name,
		': does not point to an array')
		    unless ref($d) eq 'ARRAY';
	unless (defined($d->[1])) {
	    # Turn TEST_VIEW into Test View.
	    my($n) = ucfirst(lc($name));
	    $n =~ s/_(\w?)/ \u$1/g;
	    $d->[1] = $n;
	}
	$short_width = length($d->[1]) if length($d->[1]) > $short_width;
	$d->[2] = $d->[1] unless defined($d->[2]);
	$long_width = length($d->[2]) if length($d->[2]) > $long_width;
	# Remove aliases
	my(@aliases) = splice(@$d, 3);
	Bivio::IO::Alert->die($pkg, '::', $name, ': invalid number "',
		$d->[0], '"')
		    unless defined($d->[0]) && $d->[0] =~ /^[-+]?\d+$/;

	# Enforce to our syntax (not any syntax)
	Bivio::IO::Alert->die($pkg, '::', $name, ': invalid enum name')
		    unless __PACKAGE__->is_valid_name($name);

	# Fill out declaration to reverse map number to name (index 3)
	push(@$d, $name);
	$name_width = length($name) if length($name) > $name_width;
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
	Bivio::IO::Alert->die($pkg, '::', $d->[0], ': duplicate int value (',
		$d->[3], ' and ', $info->{$d->[0]}->[3], ')')
		    if defined($info->{$d->[0]});
	$info->{$d->[0]} = $d;
	# Map descriptions only if not already mapped.
	$info->{uc($d->[1])} = $d unless defined($info->{uc($d->[1])});
	$info->{uc($d->[2])} = $d unless defined($info->{uc($d->[2])});
	# Map extra aliases
	foreach my $alias (@aliases) {
	    Bivio::IO::Alert->die($pkg, '::', $alias, ': duplicate alias')
			if defined($info->{uc($alias)});
	    $info->{uc($alias)} = $d;
	}
	# Index 5: enum instance
	my($ln) = lc($name);
	$eval .= <<"EOF";
	    sub $name {return \\&$name;}
            sub execute_$ln {shift; return ${pkg}::${name}()->execute(\@_)};
	    push(\@{\$_INFO->{'$name'}}, bless(&$name));
	    \$_INFO->{&$name} = \$_INFO->{'$name'};
EOF
    }
    defined($min) || Bivio::IO::Alert->die($pkg, ': no values');
    if ($pkg->is_continuous) {
	my($n);
	foreach $n ($min->[0] .. $max->[0]) {
            Bivio::IO::Alert->die($pkg, ': missing number (', $n, ') in enum')
	        unless defined($info->{$n});
	}
    }
    eval($eval . '; 1')
	    || Carp::croak("compilation failed: $@");
    $_MAP{$pkg} = $info;
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
    my($count) = int(@list);
    eval <<"EOF" || Carp::Croak("compilation failed: $@");
        package $pkg;
        sub can_be_negative {return $can_be_negative;}
        sub can_be_positive {return $can_be_positive;}
        sub can_be_zero {return $can_be_zero;}
	sub get_list {return ($list);}
        sub get_max {return ${pkg}::$max();}
        sub get_min {return ${pkg}::$min();}
        sub get_precision {return $precision;}
        sub get_width {return $name_width;}
        sub get_width_long_desc {return $long_width;}
        sub get_width_short_desc {return $short_width;}
        sub get_count {return $count;}
        1;
EOF
    return;
}

=for html <a name="compile_with_numbers"></a>

=head2 static compile_with_numbers(array_ref names)

Compiles as in L<compile|"compile">, but I<names> is just a list
of names.  The numbers are assigned dynamically.  If the
first element is named "UNKNOWN", starts with 0.  Otherwise
starts with 1.

=cut

sub compile_with_numbers {
    my($proto, $names) = @_;
    my($i) = $names->[0] =~ /^UNKNOWN$/i ? 0 : 1;
    return $proto->compile([map {
	($_, [$i++]);
    } @$names]);
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req) : boolean

Put I<self> on the request as its class.

=cut

sub execute {
    my($self, $req) = @_;
    die('not a reference') unless ref($self);
    $req->put(ref($self) => $self);
    return 0;
}

=for html <a name="from_literal"></a>

=head2 static from_literal(int value) : Bivio::Type::Enum

Returns the enum for this integer or name.  If not found, returns an error.

=cut

sub from_literal {
    my($proto, $value) = @_;
    return undef unless defined($value) && $value ne '';
    my($info);
    if ($value =~ /^-?\d+$/) {
	$info = _get_info($proto, $value, 1);
    }
    else {
	$info = _get_info($proto, $value = uc($value), 1);
	$info = undef if $info && $info->[3] ne $value;
    }
    return (undef, Bivio::TypeError::NOT_FOUND()) unless $info;
    return $info->[5];
}

=for html <a name="from_sql_column"></a>

=head2 static from_sql_column(int value) : Bivio::Type::Enum

Returns the enum for this value.

=cut

sub from_sql_column {
    my($proto, $value) = @_;
    return undef unless defined($value);
    return _get_info($proto, $value + 0)->[5];
}

=for html <a name="get_count"></a>

=head2 static abstract get_count() : int

Return number of elements.

=cut

sub get_count {
    die('abstract method');
}

=for html <a name="get_decimals"></a>

=head2 static get_decimals : int

Returns 0.

=cut

sub get_decimals {
    return 0;
}

=for html <a name="get_list"></a>

=head2 abstract static get_list : array

Return the list of all enumerated types.  These are not returned in
any particular order.

=cut

sub get_list {
    die('abstract method');
}

=for html <a name="get_long_desc"></a>

=head2 get_long_desc() : string

Returns the long description for the enum value.

=cut

sub get_long_desc {
    return _get_info(shift(@_), undef)->[2];
}

=for html <a name="get_name"></a>

=head2 get_name() : string

Returns the string name of the enumerated value.

=cut

sub get_name {
    return _get_info(shift(@_), undef)->[3];
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
    return _get_info(shift(@_), undef)->[1];
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
    # Delete leading -> for compatibility with "standard" get_widget_value
    $method =~ s/^\-\>//;
    my($value) = $self->$method();
    return @_ ? shift(@_)->get_widget_value($value, @_) : $value;
}

=for html <a name="get_width"></a>

=head2 static abstract get_width : int

Defines the maximum width of L<get_name|"get_name">.

=cut

sub get_width {
    die('abstract method');
}

=for html <a name="get_width_long_desc"></a>

=head2 static abstract get_width_long_desc() : int

Defines the maximum width of L<get_long_desc|"get_long_desc">.

=cut

sub get_width_long_desc {
    die('abstract method');
}

=for html <a name="get_width_short_desc"></a>

=head2 static abstract get_width_short_desc() : int

Defines the maximum width of L<get_short_desc|"get_short_desc">.

=cut

sub get_width_short_desc {
    die('abstract method');
}

=for html <a name="is_continuous"></a>

=head2 static is_continuous() : boolean

Is this enumeration an unbroken sequence?  By default, this is true.
Enumerations which don't want to be continous should override this method.

=cut

sub is_continuous {
    return 1;
}

=for html <a name="is_equal"></a>

=head2 static is_equal(Bivio::Type::Enum left, Bivio::Type::Enum right) : boolean

Are the two values equal?  Uses "==" comparison.  undefs are not
equal, paralleling what happens is SQL.

=cut

sub is_equal {
    my(undef, $left, $right) = @_;
    return 0 unless defined($left) && defined($right);
    return $left == $right ? 1 : 0;
}

=for html <a name="is_valid_name"></a>

=head2 static is_valid_name(string name) : boolean

Returns true if I<name> is a correctly formed enumerated type name.

=cut

sub is_valid_name {
    my(undef, $name) = @_;
    return $name =~ /^[A-Z][A-Z0-9_]*$/ ? 1 : 0;
}

=for html <a name="to_literal"></a>

=head2 static to_literal(Bivio::Type::Enum value) : int

Return the integer representation of I<value>

=cut

sub to_literal {
    my($proto, $value) = @_;
    return undef unless defined($value);
    return _get_info($proto, $value)->[0];
}

=for html <a name="to_sql_param"></a>

=head2 static to_sql_param(Bivio::Type::Enum value) : int

Returns L<as_string|"as_string"> for I<value> or the empty string.

=cut

sub to_sql_param {
    my($proto, $value) = @_;
    return undef unless defined($value);
    return _get_info($proto, $value)->[0];
}

=for html <a name="to_string"></a>

=head2 to_string(Bivio::Type::Enum value) : string

Returns the string representation of the value.

=cut

sub to_string {
    my($proto, $value) = @_;
    return '' unless defined($value);
    return _get_info($proto, $value)->[3];
}

=for html <a name="to_xml"></a>

=head2 to_xml(Bivio::Type::Enum value) : string

Returns the name of I<value>.

=cut

sub to_xml {
    my($proto, $value) = @_;
    return '' unless defined($value);
    return _get_info($proto, $value)->[3];
}

#=PRIVATE METHODS

# _get_info(string class)
# _get_info(Bivio::Type::Enum self)
# _get_info(Bivio::Type::Enum self, any ident)
# _get_info(Bivio::Type::Enum self, any ident, boolean dont_die)
#
# Finds info for I<ident> in I<self> (can be a proto) or dies.
sub _get_info {
    my($self, $ident, $dont_die) = @_;
    my($info) = $_MAP{ref($self) || $self};
    Carp::croak($self, ': not an enumerated type') unless defined($info);
    defined($ident) || ($ident = $self);
    return $info->{$ident} if defined($info->{$ident});
    Bivio::IO::Alert->die($ident, ': no such ', ref($self) || $self)
		unless $dont_die;
    return undef;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
