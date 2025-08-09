# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::RecoveryCodeType;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => 0,
    TOTP_LOST => 1,
    PASSWORD_QUERY => 2,
    PASSWORD_RESET => 3,
]);

1;
