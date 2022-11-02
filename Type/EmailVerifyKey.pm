# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EmailVerifyKey;
use strict;
use Bivio::Base 'Type.Line';

my($_R) = b_use('Biz.Random');
my($_TE) = b_use('Bivio.TypeError');

sub create {
    return lc($_R->hex_digits(shift->get_width));
}

sub from_literal {
    my($proto) = shift;
    my($res, $err) = $proto->SUPER::from_literal(@_);
    return $err
        ? (undef, $err)
        : $res
            ? $res =~ /^[a-h0-9]{@{[$proto->get_width]}}$/
                ? lc($res)
                : (undef, $_TE->EMAIL_VERIFY_KEY)
            : (undef, $_TE->NULL);
}

sub get_width {
    return 10;
}

1;
