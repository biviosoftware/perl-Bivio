# Copyright (c) 2023 bivio Software, Inc.  All rights reserved.
package Bivio::Type::ConfirmPassword;
use strict;
use Bivio::Base 'Type.Line';

sub get_width {
    return 255;
}

sub is_password {
    return 1;
}

sub is_secure_data {
    return 1;
}

1;
