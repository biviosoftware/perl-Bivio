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
    __PACKAGE__->compile({
        'NAME' => {
            0,
            'short description',
            'long description',
        },
    });
    __PACKAGE__->NAME;
    __PACKAGE__->NAME->as_string;
    __PACKAGE__->NAME->as_int;
    __PACKAGE__->NAME->get_short_desc;
    __PACKAGE__->NAME->get_long_desc;
    __PACKAGE__->from_int(0);
    __PACKAGE__->from_string('NAME');

=cut

use Bivio::UNIVERSAL;
@Bivio::Type::Enum::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Type::Enum> is the base class for enumerated types.  An enumerated
type is dynamically compiled from a description by L<compile|"compile">.
L<compile|"compile"> defines a new subroutine in the for each name in the
enumerated type.  The subroutines are blessed, so the routines
L<as_int|"as_int">, L<as_string|"as_string">, etc. can be called using
method lookup syntax.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Carp ();

#=VARIABLES
my(%_MAP);

=head1 METHODS

=cut

=for html <a name="as_int"></a>

=head2 as_int() : int

Returns integer value for enum value

=cut

sub as_int {
    my($self) = @_;
    my($map) = $_MAP{ref($self)};
    return $map->{$self}->[0];
}

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns string representation of enum value

=cut

sub as_string {
    my($self) = @_;
    my($map) = $_MAP{ref($self)};
    return $map->{$self}->[3];
}

=for html <a name="compile"></a>

=head2 static compile(hash_ref declaration)

Hash of enum names pointing to array containing number, short
description, and, long description.  If the long description
is not supplied, the short description will be used.  If the
short description is not supplied, the name will be downcased
and all underscores (_) will be replaced with space.

=cut

sub compile {
    my(undef, $info) = @_;
    my($pkg) = caller;
    defined($_MAP{$pkg}) && Carp::croak('already compiled');
    my($name);
    my($eval) = "package $pkg;\nmy(\$_INFO) = \$info;\n";
    # Make a copy, because we're going to grow $decl.
    my(%info_copy) = %$info;
    my($min, $max);
    while (my($name, $d) = each(%info_copy)) {
	ref($d) eq 'ARRAY'
		|| Carp::croak("$name: does not point to an array");
	if (int(@$d) == 1) {
	    my($n) = lc($name);
	    $n =~ s/_/ /g;
	    push(@$d, $n, $n);
	}
	elsif (int(@$d) == 2) {
	    push(@$d, $d->[1]);
	}
	elsif (int(@$d) != 3) {
	    Carp::croak("$name: incorrect array length (should be 1 to 3)");
	}
	defined($d->[0]) && $d->[0] =~ /^[-+]?\d+$/
		|| Carp::croak("$name: invalid number \"$d->[0]\"");
        $name =~ /^[A-Z][A-Z0-9_]*$/
		|| Carp::croak("$name: invalid enum name");
	# Fill out declaration to reverse map number to name
	push(@$d, $name);
	# ALSO Ensures we convert $d->[0] into an integer!
	if (defined($min)) {
	    $d->[0] < $min->[0] && ($min = $d);
	    $d->[0] > $max->[0] && ($max = $d);
	}
	else {
	    $min = $max = $d;
	}
	$info->{$d->[0]} = $d;
	$eval .= <<"EOF";
	    \sub $name {return \\&$name;}
	    push(\@{\$_INFO->{'$name'}}, bless(&$name));
	    \$_INFO->{&$name} = \$_INFO->{'$name'};
EOF
    }
    defined($min) || Carp::croak('no values');
    $info->{_min} = $min;
    $info->{_max} = $max;
    if ($pkg->is_sequential) {
	my($n);
	foreach $n ($min->[0] .. $max->[0]) {
	    defined($info->{$n}) || Carp::croak("missing number $n");
	}
    }
    eval($eval . '; 1')
	    || Carp::croak("compilation failed: $@");
    $_MAP{$pkg} = $info;
    return;
}

=for html <a name="from_int"></a>

=head2 static from_int(int num) : Bivio::Type::Enum

Returns enum value for specified integer.

=cut

sub from_int {
    my($proto, $num) = @_;
    my($map) = $_MAP{ref($proto) || $proto};
    return $map->{$num + 0}->[4];
}

=for html <a name="from_string"></a>

=head2 static from_string(string name) : Bivio::Type::Enum

Returns enum value for specified string

=cut

sub from_string {
    my($proto, $name) = @_;
    my($map) = $_MAP{ref($proto) || $proto};
    return $map->{$name}->[4];
}

=for html <a name="get_long_desc"></a>

=head2 get_long_desc() : string

Returns the long description for the enum value.

=cut

sub get_long_desc {
    my($self) = @_;
    my($map) = $_MAP{ref($self)};
    return $map->{$self}->[2];
}

=for html <a name="get_short_desc"></a>

=head2 get_short_desc() : string

Returns the short description for the enum value.

=cut

sub get_short_desc {
    my($self) = @_;
    my($map) = $_MAP{ref($self)};
    return $map->{$self}->[1];
}

=for html <a name="is_sequential"></a>

=head2 is_sequential() : 1

Is this enumeration sequentially numbered?  By default, this is true.
Enumerations which don't want to be sequential should override this method.

=cut

sub is_sequential {
    return 1;
}

=for html <a name="min"></a>

=head2 static min() : Bivio::Type::Enum

Returns the minimum

=cut

sub min {
    my($proto) = @_;
    my($map) = $_MAP{ref($proto) || $proto};
    return $map->{_min}->[4];
}

=for html <a name="max"></a>

=head2 static max() : Bivio::Type::Enum

Returns the maximum

=cut

sub max {
    my($proto, $name) = @_;
    my($map) = $_MAP{ref($proto) || $proto};
    return $map->{_max}->[4];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
