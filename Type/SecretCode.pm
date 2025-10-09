# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::SecretCode;
use strict;
use Bivio::Base 'Type.Enum';

my($_DT) = b_use('Type.DateTime');
my($_MC) = b_use('Type.MnemonicCode');

my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    password_query_expiry_seconds => 30 * 60,
    password_mfa_challenge_expiry_seconds => 5 * 60,
    password_reset_expiry_seconds => 5 * 60,
});

__PACKAGE__->compile([
    UNKNOWN => 0,
    MFA_RECOVERY => 1,
    PASSWORD_QUERY => 2,
    PASSWORD_MFA_CHALLENGE => 3,
    PASSWORD_RESET => 4,
]);

sub from_literal_for_type {
    my($self, $value) = @_;
    if ($self->eq_mfa_recovery) {
        return $_MC->from_literal($value);
    }
    return $value;
}

sub generate_code_for_type {
    my($self) = @_;
    return Bivio::Biz::Random->password
        if $self->equals_by_name(qw(password_query password_mfa_challenge password_reset));
    return $_MC->generate_code
        if $self->eq_mfa_recovery;
    b_die('unsupported type');
    # DOES NOT RETURN
}

sub get_expiry_for_type {
    my($self) = @_;
    return $_DT->add_seconds($_DT->now, $_CFG->{lc($self->get_name) . '_expiry_seconds'})
        if $self->equals_by_name(qw(password_query password_mfa_challenge password_reset));
    return undef
        if $self->eq_mfa_recovery;
    b_die('unsupported type');
    # DOES NOT RETURN
}

sub handle_config {
    my(undef, $cfg) = @_;
    foreach my $f (qw(
        password_query_expiry_seconds
        password_mfa_challenge_expiry_seconds
        password_reset_expiry_seconds
    )) {
        b_die('missing ' . $f)
            unless $cfg->{$f};
    }
    $_CFG = $cfg;
    return;
}

1;
