# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Integer;
use strict;
use Bivio::Base 'Type.Number';
use Bivio::TypeError;

# C<Bivio::Type::Integer> is a number used for "small integer"
# computations, e.g. byte counts and list_display_size.
# An <Bivio::Type::Integer> always fits into a perl int.  It
# may be subclassed to create a subrange as all methods use
# L<get_min|"get_min"> and L<get_max|"get_max"> to get the
# boundaries for the integer.
# Dynamic subranges may be created using L<new|"new">.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub compare_defined {
    my(undef, $left, $right) = @_;
    # Returns the numeric comparison (E<lt>=E<gt>) of I<left> to I<right>.
    return $left <=> $right;
}

sub from_literal {
    my($proto, $value) = @_;
    # Parses I<value> as a string.  Verifies I<value> is a number and within min/max
    # of this Integer type.  Accepts any input and will not die as a result of
    # invalid values, e.g. C<undef>.
    #
    # On success, returns an C<int>.
    #
    # Special case if passed C<undef>, which result in C<undef> being
    # returned.
    #
    # On failure, returns the tuple (C<undef>, I<type_error>), where
    # I<type_error> is one of the following L<Bivio::TypeError|Bivio::TypeError>
    # values:
    #
    #
    # INTEGER
    #
    # The syntax is not valid for an integer, i.e. doesn't match
    # the regex /^[-+]?\d+$/.
    #
    # NUMBER_RANGE
    #
    # The syntax is correct, but the resultant integer is outside the bounds of
    # this integer type.
    $proto->internal_from_literal_warning
        unless wantarray;
    # Null (blank) string and null are same thing.
    return undef unless defined($value) && $value =~ /\S/;
    # Get rid of all blanks to be nice to user
    $value =~ s/\s+//g;;
    return (undef, Bivio::TypeError->INTEGER)
	unless $value =~ /^[-+]?\d+$/;
    # Return as a string, so we avoid perl turning 0 into ''.
    return $proto->get_min <= $value && $proto->get_max >= $value
	    ? int($value).'' : (undef, Bivio::TypeError->NUMBER_RANGE);
}

sub get_decimals {
    # Returns 0
    return 0;
}

sub get_max {
    my($proto) = @_;
    # Returns '999999999' if called with a class name.
    # Static subranges should override this method if their max is different.
    # I<Remember that this method returns a string!>
    #
    # The max for dynamic subranges will be retrieved from the type's
    # L<new|"new"> value.
    return '999999999' unless ref($proto);
    return $proto->[$_IDI]->{max};
}

sub get_min {
    my($proto) = @_;
    # Returns '-999999999' if called with a class name.
    # Static subranges should override this method if their min is different.
    # I<Remember that this method returns a string!>
    #
    # The min for dynamic subranges will be retrieved from the type's
    # L<new|"new"> value.
    return '-999999999' unless ref($proto);
    return $proto->[$_IDI]->{min};
}

sub get_precision {
    my($proto) = @_;
    # Returns the maximum number of decimal digits in
    # L<get_min|"get_min"> or L<get_max|"get_max"> whichever is greater.
    my($min, $max) = ($proto->get_min, $proto->get_max);
    my($n) = length($min) > length($max) ? $min : $max;
    return $n < 0 ? length($n) - 1 : length($n);
}

sub get_width {
    my($proto) = @_;
    # Returns the length of L<get_min|"get_min"> or L<get_max|"get_max">
    # whichever is greater.
    my($min, $max) = ($proto->get_min, $proto->get_max);
    return length($min) > length($max) ? length($min) : length($max);
}

sub new {
    my($proto, $min, $max) = @_;
    # Creates a new subrange between I<min> and I<max>, inclusive.
    # If either limit is undef, uses the value for this class.
    ($min) = defined($min) ? __PACKAGE__->from_literal($min)
	    : __PACKAGE__->get_min;
    Bivio::Die->die('invalid min value') unless defined($min);
    ($max) = defined($max) ? __PACKAGE__->from_literal($max)
	    : __PACKAGE__->get_max;
    Bivio::Die->die('invalid max value') unless defined($max);
    Bivio::Die->die('min greater than max') unless $min <= $max;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
	# get_min and get_max return strings
	min => "$min",
	max => "$max",
    };
    return $self;
}

1;
