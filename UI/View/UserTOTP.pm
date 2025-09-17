# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::UI::View::UserTOTP;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

sub enable_form {
    my($self) = @_;
    return $self->internal_body(vs_simple_form(UserEnableTOTPForm => [
        'UserEnableTOTPForm.RealmOwner.password',
        $self->totp_fields('UserEnableTOTPForm'),
    ]));
}

sub disable_form {
    my($self) = @_;
    return $self->internal_body(vs_simple_form(UserDisableTOTPForm => [
        'UserDisableTOTPForm.RealmOwner.password',
        $self->totp_fields('UserDisableTOTPForm', 1),
    ]));
}

sub recovery_code_list {
    return shift->internal_body(MFARecoveryCodeList());
}

sub totp_fields {
    my(undef, $form, $with_recovery, $control) = @_;
    $form ||= 'UserLoginTOTPForm';
    return (
        [$form . '.totp_code', {
            row_class => 'b_totp_code',
            $control ? (
                row_control => $control,
            ) : (),
        }],
        $with_recovery ? (
            [$form . '.recovery_code', {
                row_class => 'b_recovery_code',
                $control ? (
                    row_control => $control,
                ) : (),
            }],
            $form eq 'UserLoginTOTPForm' ? [$form . '.disable_totp', {
                row_class => 'b_disable_totp',
                $control ? (
                    row_control => $control,
                ) : (),
            }] : (),
            [
                vs_blank_cell(),
                Link('Lost Authenticator Access?', '#', {
                    ID => 'b_recovery_access',
                    $control ? (
                        row_control => $control,
                    ) : (),
                }),
            ],
            [InlineJavaScript(
                <<'EOF',
(() => {
    const fa = document.getElementById("b_recovery_access");
    const tc = document.getElementsByClassName("b_totp_code")[0];
    const fc = document.getElementsByClassName("b_recovery_code")[0];
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
                $control ? {row_control => $control} : (),
            )],
        ) : (),
    );
}

sub totp_form {
    my($self) = @_;
    return $self->internal_body(vs_simple_form(UserLoginTOTPForm => [
        $self->totp_fields('UserLoginTOTPForm', 1),
    ]));
}

1;
