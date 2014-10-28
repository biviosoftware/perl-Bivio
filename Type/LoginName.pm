# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::LoginName;
use strict;
use Bivio::Base 'Type.String';
b_use('IO.ClassLoaderAUTOLOAD');


sub from_literal {
    my($proto, $value) = @_;
    map({
	my($v, $e) = $_->from_literal($value);
	return $v
	    unless $e;
    } Type_Email(), Type_RealmName(), Type_PrimaryId());
    return (undef, Bivio_TypeError()->SYNTAX_ERROR);
}

sub get_width {
    my($w) = 'get_width';
    return Type_Integer()->max(
	Type_Email()->$w,
	Type_RealmName()->$w,
	Type_PrimaryId()->$w,
    );
}

1;
