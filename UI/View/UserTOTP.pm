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

sub enable_mail {
    return shift->internal_mail;
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
        [vs_blank_cell()],
        _fields('UserEscalationTOTPForm', 1, 0),
    ]));
}

sub disable_form {
    my($self) = @_;
    return $self->internal_body(vs_simple_form(UserDisableTOTPForm => []));
}

sub disable_mail {
    return shift->internal_mail;
}

sub internal_mail {
    my($self) = @_;
    my($n) = $self->my_caller;
    view_put(map(("mail_$_" => _prose($n, $_)), qw(to subject)));
    return $self->internal_body_prose(_prose($n, 'body'));
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
        [vs_blank_cell(), String('- OR -')],
        $with_recovery ? (
            [$form . '.mfa_recovery_code', {
                row_class => 'b_mfa_recovery_code',
            }],
            [vs_blank_cell()],
        ) : (),
    );
}

sub _prose {
    return vs_text_as_prose('UserTOTP', @_);
}

1;
