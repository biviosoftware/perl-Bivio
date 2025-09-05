# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::UI::View::TOTP;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

sub enable_form {
    return shift->internal_body(vs_simple_form(UserEnableTOTPForm => [qw(
        UserEnableTOTPForm.RealmOwner.password
        UserEnableTOTPForm.totp_code
    )]));
}

sub disable_form {
    return shift->internal_body(vs_simple_form(UserDisableTOTPForm => [qw(
        UserDisableTOTPForm.RealmOwner.password
        UserDisableTOTPForm.totp_code
        UserDisableTOTPForm.recovery_code
    )]));
}

sub recovery_code_list {
    return shift->internal_body(RecoveryCodeList());
}

sub recovery_form {
    return shift->internal_body(vs_simple_form(UserRecoveryForm => [qw(
        UserRecoveryForm.recovery_code
    )]));
}

sub totp_form {
    return shift->internal_body(vs_simple_form(UserLoginTOTPForm => [
        ['UserLoginTOTPForm.totp_code', {
            row_class => 'b_totp_code',
        }],
        ['UserLoginTOTPForm.totp_lost_recovery_code', {
            row_class => 'b_totp_lost_recovery_code',
        }],
        ['UserLoginTOTPForm.disable_totp', {
            row_class => 'b_disable_totp',
        }],
        [
            vs_blank_cell(),
            Link('Lost Authenticator Access?', '#', {
                ID => 'b_totp_lost_access',
            }),
        ],
        InlineJavaScript(<<'EOF'),
(() => {
    const la = document.getElementById("b_totp_lost_access");
    const c = document.getElementsByClassName("b_totp_code")[0];
    const lrc = document.getElementsByClassName("b_totp_lost_recovery_code")[0];
    const dt = document.getElementsByClassName("b_disable_totp")[0];
    if (la && c && lrc && dt) {
        la.addEventListener("click", (event) => {
            la.style.display = "none";
            c.style.display = "none";
            lrc.style.display = "table-row";
            dt.style.display = "table-row";
        });
    }
    else {
        console.log("lost access link not found");
    }
})();
EOF
    ]));
}

1;
