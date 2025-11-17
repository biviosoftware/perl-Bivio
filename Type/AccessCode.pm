# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::AccessCode;
use strict;
use Bivio::Base 'Type.Enum';

# TODO: "AccessCode"?

my($_DT) = b_use('Type.DateTime');
my($_MC) = b_use('Type.MnemonicCode');
my($_R) = b_use('Biz.Random');
my($_TE) = b_use('Bivio.TypeError');

__PACKAGE__->compile([
    UNKNOWN => 0,
    LOGIN_CHALLENGE => 1,
    ESCALATION_CHALLENGE => 2,
    MFA_RECOVERY => 3,
    PASSWORD_QUERY => 4,
]);

my($_CHARS) = ['a'..'z', 'A'..'Z', '0'..'9'];
my($_WIDTH) = 64;
my($_EPHEMERAL_TYPES) = [qw(
    LOGIN_CHALLENGE
    ESCALATION_CHALLENGE
    PASSWORD_QUERY
)];

my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    login_challenge_expiry_seconds => 5 * 60,
    escalation_challenge_expiry_seconds => 5 * 60,
    password_query_expiry_seconds => 60 * 60,
});

sub from_literal_for_type {
    my($self, $value) = _assert_specified(@_);
    if ($self->eq_mfa_recovery) {
        return $_MC->from_literal($value);
    }
    return (undef, $_TE->SYNTAX_ERROR)
        unless $value =~ qr/^[@$_CHARS]+$/;
    return $value;
}

sub generate_code_for_type {
    my($self) = _assert_specified(@_);
    return $_R->string($_WIDTH, $_CHARS)
        if $self->equals_by_name(@$_EPHEMERAL_TYPES);
    return $_MC->generate_code
        if $self->eq_mfa_recovery;
    b_die('unsupported type');
    # DOES NOT RETURN
}

sub get_expiry_for_type {
    my($self) = _assert_specified(@_);
    return $_DT->add_seconds($_DT->now, $_CFG->{_expiry_cfg_field($self)})
        if $self->equals_by_name(@$_EPHEMERAL_TYPES);
    return undef
        if $self->eq_mfa_recovery;
    b_die('unsupported type');
    # DOES NOT RETURN
}

sub get_expiry_seconds_for_type {
    my($self) = _assert_specified(@_);
    return $_CFG->{_expiry_cfg_field($self)} // 0;
}

sub handle_config {
    my(undef, $cfg) = @_;
    foreach my $t (@$_EPHEMERAL_TYPES) {
        b_die('missing expiry seconds for type=', $t)
            unless $cfg->{_expiry_cfg_field($t)};
    }
    $_CFG = $cfg;
    return;
}

sub _assert_specified {
    my($self) = @_;
    b_die('no type')
        unless $self->is_specified;
    return @_;
}

sub _expiry_cfg_field {
    my($type) = @_;
    $type = $type->get_name
        if ref($type);
    return lc($type) . '_expiry_seconds';
}

1;
