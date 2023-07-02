# Copyright (c) 2023 bivio Software, Inc.  All rights reserved.
package Bivio::Type::PasswordHashHMACSHA1;
use strict;
use Bivio::Base 'Type.PasswordHashBase';
use Digest::SHA ();

sub ID {
    return 'hmac_sha1';
}

sub REGEX {
    return qr{^[a-z0-9+/]{29}$}ois;
}

sub SALT_LENGTH {
    return 2;
}

sub as_literal {
    my($self) = @_;
    # Deprecated literal format
    return ($self->get_salt . $self->get_hash);
}

sub internal_to_literal {
    my($proto, $clear_text, $salt) = @_;
    # Deprecated literal format
    return $salt . Digest::SHA::hmac_sha1_base64($clear_text, $salt);
}

sub internal_to_parts {
    my($proto, $value) = @_;
    return [$proto->ID, substr($value, 0, 2), substr($value, 2)];
}

1;
