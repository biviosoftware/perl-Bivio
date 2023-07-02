# Copyright (c) 2023 bivio Software, Inc.  All rights reserved.
package Bivio::Type::PasswordHashHMACSHA512;
use strict;
use Bivio::Base 'Type.PasswordHashBase';
use Digest::SHA ();

sub ID {
    return 'hmac_sha512';
}

sub REGEX {
    my($proto) = @_;
    my($id) = $proto->ID;
    return qr{^\$$id\$[a-z0-9]{16}\$[a-z0-9+/]{86}$}ois;
}

sub SALT_LENGTH {
    return 16;
}

sub internal_to_literal {
    my($proto, $clear_text, $salt) = @_;
    return $proto->internal_format_literal(
        $salt,
        Digest::SHA::hmac_sha512_base64($clear_text, $salt),
    );
}

1;
