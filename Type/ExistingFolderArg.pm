# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ExistingFolderArg;
use strict;
use Bivio::Base 'Type.FolderArg';

my($_NOT_FOUND) = b_use('Bivio.TypeError')->NOT_FOUND;

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
        unless defined($v);
    return (undef, $_NOT_FOUND)
        unless -d $v;
    return $v;
}

1;
