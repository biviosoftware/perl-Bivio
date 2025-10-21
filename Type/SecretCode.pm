# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::SecretCode;
use strict;
use Bivio::Base 'Type.Enum';

my($_DT) = b_use('Type.DateTime');
my($_MC) = b_use('Type.MnemonicCode');
my($_R) = b_use('Biz.Random');
my($_TE) = b_use('Bivio.TypeError');

my($_CHARS) = [0..9, 'a'..'z', 'A'..'Z'];
my($_WIDTH) = 64;

my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    login_mfa_challenge_expiry_seconds => 5 * 60,
    password_query_expiry_seconds => 30 * 60,
    password_query_mfa_challenge_expiry_seconds => 5 * 60,
    password_reset_expiry_seconds => 5 * 60,
});

__PACKAGE__->compile([
    UNKNOWN => 0,
    LOGIN_MFA_CHALLENGE => 1,
    MFA_RECOVERY => 2,
    PASSWORD_QUERY => 3,
    PASSWORD_QUERY_MFA_CHALLENGE => 4,
    PASSWORD_RESET => 5,
]);

sub from_literal_for_type {
    my($self, $value) = @_;
    b_die('no type')
        if !ref($self) || $self->eq_unknown;
    if ($self->eq_mfa_recovery) {
        return $_MC->from_literal($value);
    }
    return (undef, $_TE->SYNTAX_ERROR)
        unless $value =~ qr/^[@$_CHARS]+$/;
    return $value;
}

sub generate_code_for_type {
    my($self) = @_;
    return $_R->string($_WIDTH, $_CHARS)
        if $self->equals_by_name(qw(
            login_mfa_challenge
            password_query
            password_query_mfa_challenge
            password_reset
        ));
    return $_MC->generate_code
        if $self->eq_mfa_recovery;
    b_die('unsupported type');
    # DOES NOT RETURN
}

sub get_expiry_for_type {
    my($self) = @_;
    return $_DT->add_seconds($_DT->now, $_CFG->{lc($self->get_name) . '_expiry_seconds'})
        if $self->equals_by_name(qw(
            login_mfa_challenge
            password_query
            password_query_mfa_challenge
            password_reset
        ));
    return undef
        if $self->eq_mfa_recovery;
    b_die('unsupported type');
    # DOES NOT RETURN
}

sub handle_config {
    my(undef, $cfg) = @_;
    foreach my $f (qw(
        login_mfa_challenge_expiry_seconds
        password_query_expiry_seconds
        password_query_mfa_challenge_expiry_seconds
        password_reset_expiry_seconds
    )) {
        b_die('missing ' . $f)
            unless $cfg->{$f};
    }
    $_CFG = $cfg;
    return;
}

1;
