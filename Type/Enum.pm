# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
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

# also uses Bivio::TypeError dynamically.  Used by DieCode and
# therefore Bivio::Die, so don't import Bivio::Die.
my($_INT_RE) = qr{^[-+]?\d+$}s;
my(%_MAP);

sub QUERY_KEY {
    my($proto) = @_;
    return lc($proto->simple_package_name);
}

sub add_to_query {
    my($self, $query) = @_;
    ($query ||= {})->{$self->QUERY_KEY} = $self->as_query;
    return $query;
}

sub as_facade_text_default {
    return shift->get_long_desc;
}

sub as_facade_text_tag {
    return shift->get_name;
}

sub as_int {
    my($self) = @_;
    return $self->to_sql_param($self);
}

sub as_query {
    my($self) = @_;
    return $self->to_query($self);
}

sub as_sql_param {
    my($self) = @_;
    # Returns integer value for enum value.
    return $self->to_sql_param($self);
}

sub as_string {
    return _get(shift(@_), 'as_string');
}

sub as_uri {
    return lc(shift->get_name);
}

sub as_xml {
    my($self) = @_;
    # Calls to_xml() on self
    return $self->to_xml($self);
}

sub clone_return_is_self {
    return 1;
}

sub compare {
    my($self) = shift;
    return $self->SUPER::compare(@_ <= 1 ? ($self, @_) : @_);
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
    my($decl) = _compile_decl($pkg, $args);
    my($eval) = "package $pkg;\n";
    my($min, $max);
    my($name_width) = 0;
    my($short_width) = 0;
    my($long_width) = 0;
    my($can_be_zero) = 0;
    my($map) = {};
    while (my($name, $d) = each(%$decl)) {
	Bivio::IO::Alert->bootstrap_die(
	    $pkg, '::', $name, ': does not point to an array',
	) unless ref($d) eq 'ARRAY';
	my($attr) = {
	    int => shift(@$d),
	    short_desc => shift(@$d),
	    long_desc => shift(@$d),
	    name => $name,
	};
	my($aliases) = $d;
	$attr->{short_desc} = $pkg->format_short_desc($name)
	    unless defined($attr->{short_desc});
	$attr->{long_desc} = $attr->{short_desc}
	    unless defined($attr->{long_desc});
	$short_width = length($attr->{short_desc})
	    if length($attr->{short_desc}) > $short_width;
	$long_width = length($attr->{long_desc})
	    if length($attr->{long_desc}) > $long_width;
	Bivio::IO::Alert->bootstrap_die(
	    $pkg, '::', $name, ': invalid number "', $attr->{int}, '"',
	) unless defined($attr->{int}) && $attr->{int} =~ $_INT_RE;
	Bivio::IO::Alert->bootstrap_die(
	    $pkg, '::', $name, ': invalid enum name',
	) unless $pkg->is_valid_name($name);
	$name_width = length($name)
	    if length($name) > $name_width;
	my($as_string) = $pkg . '::' . $name;
	$attr->{as_string} = $as_string;
	if (defined($min)) {
	    $min = $attr
		if $attr->{int} < $min->{int};
	    $max = $attr
		if $attr->{int} > $max->{int};
	}
	else {
	    $min = $max = $attr;
	}
	$can_be_zero = 1
	    if $attr->{int} == 0;
	foreach my $x (
	    ['int', $attr->{int}],
	    ['desc', map(uc($_), $attr->{long_desc}, $attr->{short_desc}, @$aliases)],
	    ['not_desc', $attr->{int}, uc($attr->{as_string}), $attr->{name}],
	    ['name', $attr->{name}],
	    ['as_string', $attr->{as_string}],
	) {
	    my($kind) = shift(@$x);
	    foreach my $key (@$x) {
		my($dup) = $map->{$kind}->{$key};
		Bivio::IO::Alert->bootstrap_die(
		    $pkg,
		    '::',
		    $key,
		    ": duplicate $kind value (",
		    $attr->{name},
		    ' and ',
		    $dup->{name},
		    ')',
		) if $dup && $dup != $attr;
		$map->{$kind}->{$key} = $attr;
	    }
	}
	my($ln) = lc($name);
	$eval .= <<"EOF";
	    sub $name {return \\&$name;}
            bless(&$name);
            sub execute_$ln {shift; return ${pkg}::${name}()->execute(\@_)}
	    sub eq_$ln {return ${pkg}::${name}->equals(\@_)}
EOF
    }
    defined($min) || Bivio::IO::Alert->bootstrap_die($pkg, ': no values');
    if ($pkg->is_continuous) {
	my($n);
	foreach $n ($min->{int} .. $max->{int}) {
            Bivio::IO::Alert->bootstrap_die(
		$pkg,
                ': missing number (',
		$n,
		') in enum',
	    ) unless $map->{int}->{$n};
	}
    }
    die("$pkg: compilation failed: $@")
	unless eval($eval . '; 1');
    $_MAP{$pkg} = $map;
    my($list) = [map(
	{
	    my($attr) = $map->{name}->{$_};
	    my($self) = $pkg->$_();
	    $attr->{self} = $self;
	    $map->{self}->{$self} = $attr;
	    $map->{not_desc}->{$self} = $attr;
	    $self;
	}
	keys(%{$map->{name}}),
    )];
    # Must happen last after enum references are defined.
    my($can_be_negative) = $min->{int} < 0;
    my($can_be_positive) = $max->{int} > 0;
    # Compute number of digits in maximum sized integer
    my($precision) = abs($max->{int});
    $precision = abs($min->{int}) if abs($min->{int}) > $precision;
    $precision = length($precision);
    $min = $min->{name};
    $max = $max->{name};
    my($get_list) = join(
	',',
	map($pkg . '::' . $_->get_name . '()',
	    sort({$a->as_int <=> $b->as_int} @$list)),
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
    foreach my $name (@_) {
	return 1
	    if $self == $self->from_any($name);
    }
    return 0;
}

sub execute {
    # Calls I<put_on_request>.  Always returns false.
    shift->put_on_request(@_);
    return 0;
}

sub execute_from_query {
    my($proto, $req) = @_;
    return $proto->from_int(
	($req->get('query') || {})->{$proto->QUERY_KEY} || 0)->execute($req);
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
    return _unsafe_from($proto, $thing, 0);
}

sub from_int {
    my($proto, $int) = @_;
    return $proto->from_any($int + 0);
}

sub from_literal {
    my($proto, $value) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return $value
	if $proto->is_blesser_of($value);
    return ()
	unless defined($value) && $value ne '';
    my($self);
    if ($value =~ $_INT_RE) {
	$self = _unsafe_from($proto, $value);
    }
    elsif ($proto->is_blesser_of($value)) {
	return $value;
    }
    else {
	$self = _unsafe_from($proto, $value);
	return $self
	    if $self && _eq_name($self, $value);
	$self = undef;
    }
    return $self ?  $self
        : (undef, $proto->use('Bivio::TypeError')->NOT_FOUND);
}

sub from_name {
    my($proto, $name) = @_;
    # Returns enum value for specified name in a case-insensitive manner.
    Bivio::IO::Alert->bootstrap_die($name, ': is not a string')
        if ref($name);
    my($self) = $proto->from_any($name);
    Bivio::IO::Alert->bootstrap_die(
	$name,
	': is not the name of an ',
	ref($proto) || $proto,
    ) unless $self && _eq_name($self, $name);
    return $self;
}

sub from_sql_column {
    my($proto, $value) = @_;
    return undef
	unless defined($value);
    return $proto->from_int($value);
}

sub get_count {
    # Return number of elements.
    Bivio::IO::Alert->bootstrap_die('abstract method');
}

sub get_decimals {
    return 0;
}

sub get_list {
    # Return the list of all enumerated types.  These are not returned in
    # any particular order.
    Bivio::IO::Alert->bootstrap_die('abstract method');
}

sub get_long_desc {
    return _get(shift(@_), 'long_desc')
}

sub get_name {
    # Returns the string name of the enumerated value.
    return _get(shift(@_), 'name');
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
    return _get(shift(@_), 'short_desc');
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

sub new {
    die('you cannot call new on an enum');
}

sub map_list {
    return _map_enums('get_list', @_);
}

sub map_non_zero_list {
    return _map_enums('get_non_zero_list', @_);
}

sub to_json {
    return ${b_use('MIME.JSON')->to_text(shift->to_xml(shift))};
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
    return undef
	unless defined($value);
    return _get($value, 'int');
}

sub to_string {
    my($proto, $value) = @_;
    return ''
	unless defined($value);
    return $value->get_short_desc;
}

sub to_xml {
    my($proto, $value) = @_;
    return ''
	unless defined($value);
    return $value->get_name;
}

sub unsafe_from_any {
    my($proto, $thing) = @_;
    return _unsafe_from($proto, $thing);
}

sub unsafe_from_int {
    my($proto, $int) = @_;
    Bivio::IO::Alert->bootstrap_die($int, ': is not a int')
        if ref($int) || $int !~ /^-?\d+$/s;
    return _unsafe_from($proto, $int);
}

sub unsafe_from_name {
    my($proto, $name) = @_;
    Bivio::IO::Alert->bootstrap_die($name, ': is not a string')
        if ref($name);
    return _unsafe_from($proto, $name);
}

sub _compile_decl {
    my($pkg, $args) = @_;
    Bivio::IO::Alert->bootstrap_die($pkg, ': already compiled')
        if defined($_MAP{$pkg});
    Bivio::IO::Alert->bootstrap_die(
	$pkg, ': first argument must be an array_ref'
    ) if ref($args) ne 'ARRAY';
    my($found) = {};
    return {@{$pkg->map_by_two(
	sub {
	    my($k, $v) = @_;
	    Bivio::IO::Alert->bootstrap_die($k, ': duplicate entry')
	        if $found->{$k}++;
	    return ($k, ref($v) ? $v : [$v]);
	},
	$args,
    )}};
}

sub _eq_name {
    my($self, $name) = @_;
    return $self->get_name eq uc($name);
}

sub _facade_lookup {
    my($self, $method, $thing) = @_;
    my($req) = Bivio::UNIVERSAL->unsafe_get_request;
    my($fc);
    return undef
	unless $req and $fc = $req->ureq(qw(UI.Facade Enum));
    return $fc->$method($self, $thing)
}

sub _get {
    my($self, $which) = @_;
    return $which =~ /desc$/
	&& _facade_lookup($self, 'unsafe_desc_from_enum', $which)
	|| _map($self)->{self}->{$self}->{$which};
}

sub _lookup {
    my($self, $thing, $dont_die) = @_;
    my($res);
    if (defined($thing)) {
	my($map) = _map($self);
	$res = $map->{not_desc}->{$thing}->{self}
	    || _facade_lookup($self, 'unsafe_enum_from_desc', $thing)
	    || $map->{desc}->{$thing}->{self};
    }
    Bivio::IO::Alert->bootstrap_die(
	$thing,
	': no such ',
	ref($self) || $self,
    ) unless $res || $dont_die;
    return $res;
}

sub _map {
    my($self) = @_;
    return $_MAP{ref($self) || $self}
	|| die ($self, ': not an enumerated type');
}

sub _map_enums {
    my($method, $proto, $op) = @_;
    return [map($op->($_), $proto->$method)];
}

sub _unsafe_from {
    my($proto, $thing, $dont_die) = @_;
    my($res) = _lookup(
	$proto,
	!$thing || ref($thing) ? $thing : uc($thing),
	defined($dont_die) ? $dont_die : 1,
    );
    return $res;
}

1;
