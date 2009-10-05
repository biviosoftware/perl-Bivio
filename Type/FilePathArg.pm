# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FilePathArg;
use strict;
use Bivio::Base 'Type.FilePath';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = shift->SUPER::from_literal(@_);
    return ($v, $e)
	unless $v;
    $v =~ s{^/}{}
	unless $proto->is_absolute($value);
    return $v;
}

1;
