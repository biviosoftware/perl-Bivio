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
            [String('You may log in using an authenticator recovery code if you cannot access your authenticator at this time. Codes can only be used once. Used recovery codes will no longer be available.', {
                row_class => 'b_mfa_recovery_prologue',
                cell_colspan => 2,
                $control ? (
                    row_control => $control,
                ) : (),
            })],
            [$form . '.mfa_recovery_code', {
                row_class => 'b_mfa_recovery_code',
                $control ? (
                    row_control => $control,
                ) : (),
            }],
            $form eq 'UserLoginTOTPForm' ? [$form . '.disable_mfa', {
                row_class => 'b_disable_mfa',
                $control ? (
                    row_control => $control,
                ) : (),
            }] : (),
            [
                vs_blank_cell(),
                Link('Can\'t Access Authenticator?', '#', {
                    ID => 'b_recovery_access',
                    $control ? (
                        row_control => $control,
                    ) : (),
                }),
            ],
            [InlineJavaScript(
                <<'EOF',
(() => {
    const ra = document.getElementById("b_recovery_access");
    const tc = document.getElementsByClassName("b_totp_code")[0];
    const rp = document.getElementsByClassName("b_mfa_recovery_prologue")[0];
    const rc = document.getElementsByClassName("b_mfa_recovery_code")[0];
    const dm = document.getElementsByClassName("b_disable_mfa")[0];
    if (ra && rp && tc && rc && dm) {
        ra.addEventListener("click", (event) => {
            ra.style.display = "none";
            tc.style.display = "none";
            rp.style.display = "table-row";
            rc.style.display = "table-row";
            dm.style.display = "table-row";
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
