# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::StringArray;
use strict;
use Bivio::Base 'Type.ArrayBase';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_S) = b_use('Type.String');

sub UNDERLYING_TYPE {
    return $_S;
}

sub from_literal_stripper {
    my(undef, $value) = @_;
    $value =~ s/^\s+|\s+$//sg;
    return $value;
}

1;
