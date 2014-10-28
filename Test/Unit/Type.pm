# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Unit::Type;
use strict;
use Bivio::Base 'TestUnit.Unit';

my($_TE) = b_use('Bivio.TypeError');

sub UNDEF {
    return [undef, undef];
}

sub from_literal_error {
    my(undef, $type_error) = @_;
    return [undef, $_TE->from_any($type_error)];
}

sub handle_test_unit_autoload {
    my($self, $func) = @_;
    return [undef, $_TE->from_name($func)];
}

sub handle_test_unit_autoload_ok {
    my(undef, $func) = @_;
    return $_TE->is_valid_name($func) && $_TE->unsafe_from_name($func);
}

sub unit {
    return shift->unit_from_method_group(@_);
}

1;
