# Copyright (c) 1999-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Gender;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => [0, 'Unspecified'],
    FEMALE => [1, undef, undef, 'F'],
    MALE => [2, undef, undef, 'M'],
]);

sub from_literal {
    my($proto, $value) = @_;
    my($res, $err) = shift->SUPER::from_literal(@_);
    if ($err) {
	if ($value =~ /^m$/i) {
	    $res = $proto->MALE;
	    $err = undef;
	} elsif ($value =~ /^f$/i) {
	    $res = $proto->FEMALE;
	    $err = undef;
	}
    }
    return $err ? ($res, $err) : $res;
}

1;
