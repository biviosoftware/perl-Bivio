# Copyright (c) 2023 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::LoginAttemptState;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => 0,
    SUCCESS => 1,
    FAILURE => 2,
    LOCKOUT => 3,
    RESET => 4,
]);

1;
