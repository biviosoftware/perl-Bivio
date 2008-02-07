# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Enum;
use strict;
# Do not use Bivio::Base
use base 'Bivio::Type::Number';
use Bivio::IO::Alert;

# C<Bivio::Type::Enum> is the base class for enumerated types.  An enumerated
# type is dynamically compiled from a description by L<compile|"compile">.
# L<compile|"compile"> defines a new subroutine in the for each name in the
# enumerated type.  The subroutines are blessed, so the routines
# L<as_int|"as_int">, L<as_string|"as_string">, etc. can be called using
# method lookup syntax.
#
# An enum is L<Bivio::Type::Number|Bivio::Type::Number>.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
# also uses Bivio::TypeError dynamically.  Used by DieCode and
# therefore Bivio::Die, so don't import Bivio::Die.
my(%_MAP);

sub as_int {
    my($self) = @_;
    # Returns integer value for enum value.
    return $self->to_sql_param($self);
}

sub as_sql_param {
    my($self) = @_;
    # Returns integer value for enum value.
    return $self->to_sql_param($self);
}

sub as_string {
    my($self) = shift;
    # Returns fully-qualified string representation of enum value.
    return _get_info($self, undef)->[4];
}

sub as_uri {
    return lc(shift->get_name);
}

sub as_xml {
    my($self) = @_;
    # Calls to_xml() on self
    return $self->to_xml($self);
}

sub clone {
    # Instances are constant
    return shift;
}

sub compare_defined {
    my(undef, $left, $right) = @_;
    # Performs the numeric comparison of the enum values.  C<undef> is treated as
    # "least" (see L<Bivio::Type::compare|Bivio::Type/"compare">).
    Bivio::IO::Alert->bootstrap_die(
	ref($left), ' != ', ref($right), ': type mismatch'
    ) unless ref($left) eq ref($right);
    return $left->as_int <=> $right->as_int;
}

