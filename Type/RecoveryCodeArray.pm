# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::RecoveryCodeArray;
use strict;
use Bivio::Base 'Type.StringArray';

my($_RC) = b_use('Type.RecoveryCode');

sub UNDERLYING_TYPE {
    return $_RC;
}

sub get_width {
    return 1000;
}

1;
