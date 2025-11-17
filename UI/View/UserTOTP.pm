# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::UI::View::UserTOTP;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

sub enable_form {
    my($self) = @_;
    return $self->internal_body(vs_simple_form(UserEnableTOTPForm => [
        _fields('UserEnableTOTPForm', 0, 0),
    ]));
}

sub escalation_totp_form {
    my($self) = @_;
    return $self->internal_body(vs_simple_form(UserEscalationTOTPForm => [
        Join([
            'You have requested a restricted account action. Please enter your password and authenticator code to continue.',
            BR(), BR(),
            'Access to restricted actions will be granted for ',
            String([sub {
                return (int(b_use('Type.AccessCode')->ESCALATION_CHALLENGE->get_expiry_seconds_for_type) / 60);
            }]),
            ' minutes.',
            BR(), BR(),
        ]),
        'UserEscalationTOTPForm.RealmOwner.password',
        _fields('UserEscalationTOTPForm', 1, 0),
    ]));
}

sub disable_form {
    my($self) = @_;
    return $self->internal_body(vs_simple_form(UserDisableTOTPForm => []));
}

sub login_form {
    my($self) = @_;
    return $self->internal_body(vs_simple_form(UserLoginTOTPForm => [
        _fields('UserLoginTOTPForm', 1, 1),
    ]));
}

sub _fields {
    my($form, $with_recovery, $focus) = @_;
    $form ||= 'UserLoginTOTPForm';
    return (
        [$form . '.totp_code', {
            row_class => 'b_totp_code',
            $focus ? () : (
                ONFOCUS => 'return;',
            ),
        }],
        $with_recovery ? (
            [String('You may use an authenticator recovery code if you cannot access your authenticator at this time. Codes can only be used once. Used recovery codes will no longer be available.', {
                row_class => 'b_mfa_recovery_prologue',
                cell_colspan => 2,
            })],
            [$form . '.mfa_recovery_code', {
                row_class => 'b_mfa_recovery_code',
            }],
            [
                vs_blank_cell(),
                Link('Can\'t Access Authenticator?', '#', {
                    ID => 'b_recovery_access',
                }),
            ],
            [InlineJavaScript(
                <<'EOF',
(() => {
    const ra = document.getElementById("b_recovery_access");
    const tc = document.getElementsByClassName("b_totp_code")[0];
    const rp = document.getElementsByClassName("b_mfa_recovery_prologue")[0];
    const rc = document.getElementsByClassName("b_mfa_recovery_code")[0];
    if (ra && rp && tc && rc) {
        ra.addEventListener("click", (event) => {
            ra.style.display = "none";
            tc.style.display = "none";
            rp.style.display = "table-row";
            rc.style.display = "table-row";
        });
    }
    else {
        console.log("lost access link not found");
    }
})();
EOF
            )],
        ) : (),
    );
}

1;
