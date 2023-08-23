# Copyright (c) 1999-2023 bivio Software, Inc.  All rights reserved.
package Bivio::Type::Password;
use strict;
use Bivio::Base 'Type.Line';

my($_HMACSHA512) = b_use('Type.PasswordHashHMACSHA512');
my($_HASH_TYPES) = [
    b_use('Type.PasswordHashCrypt'),
    b_use('Type.PasswordHashHMACSHA1'),
    $_HMACSHA512,
];
my($_SUPPORTED_HASH_TYPE) = {map(($_ => 1), @$_HASH_TYPES)};

# C<Bivio::Type::Password> indicates the input is a password entry.
# It should be handled with care, e.g. never displayed to user.

sub CURRENT_HASH_TYPE {
    return $_HMACSHA512,
}

sub INVALID {
    # Returns invalid password (save literally!).
    return 'xx';
}

sub OTP_VALUE {
    return 'otp';
}

sub compare {
    my($proto, $hashed, $clear_text) = @_;
    return -1
        unless defined($hashed);
    # Incoming clear text is never allowed to match stored OTP value and instead must be verified
    # via the OTP module.
    return -1
        if $hashed eq $proto->OTP_VALUE;
    return 1
        unless defined($clear_text);
    return _to_hash_type_instance_or_die($hashed)->compare($clear_text);
}

sub encrypt {
    my($proto, $clear_text, $type) = @_;
    $type ||= $proto->CURRENT_HASH_TYPE;
    b_die("unsupported hash type=$type")
        unless $_SUPPORTED_HASH_TYPE->{$type};
    return $type->to_literal($clear_text);
}

sub get_min_width {
    # Allow existing deprecated 6-7 character passwords.
    return 6;
}

sub get_width {
    return 255;
}

sub is_otp {
    my($proto, $value) = @_;
    return $proto->OTP_VALUE eq ($value || '') ? 1 : 0;
}

sub is_password {
    return 1;
}

sub is_secure_data {
    return 1;
}

sub is_valid {
    my($proto, $hashed, $expected_hash_type) = @_;
    return 0
        unless $hashed;
    return 1
        if $hashed eq $proto->OTP_VALUE;
    my($hti) = _to_hash_type_instance($hashed);
    if ($expected_hash_type) {
        return $proto->is_blesser_of($hti, $expected_hash_type);
    }
    return $hti ? 1 : 0;
}

sub needs_upgrade {
    my($proto, $hashed) = @_;
    return 0
        if $hashed eq $proto->OTP_VALUE;
    return $proto->CURRENT_HASH_TYPE->is_blesser_of(_to_hash_type_instance_or_die($hashed)) ? 0 : 1;
}

sub _to_hash_type_instance {
    my($hashed) = @_;
    foreach my $type (@$_HASH_TYPES) {
        my($hti, $error) = $type->from_literal($hashed);
        return $hti
            unless $error;
    }
    return;
}

sub _to_hash_type_instance_or_die {
    my($hashed) = @_;
    return _to_hash_type_instance($hashed)
        || b_die('invalid password hash=', $hashed);
}

1;
