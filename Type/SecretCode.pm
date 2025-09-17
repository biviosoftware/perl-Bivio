# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::SecretCode;
use strict;
use Bivio::Base 'Type.Enum';

my($_DT) = b_use('Type.DateTime');
my($_MC) = b_use('Type.MnemonicCode');

my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    password_query_expiry_seconds => 30 * 60,
});

__PACKAGE__->compile([
    UNKNOWN => 0,
    MFA_RECOVERY => 1,
    PASSWORD_QUERY => 2,
    PASSWORD_RESET => 3,
]);

sub from_literal_for_type {
    my(undef, $type, $value) = @_;
    if ($type->eq_mfa_recovery) {
        return $_MC->from_literal($value);
    }
    return $value;
}

sub generate_code_for_type {
    my(undef, $type) = @_;
    return Bivio::Biz::Random->password
        if $type->eq_password_query;
    return $_MC->generate_code
        if $type->eq_mfa_recovery;
    b_die('unsupported type');
    # DOES NOT RETURN
}

sub get_expiry_for_type {
    my(undef, $type) = @_;
    return $_DT->add_seconds($_DT->now, $_CFG->{password_query_expiry_seconds})
        if $type->eq_password_query;
    return undef;
}

sub handle_config {
    my(undef, $cfg) = @_;
    b_die('missing password_query_expiry_seconds')
        unless $cfg->{password_query_expiry_seconds};
    $_CFG = $cfg;
    return;
}

1;