sub compile {
    my($pkg, $args) = @_;
    # Hash of enum names pointing to array containing number, short
    # description, and, long description.  If the long description
    # is not supplied or is C<undef>, the short description will be used.  If the
    # short description is not supplied or is C<undef>, the name will be downcased
    # and all underscores (_) will be replaced with space and the first letter
    # of each word will be capitalized.
    #
    # The descriptions should be unique, but may match the other descriptions or
    # names for a particular enum.  L<from_any|"from_any"> can map from descriptions
    # to enums in a case-insensitive manner.
    #
    # As many aliases as you like may be provided.  However, duplicates
    # will cause an error.
    #
    # Example compile:
    #
    #     __PACKAGE__->compile([
    #         'NAME1' => [
    #             1,
    #             'short description',
    #             'long description',
    #             'alias 1',
    #             '...',
    #             'alias N',
    #         ],
    #         'NAME2' => [
    #             2,
    #         ],
    #     ]);
    #
    # An array_ref is used, so this module can check for duplicate names.
    #
    # Reference an Enum value with:
    #
    #     __PACKAGE__->NAME1;
    Bivio::IO::Alert->bootstrap_die($pkg, ': already compiled')
        if defined($_MAP{$pkg});
    Bivio::IO::Alert->bootstrap_die(
	$pkg, ': first argument must be an array_ref'
    ) if ref($args) ne 'ARRAY';
    my($found) = {};
    my($info) = {@{$pkg->map_by_two(
	sub {
	    my($k, $v) = @_;
	    Bivio::IO::Alert->bootstrap_die($k, ': duplicate entry')
	        if $found->{$k}++;
	    return ($k, ref($v) ? $v : [$v]);
	},
	$args,
    )}};
    my($eval) = "package $pkg;\nmy(\$_INFO) = \$info;\n";
    my($min, $max);
    my($list) = [];
    my($info_copy) = {%$info};
    my($name_width) = 0;
    my($short_width) = 0;
    my($long_width) = 0;
    my($can_be_zero) = 0;
    while (my($name, $d) = each(%$info_copy)) {
	Bivio::IO::Alert->bootstrap_die(
	    $pkg, '::', $name, ': is a reserved word'
	) if $pkg->can($name);
	Bivio::IO::Alert->bootstrap_die(
	    $pkg, '::', $name, ': does not point to an array',
	) unless ref($d) eq 'ARRAY';
	$d->[1] = $pkg->format_short_desc($name)
	    unless defined($d->[1]);
	$short_width = length($d->[1]) if length($d->[1]) > $short_width;
	$d->[2] = $d->[1] unless defined($d->[2]);
	$long_width = length($d->[2]) if length($d->[2]) > $long_width;
	my(@aliases) = splice(@$d, 3);
	Bivio::IO::Alert->bootstrap_die(
	    $pkg, '::', $name, ': invalid number "', $d->[0], '"',
	) unless defined($d->[0]) && $d->[0] =~ /^[-+]?\d+$/;
	Bivio::IO::Alert->bootstrap_die(
	    $pkg, '::', $name, ': invalid enum name',
	) unless $pkg->is_valid_name($name);
	push(@$d, $name);
	$name_width = length($name) if length($name) > $name_width;
	my($as_string) = $pkg.'::'.$name;
	push(@$d, $as_string);
	push(@$list, $as_string);
	if (defined($min)) {
	    $d->[0] < $min->[0] && ($min = $d);
	    $d->[0] > $max->[0] && ($max = $d);
	}
	else {
	    $min = $max = $d;
	}
	$can_be_zero = 1 if $d->[0] == 0;
	Bivio::IO::Alert->bootstrap_die(
	    $pkg, '::', $d->[0],
	    ': duplicate int value (',
	    $d->[3], ' and ', $info->{$d->[0]}->[3], ')',
	) if defined($info->{$d->[0]});
	$info->{$d->[0]} = $d;
	$info->{uc($d->[1])} = $d
	    unless defined($info->{uc($d->[1])});
	$info->{uc($d->[2])} = $d
	    unless defined($info->{uc($d->[2])});
	foreach my $alias (@aliases) {
	    Bivio::IO::Alert->bootstrap_die($pkg, '::', $alias,
		    ': duplicate alias')
			if defined($info->{uc($alias)});
	    $info->{uc($alias)} = $d;
	}
	my($ln) = lc($name);
	$eval .= <<"EOF";
	    sub $name {return \\&$name;}
	    push(\@{\$_INFO->{'$name'}}, bless(&$name));
	    \$_INFO->{&$name} = \$_INFO->{'$name'};
            sub execute_$ln {shift; return ${pkg}::${name}()->execute(\@_)}
	    sub eq_$ln {return ${pkg}::${name}() == shift(\@_) ? 1 : 0}
EOF
    }
    defined($min) || Bivio::IO::Alert->bootstrap_die($pkg, ': no values');
    if ($pkg->is_continuous) {
	my($n);
	foreach $n ($min->[0] .. $max->[0]) {
            Bivio::IO::Alert->bootstrap_die($pkg,
                ': missing number (', $n, ') in enum')
	        unless defined($info->{$n});
	}
    }
    die("$pkg: compilation failed: $@")
	unless eval($eval . '; 1');
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
    my($get_list) = join(
	',',
	map($pkg . '::' . $_->get_name . '()',
	    sort {$a->as_int <=> $b->as_int} map($pkg->$_(), @$list)),
    );
    my($count) = scalar(@$list);
    die("$pkg: compilation failed: $@")
	unless eval(<<"EOF");
        package $pkg;
        sub can_be_negative {return $can_be_negative;}
        sub can_be_positive {return $can_be_positive;}
        sub can_be_zero {return $can_be_zero;}
	sub get_list {return ($get_list);}
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

sub compile_with_numbers {
    my($proto, $names) = @_;
    # Compiles as in L<compile|"compile">, but I<names> is just a list
    # of names.  The numbers are assigned dynamically.  If the
    # first element is named "UNKNOWN", starts with 0.  Otherwise
    # starts with 1.
    my($i) = $names->[0] =~ /^UNKNOWN$/i ? 0 : 1;
    return $proto->compile([map {
	($_, [$i++]);
    } @$names]);
}

sub equals_by_name {
    my($self) = shift;
    # Returns true if any I<name> is self's name.  Blows up if I<name> is invalid.
    foreach my $name (@_) {
	return 1
	    if $self == $self->from_name($name);
    }
    return 0;
}

sub execute {
    # Calls I<put_on_request>.  Always returns false.
    shift->put_on_request(@_);
    return 0;
}

sub format_short_desc {
    my($proto) = shift;
    # Converts an enum name (may be string or enum) to a mixed case string,
    # e.g.  turns TEST_VIEW into Test View.  If no arg, uses self.
    my($name) = @_ ? shift(@_) : $proto;
    $name = ucfirst(lc(ref($name) ? $name->get_name : $name));
    $name =~ s/_(\w?)/ \u$1/g;
    return $name;
}

sub from_any {
    my($proto, $thing) = @_;
    # Returns enum value for specified name, short description, long description,
    # enum, or integer in a case-insensitive manner.
    ref($thing) || ($thing = uc($thing));
    return _get_info($proto, $thing)->[5];
}

sub from_int {
    # Returns enum value for specified integer.
    return _get_info(shift(@_), shift(@_) + 0)->[5];
}

sub from_literal {
    my($proto, $value) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return ()
	unless defined($value) && $value ne '';
    my($info);
    if ($value =~ /^-?\d+$/) {
	$info = _get_info($proto, $value, 1);
    }
    elsif ($proto->is_blessed($value, $proto)) {
	return $value;
    }
    else {
	$info = _get_info($proto, $value = uc($value), 1);
	$info = undef
	    if $info && $info->[3] ne $value;
    }
    return $info ? $info->[5]
        : (undef, $proto->use('Bivio::TypeError')->NOT_FOUND);
}

sub from_name {
    my($proto, $name) = @_;
    # Returns enum value for specified name in a case-insensitive manner.
    Bivio::IO::Alert->bootstrap_die($name, ': is not a string') if ref($name);
    $name = uc($name);
    my($info) = _get_info($proto, $name);
    Bivio::IO::Alert->bootstrap_die($name, ': is not the name of an ',
	    ref($proto) || $proto) unless $name eq $info->[3];
    return $info->[5];
}

sub from_sql_column {
    my($proto, $value) = @_;
    # Returns the enum for this value.
    return undef unless defined($value);
    return _get_info($proto, $value + 0)->[5];
}

sub get_count {
    # Return number of elements.
    Bivio::IO::Alert->bootstrap_die('abstract method');
}

sub get_decimals {
    # Returns 0.
    return 0;
}

sub get_list {
    # Return the list of all enumerated types.  These are not returned in
    # any particular order.
    Bivio::IO::Alert->bootstrap_die('abstract method');
}

sub get_long_desc {
    # Returns the long description for the enum value.
    return _get_info(shift(@_), undef)->[2];
}

sub get_name {
    # Returns the string name of the enumerated value.
    return _get_info(shift(@_), undef)->[3];
}

sub get_non_zero_list {
    return grep($_->as_int, shift->get_list);
}

sub get_self {
    # Returns C<$self>.  Convenience routine.
    return shift;
}

sub get_short_desc {
    # Returns the short description for the enum value.
    return _get_info(shift(@_), undef)->[1];
}

sub get_widget_value {
    my($self, $method) = (shift, shift);
    # Calls I<method> with args on I<self>.
    # Delete leading -> for compatibility with "standard" get_widget_value
    $method =~ s/^\-\>//;
    return $self->$method(@_);
}

sub get_width {
    # Defines the maximum width of L<get_name|"get_name">.
    Bivio::IO::Alert->bootstrap_die('abstract method');
}

sub get_width_long_desc {
    # Defines the maximum width of L<get_long_desc|"get_long_desc">.
    Bivio::IO::Alert->bootstrap_die('abstract method');
}

sub get_width_short_desc {
    # Defines the maximum width of L<get_short_desc|"get_short_desc">.
    Bivio::IO::Alert->bootstrap_die('abstract method');
}

sub is_continuous {
    # Is this enumeration an unbroken sequence?  By default, this is true.
    # Enumerations which don't want to be continous should override this method.
    return 1;
}

sub is_specified {
    my($self) = @_ > 1 ? $_[1] : $_[0];
    # Returns true if I<self> or I<value> is not null and as_int returns something
    # other than 0.
    return defined($self) && $self->as_int != 0;
}

sub is_valid_name {
    my(undef, $name) = @_;
    # Returns true if I<name> is a correctly formed enumerated type name.
    return $name && $name =~ /^[A-Z][A-Z0-9_]*$/ ? 1 : 0;
}

sub to_literal {
    my($proto, $value) = @_;
    # Return the integer representation of I<value>
    return shift->SUPER::to_literal(@_)
	unless defined($value);
    return $proto->to_sql_param(
	ref($value) ? $value : $proto->from_literal_or_die($value));
}

sub to_sql_param {
    my($proto, $value) = @_;
    # Return the integer representation of I<value>
    return undef unless defined($value);
    Bivio::IO::Alert->warn_deprecated($value, ': enum ref required')
        unless ref($value);
    return _get_info($proto, $value)->[0];
}

sub to_string {
    my($proto, $value) = @_;
    # Returns the string representation of the value.
    return '' unless defined($value);
    return $value->get_short_desc;
}

sub to_xml {
    my($proto, $value) = @_;
    # Returns the name of I<value>.
    return '' unless defined($value);
    return _get_info($proto, $value)->[3];
}

sub unsafe_from_any {
    my($proto, $thing) = @_;
    # Returns enum value for specified name, short description, long description,
    # enum, or integer in a case-insensitive manner.  If not found, returns
    # C<undef>.
    ref($thing) || ($thing = uc($thing));
    my($info) = _get_info($proto, $thing, 1);
    return $info ? $info->[5] : undef;
}

sub unsafe_from_name {
    my($proto, $name) = @_;
    # Returns enum value for specified I<name> in a case-insensitive manner.
    # If not found, returns C<undef>.
    #
    # ASSERTS: I<name> is not a ref.
    Bivio::IO::Alert->bootstrap_die($name, ': is not a string') if ref($name);
    my($info) = _get_info($proto, uc($name), 1);
    return $info ? $info->[5] : undef;
}

sub _get_info {
    my($self, $ident, $dont_die) = @_;
    # Finds info for I<ident> in I<self> (can be a proto) or dies.
    my($info) = $_MAP{ref($self) || $self};
    die($self, ': not an enumerated type') unless defined($info);
    defined($ident) || ($ident = $self);
    return $info->{$ident} if defined($info->{$ident});
    Bivio::IO::Alert->bootstrap_die($ident, ': no such ', ref($self) || $self)
		unless $dont_die;
    return undef;
}

1;
