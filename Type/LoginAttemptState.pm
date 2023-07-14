# Copyright (c) 2023 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::LoginAttemptState;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    SUCCESS => 0,
    FAILURE => 1,
    LOCKOUT => 2,
    RESET => 3,
]);

1;
