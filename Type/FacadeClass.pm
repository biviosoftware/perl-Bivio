# Copyright (c) 2003-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FacadeClass;
use strict;
use Bivio::Base 'Type.Name';

# C<Bivio::Type::FacadeClass> is used to check if a facade's simple class is a
# valid.  See also
# L<Bivio::Biz::Model::FacadeClassList|Bivio::Biz::Model::FacadeClassList>.


sub from_literal {
    # (proto, string) : array
    my($v, $e) = shift->SUPER::from_literal(@_);
    return ($v, $e)
        unless defined($v);
    return (undef, Bivio::TypeError->FACADE_CLASS)
        unless grep($_ eq $v, @{b_use('UI.Facade')->get_all_classes});
    return $v;
}

1;
