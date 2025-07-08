# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::UI::View::TOTP;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

sub enable_form {
    return shift->internal_body(vs_simple_form(UserEnableTOTPForm => [qw(
        UserEnableTOTPForm.totp_code
        UserEnableTOTPForm.RealmOwner.password
    )]));
}

sub disable_form {
    return shift->internal_body(vs_simple_form(UserDisableTOTPForm => [qw(
        UserDisableTOTPForm.totp_code
        UserDisableTOTPForm.RealmOwner.password
        UserDisableTOTPForm.recovery_code
    )]));
}

1;
