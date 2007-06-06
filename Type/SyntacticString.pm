# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::SyntacticString;
use strict;
use Bivio::Base 'Type.String';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub from_literal {
    my($proto, $value) = @_;
    $value = $proto->internal_pre_from_literal($value);
    my($v, $e) = $proto->SUPER::from_literal($value);
    return !defined($v) ? ($v, $e)
	: $v =~ /^@{[$proto->REGEX]}$/ ? $proto->internal_post_from_literal($v)
	: (undef, Bivio::TypeError->SYNTAX_ERROR);
}

sub get_width {
    return 100;
}

sub internal_post_from_literal {
    return $_[1];
}

sub internal_pre_from_literal {
    my($proto, $value) = @_;
    if (defined($value)) {
	$value =~ s/^\s+|\s+$//g;
	$value =~ s/\s+/ /g;
    }
    return $value;
}

1;
