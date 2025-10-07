# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::SecretCodeStatus;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => 0,
    ACTIVE => 1,
    USED => 2,
    ARCHIVED => 3,
]);

1;
