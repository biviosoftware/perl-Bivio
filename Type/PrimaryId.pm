# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::PrimaryId;
use strict;
use Bivio::Base 'Type.Number';

# C<Bivio::Type::PrimaryId> is a number which uniquely identifies a
# row in certain tables.  It is the one and only primary key for those
# tables.
#
# Compare C<PrimaryId> values using C<eq> and C<ne>, B<not> the numeric
# equivalents.  PrimaryIds are larger that fit into a 32-bit integer.
#
# All C<PrimaryId> values are unique within a given "universe".  PrimaryIds are
# "structured", but you should avoid depending on this structure.  The purpose of the
# structure is to allow for easy horizontal and vertical partitioning.  The lower
# five digits identify the table and a site.  This leaves 13 digits for
# the rows.  By using the lower digits, we avoid
# large numbers until we have large numbers of users and we can expand the
# space without having to change the numbering scheme, or all tables.
#
# L<to_parts|"to_parts"> and L<from_parts|"from_parts"> allow you to take apart
# the PrimaryId.


sub UNSPECIFIED_VALUE {
    return 0;
}

sub can_be_negative {
    return 0;
}

sub can_be_positive {
    return 1;
}

sub can_be_zero {
    return 0;
}

sub from_literal {
    my($proto, $value) = @_;
    # Make sure is at least one digit long, non-zero, and unsigned.
    $proto->internal_from_literal_warning
        unless wantarray;
    return undef
        unless defined($value) && $value =~ /\S/;
    $value =~ s/\s+//g;
    return $value
        if $value =~ /^0$/;
    $value =~ s/^0+//g;
    return $value
        if $value =~ /^\d+$/;
    return (undef, Bivio::TypeError->PRIMARY_ID);
}

sub from_parts {
    my(undef, $parts) = @_;
    # Returns parts (see L<to_parts|"to_parts">) as string.
    return sprintf('%s%1d%02d%02d',
        @{$parts}{qw(number version site type)});
}

sub get_decimals {
    return 0;
}

sub get_max {
    return '999999999999999999';
}

sub get_min {
    return '100001';
}

sub get_precision {
    return 18;
}

sub get_width {
    return 18;
}

sub is_equal {
    my(undef, $left, $right) = @_;
    return 0
        if defined($left) xor defined($right);
    return 1
        unless defined($left);
    return $left eq $right ? 1 : 0;
}

sub is_specified {
    my($proto, $value) = @_;
    return defined($value) && $value =~ /\d/
        && $value ne Bivio::Biz::ListModel->EMPTY_KEY_VALUE
        && $value ne $proto->UNSPECIFIED_VALUE
        ? 1 : 0;
}

sub is_valid {
    my($p) = shift->unsafe_to_parts(@_);
    return $p && $p->{number} && $p->{type} ? 1 : 0;
}

sub to_html {
    my($self, $value) = @_;
    return defined($value) ? $value : '';
}

sub to_literal {
    my(undef, $value) = @_;
    return defined($value) ? $value : '';
}

sub to_parts {
    return shift->unsafe_to_parts(@_) || Bivio::Die->die($_[0], ': bad value');
}

sub to_query {
    my($self, $value) = @_;
    return defined($value) ? $value : '';
}

sub to_uri {
    my($self, $value) = @_;
    return defined($value) ? $value : '';
}

sub unsafe_to_parts {
    my(undef, $value) = @_;
    return ($value || '') =~ /^(\d+)(\d)(\d{2})(\d{2})$/ ? {
        number => $1,
        version => $3 + 0,
        site => $2 + 0,
        type => $4 + 0,
    } : undef;
}

1;
