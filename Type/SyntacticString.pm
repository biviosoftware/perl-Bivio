# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::SyntacticString;
use strict;
use Bivio::Base 'Type.String';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub SYNTAX_ERROR {
    return Bivio::TypeError->SYNTAX_ERROR;
}

sub TOO_LONG_ERROR {
    return Bivio::TypeError->TOO_LONG;
}

sub TOO_SHORT_ERROR {
    return Bivio::TypeError->TOO_SHORT;
}

sub from_literal {
    my($proto, $value) = @_;
    $value = $proto->internal_pre_from_literal($value)
	if defined($value);
    my($v, $e) = $proto->SUPER::from_literal($value);
    return !defined($v) ? ($v, $e)
	: $v =~ /^@{[$proto->REGEX]}$/
	? _length($proto, $proto->internal_post_from_literal($v))
	: (undef, $proto->SYNTAX_ERROR);
}

sub get_min_width {
    return 0;
}

sub get_width {
    return 100;
}

sub internal_post_from_literal {
    return $_[1];
}

sub internal_pre_from_literal {
    my(undef, $value) = @_;
    $value =~ s/^\s+|\s+$//g;
    $value =~ s/\s+/ /g;
    return $value;
}

sub _length {
    my($proto, $value) = @_;
    return $value
	if ref($value);
    return (undef, $proto->TOO_SHORT_ERROR)
	if length($value) < $proto->get_min_width;
    return (undef, $proto->TOO_LONG_ERROR)
	if length($value) > $proto->get_width;
    return $value;
}

1;
