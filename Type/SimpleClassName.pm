# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::SimpleClassName;
use strict;
use base 'Bivio::Type::Line';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGEX {
    return qr{\w+};
}

sub from_literal {
    my($proto) = shift;
    my($v, $e) = $proto->SUPER::from_literal(@_);
    return ($v, $e)
	unless defined($v);
    return $v =~ m{^@{[$proto->REGEX]}$}
	? $v : (undef, Bivio::TypeError->SIMPLE_CLASS_NAME);
    return;
}

1;
