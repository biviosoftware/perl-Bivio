# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::HTTPURI;
use strict;
use Bivio::Base 'Type.String';
use URI ();


sub from_literal {
    # (proto, string) : any
    # Returns C<undef> if the line is empty.
    # Leading and trailing blanks are trimmed.
    # Length is checked.
    my($proto, $value) = @_;
    $value =~ s/^\s+|\s+$//g
	if defined($value);
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
	unless defined($v);
    my($u) = Bivio::Die->eval(sub {URI->new($v)});
    return $u && ($u->scheme || '') =~ /^https?$/i && $u->host ? $v
	: (undef, Bivio::TypeError->HTTP_URI);
}

sub get_width {
    return 255;
}

1;
