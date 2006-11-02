# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::SyntacticString;
use strict;
use base 'Bivio::Type::String';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);


sub from_literal {
    my($proto, $value) = splice(@_, 0, 2);
    if (defined($value)) {
	$value =~ s/^\s+|\s+$//g;
	$value =~ s/\s+/ /g;
    }
    my($v, $e) = $proto->SUPER::from_literal($value, @_);
    return !defined($v) ? ($v, $e)
	: $v =~ /^@{[$proto->REGEX]}$/ ? $v
	: (undef, Bivio::TypeError->SYNTAX_ERROR);
}

sub get_width {
    return 100;
}

1;
