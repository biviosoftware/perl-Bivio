# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Integer;
use strict;
$Bivio::Type::Integer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Integer - superclass of all numerically manipulable integer types

=head1 SYNOPSIS

    use Bivio::Type::Integer;
    Bivio::Type::Integer->new(min, max);

    @MyInteger::ISA = ('Bivio::Type::Integer');
    sub get_min {
	return 10;
    }

    sub get_max {
	return 20;
    }

=cut

=head1 EXTENDS

L<Bivio::Type::Number>

=cut

use Bivio::Type::Number;
@Bivio::Type::Integer::ISA = ('Bivio::Type::Number');

=head1 DESCRIPTION

C<Bivio::Type::Integer> is a number used for "small integer"
computations, e.g. byte counts and list_display_size.
An <Bivio::Type::Integer> always fits into a perl int.  It
may be subclassed to create a subrange as all methods use
L<get_min|"get_min"> and L<get_max|"get_max"> to get the
boundaries for the integer.
Dynamic subranges may be created using L<new|"new">.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(int min, int max) : Bivio::Type::Integer

Creates a new subrange between I<min> and I<max>, inclusive.
If either limit is undef, uses the value for this class.

=cut

sub new {
    my($proto, $min, $max) = @_;
    $min = defined($min) ? __PACKAGE__->from_literal($min)
	    : __PACKAGE__->get_min;
    Carp::croak('invalid min value') unless defined($min);
    $max = defined($max) ? __PACKAGE__->from_literal($max)
	    : __PACKAGE__->get_max;
    Carp::croak('invalid max value') unless defined($max);
    Carp::croak('min greater than max') unless $min <= $max;
    my($self) = $proto->SUPER::new();
    $self->{$_PACKAGE} = {
	# get_min and get_max return strings
	min => "$min",
	max => "$max",
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="can_be_negative"></a>

=head2 static can_be_negative : boolean

Returns true if L<get_min|"get_min"> is less than 0.

=cut

sub can_be_negative {
    my($proto) = @_;
    return $proto->get_min < 0 ? 1 : 0;
}

=for html <a name="can_be_positive"></a>

=head2 static can_be_positive : boolean

Returns true if L<get_max|"get_max"> is greater than 0.

=cut

sub can_be_positive {
    my($proto) = @_;
    return $proto->get_max > 0  ? 1 : 0;
}

=for html <a name="can_be_zero"></a>

=head2 static can_be_zero : boolean

Returns true if range crosses through zero.

=cut

sub can_be_zero {
    my($proto) = @_;
    return $proto->get_max >= 0 && $proto->get_min <= 0 ? 1 : 0;
}

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : string

Makes sure is a number and within min/max.

=cut

sub from_literal {
    my($proto, $value) = @_;
    return undef unless defined($value) && $value =~ /^[-+]?\d+$/;
    $value =~ s/^([-+]?)0+/${1}0/;
    return $proto->get_min <= $value && $proto->get_max >= $value
	    ? int($value).'' : undef;
}

=for html <a name="get_decimals"></a>

=head2 static get_decimals : int

Returns 0

=cut

sub get_decimals {
    return 0;
}

=for html <a name="get_max"></a>

=head2 static get_max : string

Returns '999999999' if called with a class name.
Static subranges should override this method if their max is different.
I<Remember that this method returns a string!>

The max for dynamic subranges will be retrieved from the type's
L<new|"new"> value.

=cut

sub get_max {
    my($proto) = @_;
    return '999999999' unless ref($proto);
    return $proto->{$_PACKAGE}->{max};
}

=for html <a name="get_min"></a>

=head2 static get_min : string

Returns '-999999999' if called with a class name.
Static subranges should override this method if their min is different.
I<Remember that this method returns a string!>

The min for dynamic subranges will be retrieved from the type's
L<new|"new"> value.

=cut

sub get_min {
    my($proto) = @_;
    return '-999999999' unless ref($proto);
    return $proto->{$_PACKAGE}->{min};
}

=for html <a name="get_precision"></a>

=head2 static get_precision : int

Returns the maximum number of decimal digits in
L<get_min|"get_min"> or L<get_max|"get_max"> whichever is greater.

=cut

sub get_precision {
    my($proto) = @_;
    my($min, $max) = ($proto->get_min, $proto->get_max);
    my($n) = length($min) > length($max) ? $min : $max;
    return $n < 0 ? length($n) - 1 : length($n);
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns the length of L<get_min|"get_min"> or L<get_max|"get_max">
whichever is greater.

=cut

sub get_width {
    my($proto) = @_;
    my($min, $max) = ($proto->get_min, $proto->get_max);
    return length($min) > length($max) ? length($min) : length($max);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
