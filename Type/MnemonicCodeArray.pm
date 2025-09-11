# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::MnemonicCodeArray;
use strict;
use Bivio::Base 'Type.StringArray';

my($_MC) = b_use('Type.MnemonicCode');

sub UNDERLYING_TYPE {
    return $_MC;
}

sub get_width {
    return 1000;
}

1;
