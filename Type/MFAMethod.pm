# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::MFAMethod;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => 0,
    TOTP => [1, 'TOTP', 'Time-Based One-Time Password'],
    # Only TOTP supported at this time; may support other methods later.
]);

sub get_model_class {
    my($self) = _assert_specified(@_);
    return b_use('Model.UserTOTP')
        if $self->eq_totp;
    b_die('unsupported type=', $self);
    # DOES NOT RETURN
}

sub get_login_form_class {
    my($self) = _assert_specified(@_);
    return b_use('Model.UserLoginTOTPForm')
        if $self->eq_totp;
    b_die('unsupported type=', $self);
    # DOES NOT RETURN
}

sub _assert_specified {
    my($self) = @_;
    b_die('unspecified')
        unless $self->is_specified;
    return $self;
}

1;
