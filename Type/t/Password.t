#!perl -w
# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$

use strict;
use Bivio::Test;
use Bivio::Type::Password;
Bivio::Test->new('Bivio::Type::Password')->unit([
    [] => [
        INVALID => 'xx',
        encrypt => [
            ['is some pass'] => qr{^[\w/+]{29}$}s,
        ],
        from_literal => [
            q(12345) => [undef, Bivio::TypeError->TOO_SHORT],
            q(1234567890123456789012345678901)
                => [undef, Bivio::TypeError->TOO_LONG],
            '123456' => qr/[\w]+/,
        ],
        is_equal => [
            ['KLySKlfjmX+gekfVh6WrM8jyJypNo', 'is some pass'] => 1,
            ['KLySKlfjmX+gekfVh6WrM8jyJypNo', '123456'] => 0,
            ['KLySKlfjmX+gekfVh6WrM8jyJypNo', undef] => 0,
            ['kzltIzEfODKJg', 'abcdef'] => 1,
            ['kzltIzEfODKJg', '123456'] => 0,
            ['kzltIzEfODKJg', undef] => 0,
            [undef, 'abcdef'] => 0,
            # Special case when both or undefined.
            [undef, undef] => 0,
        ],
        is_valid => [
            'KLySKlfjmX+gekfVh6WrM8jyJypNo' => 1,
            kzltIzEfODKJg => 1,
            abcdefg => 0,
            otp => 1,
            xx => 0,
        ],
    ],
]);
