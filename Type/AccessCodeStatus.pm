# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::AccessCodeStatus;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => 0,
    PENDING => 1,
    PASSED => 2,
    ACTIVE => 3,
    USED => 4,
    ARCHIVED => 5,
]);

1;
