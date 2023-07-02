# Copyright (c) 1999-2023 bivio Software, Inc.  All rights reserved.
package Bivio::Type::Password;
use strict;
use Bivio::Base 'Type.Line';

my($_F) = b_use('IO.File');

my($_WEAK_PASSWORDS) = {};
my($_C) = b_use('IO.Config');
my($_CFG);
$_C->register($_CFG = {
    weak_regex => [],
    weak_corpus_path => undef,
    in_weak_corpus => sub {
        # This implementation should only be used for a corpus of limited size. Larger corpuses
        # should be stored in an external database, with a new implementation that uses said
        # database.
        return $_WEAK_PASSWORDS->{shift(@_)} ? 1 : 0;
    },
});
my($_CURRENT_HASH_TYPE) = b_use('Type.PasswordHashHMACSHA512');
my($_HASH_TYPES) = [
    b_use('Type.PasswordHashCrypt'),
    b_use('Type.PasswordHashHMACSHA1'),
    $_CURRENT_HASH_TYPE,
];

# C<Bivio::Type::Password> indicates the input is a password entry.
# It should be handled with care, e.g. never displayed to user.

sub HASH_TYPE {
    return $_CURRENT_HASH_TYPE;
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
    my($hti) = _to_hash_type_instance($hashed);
    b_die('invalid password hash')
        unless ref($hti);
    return $hti->compare($clear_text);
}

sub encrypt {
    my(undef, $clear_text, $type) = @_;
    $type ||= $_CURRENT_HASH_TYPE;
    b_die("unsupported hash type=$type")
        unless grep($_ eq $type, @$_HASH_TYPES);
    return $type->to_literal($clear_text);
}

sub get_min_width {
    # As of 07/2023, new passwords are required to be 8 characters, but we are allowing existing
    # short passwords.
    return 6;
}

sub get_width {
    return 255;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    if ($_CFG->{weak_corpus_path} && -f $_CFG->{weak_corpus_path}) {
        $_F->do_lines($_CFG->{weak_corpus_path}, sub {
            $_WEAK_PASSWORDS->{shift(@_)} = 1;
            return 1;
        });
    }
    return;
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
        return ref($hti) eq $expected_hash_type ? 1 : 0;
    }
    return ref($hti) ? 1 : 0;
}

sub needs_upgrade {
    my($proto, $hashed) = @_;
    return 0
        if $hashed eq $proto->OTP_VALUE;
    my($hti) = _to_hash_type_instance($hashed);
    b_die('invalid password hash')
        unless ref($hti);
    return ref($hti) ne $_CURRENT_HASH_TYPE ? 1 : 0;
}

sub validate_clear_text {
    my($proto, $clear_text) = @_;
    # Have to check length outside of usual width checking as deprecated 6-7 character passwords are
    # still allowed.
    return 'TOO_SHORT'
        if length($clear_text) < 8;
    return 'WEAK_PASSWORD'
        if _is_weak($clear_text, $user_id, $user_name, $user_emails);
    return;
}

sub _is_weak {
    my($clear_text, $user_id, $user_name, $user_emails) = @_;
    b_die('must provide user realm_id, user realm owner name, user email addresses')
        unless $user_id && $user_name && $user_emails;
    return 1
        if $clear_text eq $user_id;
    return 1
        if $clear_text eq $user_name;
    foreach my $email (@$user_emails) {
        return 1
            if $clear_text eq $email;
        my($local_part) = split('@', $email);
        return 1
            if $clear_text eq $local_part;
        my(@email_parts) = split(qr/\W/, $email);
        return 1
            if $clear_text eq join('', @email_parts);
    }
    foreach my $regex (@{$_CFG->{weak_regex} || []}) {
        return 1
            if $clear_text =~ $regex;
    }
    return 1
        if $_CFG->{in_weak_corpus}($clear_text);
    return 0;
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

1;
