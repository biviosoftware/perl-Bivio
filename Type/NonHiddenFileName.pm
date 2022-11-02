# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::NonHiddenFileName;
use strict;
use Bivio::Base 'Type.FileName';


sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
        unless defined($v);
    return (undef, Bivio::TypeError->FILE_NAME_LEADING_DOT)
        if $v =~ /^\./;
    return $v;
}

1;
