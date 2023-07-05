# Copyright (c) 2023 bivio Software, Inc.  All rights reserved.
package Bivio::Type::PasswordHashCrypt;
use strict;
use Bivio::Base 'Type.PasswordHashBase';

sub ID {
    return 'crypt';
}

sub REGEX {
    return qr/^.{13}$/;
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
    my(undef, $clear_text, $salt) = @_;
    # Deprecated literal format
    return crypt($clear_text, $salt);
}

sub internal_to_parts {
    my($proto, $value) = @_;
    return {
        id => $proto->ID,
        salt => substr($value, 0, $proto->SALT_LENGTH),
        hash => substr($value, $proto->SALT_LENGTH),
    };
}

1;
