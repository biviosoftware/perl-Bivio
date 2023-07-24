# Copyright (c) 1999-2023 bivio Software, Inc.  All rights reserved.
package Bivio::Type::Password;
use strict;
use Bivio::Base 'Type.Name';
use Bivio::TypeError;
use Digest::SHA ();

# C<Bivio::Type::Password> indicates the input is a password entry.
# It should be handled with care, e.g. never displayed to user.

my(@_SALT_CHARS) = (
    'a'..'z',
    'A'..'Z',
    '0'..'9',
);
my($_SALT_INDEX_MAX) = int(@_SALT_CHARS) - 1;
my($_CRYPT_VALID_LENGTH) = 13;
my($_VALID_SHA_RE) = qr{^[a-z0-9+/]{29}$}ois;

sub INVALID {
    # Returns invalid password (save literally!).
    return 'xx';
}

sub OTP_VALUE {
    return 'otp';
}

sub compare {
    my($proto, $encrypted, $incoming) = @_;
    return -1
        unless defined($encrypted);
    return 1
        unless defined($incoming);
    my($salt) = substr($encrypted, 0, 2);
    my($i) = length($encrypted) == $_CRYPT_VALID_LENGTH
        ? crypt($incoming, $salt)
        : _encrypt($incoming, $salt);
    return $encrypted cmp $i;
}

sub encrypt {
    my(undef, $password) = @_;
    my($salt) = '';
    for (my($i) = 0; $i < 2; $i++) {
        $salt .= $_SALT_CHARS[int(rand($_SALT_INDEX_MAX) + 0.5)];
    };
    return _encrypt($password, $salt);

}

sub get_min_width {
    # As of 07/2023, new passwords are required to be 8 characters, but we are allowing existing
    # short passwords.
    return 6;
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
    my($proto, $value) = @_;
    return $value && (
        length($value) == $_CRYPT_VALID_LENGTH
            || $value =~ $_VALID_SHA_RE
            || $value eq $proto->OTP_VALUE
    ) ? 1 : 0;
}

sub validate_clear_text {
    my($proto, $clear_text) = @_;
    # Have to check length outside of usual width checking as deprecated 6-7 character passwords are
    # still allowed.
    return 'TOO_SHORT'
        if length($clear_text) < 8;
    return;
}

sub _encrypt {
    my($clear, $salt) = @_;
    return $salt . Digest::SHA::hmac_sha1_base64($clear, $salt);
}

1;
