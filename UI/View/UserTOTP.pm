# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::UI::View::UserTOTP;
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
        UserDisableTOTPForm.fallback_code
    )]));
}

sub fallback_code_list {
    return shift->internal_body(MFAFallbackCodeList());
}

sub totp_form {
    return shift->internal_body(vs_simple_form(UserLoginTOTPForm => [
        ['UserLoginTOTPForm.totp_code', {
            row_class => 'b_totp_code',
        }],
        ['UserLoginTOTPForm.fallback_code', {
            row_class => 'b_fallback_code',
        }],
        ['UserLoginTOTPForm.disable_totp', {
            row_class => 'b_disable_totp',
        }],
        [
            vs_blank_cell(),
            Link('Lost Authenticator Access?', '#', {
                ID => 'b_fallback_access',
            }),
        ],
        InlineJavaScript(<<'EOF'),
(() => {
    const fa = document.getElementById("b_fallback_access");
    const tc = document.getElementsByClassName("b_totp_code")[0];
    const fc = document.getElementsByClassName("b_fallback_code")[0];
    const dt = document.getElementsByClassName("b_disable_totp")[0];
    if (fa && tc && fc && dt) {
        fa.addEventListener("click", (event) => {
            fa.style.display = "none";
            tc.style.display = "none";
            fc.style.display = "table-row";
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
