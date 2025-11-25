# Copyright (c) 2007-2023 bivio Software, Inc.  All Rights Reserved.
package Bivio::UI::View::UserAuth;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_AMRCL) = b_use('Action.MFARecoveryCodeList');

sub adm_substitute_user {
    return shift->internal_body(vs_simple_form(AdmSubstituteUserForm => [qw{
        AdmSubstituteUserForm.login
    }]));
}

sub create {
    return shift->internal_body(vs_simple_form(UserRegisterForm => [
        'UserRegisterForm.Email.email',
    ]));
}

sub create_done {
    return shift->internal_body(DIV_prose(_prose('create_done.body')));
}

sub create_mail {
    return shift->internal_mail;
}

sub email_verify {
    return shift->internal_body(vs_simple_form(EmailVerifyForm => [
        'EmailVerifyForm.Email.email',
    ]));
}

sub email_verify_force {
    return shift->internal_body(vs_simple_form('EmailVerifyForceForm'));
}

sub email_verify_mail {
    my($self) = @_;
    view_put(
        mail_to => Mailbox(['Model.EmailVerifyForm', 'Email.email']),
        mail_subject => 'Verification Request',
    );
    return _support_message($self, <<'EOF');
Please follow the link to complete the email verification process:

String(['Model.EmailVerifyForm', 'uri']);
EOF
}

sub email_verify_sent {
    return shift->internal_body(P_prose(Prose(<<'EOF')));
An email has been sent to String(['Model.EmailVerifyForm', 'Email.email']);.
Please click on the link in the email message to complete the verification
process.
EOF
}

sub escalation_plain_form {
    return shift->internal_body(vs_simple_form(UserEscalationPlainForm => [
        Join([
            'You have requested a restricted account action. Please enter your password to continue.',
            BR(), BR(),
            'Access to restricted actions will be granted for ',
            String([sub {
                return b_use('Type.AccessCode')->ESCALATION_CHALLENGE->get_expiry_seconds_for_type / 60;
            }]),
            ' minutes.',
            BR(), BR(),
        ]),
        'UserEscalationPlainForm.RealmOwner.password',
    ]));
}

sub general_contact_mail {
    return shift->internal_put_base_attr(
        from => ['Model.ContactForm', 'from'],
        to => Mailbox(
            vs_text('support_email'),
            vs_text_as_prose('support_name'),
        ),
        subject => ['Model.ContactForm', 'subject'],
        body => ['Model.ContactForm', 'text'],
    );
}

sub general_contact {
    return shift->internal_body(vs_simple_form(ContactForm => [qw(
        ContactForm.from
        ContactForm.text
    )]));
}

sub internal_mail {
    my($self) = @_;
    my($n) = $self->my_caller;
    view_put(map(("mail_$_" => _prose($n, $_)), qw(to subject)));
    return $self->internal_body_prose(_prose($n, 'body'));
}

sub internal_settings_form_extra_fields {
    return [];
}

sub login {
    return shift->internal_body(vs_simple_form(UserLoginForm => [
        'UserLoginForm.login',
        'UserLoginForm.RealmOwner.password',
    ]));
}

sub mfa_recovery_code_print_list {
    view_main(Page({
        xhtml => 1,
        style => view_widget_value('xhtml_style'),
        head => Join([
            vs_text_as_prose('xhtml_head_title'),
        ]),
        body => Join([
            DIV_main_top(DIV_title(Join([vs_site_name(), vs_text_as_prose('xhtml_title')], ' '))),
            DIV_main_body([sub {
                my($source) = @_;
                return Grid([
                    map([$_], @{$_AMRCL->get_codes_from_query($source)}),
                ], {class => 'b_mfa_recovery_codes'});
            }]),
        ]),
    }));
    return;
}

sub mfa_recovery_code_refill_list {
    return shift->internal_body(vs_simple_form(MFARecoveryCodeListRefillForm => [
        Join([
            'Your authenticator recovery code list was running low, so we\'ve generated a new list for you.',
            BR(), BR(),
            MFARecoveryCodeList(),
        ]),
        '*ok_button',
    ]));
}

sub mfa_recovery_code_list_regenerate_form {
    my($self, $link) = @_;
    return shift->internal_body(
        If(
            [qw(->ureq Model.MFARecoveryCodeList)],
            Join([
                DIV_mfa_recovery_code_list(MFARecoveryCodeList()),
                BR(), BR(),
                $link || Link('Back to my site', 'MY_SITE'),
            ]),
            vs_simple_form(MFARecoveryCodeListRegenerateForm => []),
        ),
    );
}

sub mfa_recovery_code_list_regenerate_mail {
    return shift->internal_mail;
}

sub missing_cookies {
    return shift->internal_body(DIV_prose(_prose('missing_cookies.body')));
}

sub password {
    return shift->internal_body(vs_simple_form(UserPasswordForm => [
        _password_fields('UserPasswordForm'),
    ]));
}

sub password_query {
    return shift->internal_body(vs_simple_form(UserPasswordQueryForm => [
        'UserPasswordQueryForm.Email.email',
    ]));
}

sub password_query_ack {
    return shift->internal_body('');
}

sub password_query_mail {
    return shift->internal_mail;
}

sub settings_form {
    my($self) = @_;
    my($extra_fields) = $self->internal_settings_form_extra_fields;
    return shift->internal_body(vs_list_form(UserSettingsListForm => [
        "'user_password",
        'UserSettingsListForm.User.first_name',
        'UserSettingsListForm.User.middle_name',
        'UserSettingsListForm.User.last_name',
        'UserSettingsListForm.page_size',
        ['UserSettingsListForm.time_zone_selector', {
            size => 40,
        }],
        @$extra_fields,
        ['UserSettingsListForm.RealmOwner.name', {
            row_control => [qw(Model.UserSettingsListForm show_name)],
        }],
        'UserSettingsListForm.Email.email',
        'UserSettingsListForm.UserDefaultSubscription.subscribed_by_default',
        {
            column_heading_class => 'left',
            column_heading => 'RealmOwner.display_name',
            column_widget => vs_display('UserSubscriptionList.RealmOwner.display_name'),
            column_use_list => 1,
        },
        {
            field => 'is_subscribed',
            column_data_class => 'checkbox',
            column_heading => 'is_subscribed',
        },
    ], {
        empty_list_widget => Simple(''),
        class => 'list table',
    }, {
        indent_list => 1,
    }));
}

sub unapproved_applicant_mail {
    return shift->internal_put_base_attr(
#TODO: use _prose() for this
        from => Mailbox(
            ['Model.UserRegisterForm', 'Email.email'],
            ['Model.UserRegisterForm', 'RealmOwner.display_name'],
        ),
        to => Mailbox(vs_constant('site_admin_realm_name')),
        subject => Join([
            'Applicant: ',
            Mailbox(
                ['Model.UserRegisterForm', 'Email.email'],
                ['Model.UserRegisterForm', 'RealmOwner.display_name'],
            ),
        ]),
        body => Prose(<<'EOF'),
Registration request from:

String(['Model.UserRegisterForm', 'RealmOwner.display_name']); String(['Model.UserRegisterForm', 'Email.email']);

A list of pending applicants can be found here:

Link(URI({
    realm => vs_constant('site_admin_realm_name'),
    task_id => 'SITE_ADMIN_UNAPPROVED_APPLICANT_LIST',
}));
EOF
    );
}

sub user_locked_out_mail {
    return shift->internal_mail;
}

sub user_locked_out {
    return shift->internal_body('');
}

sub _password_fields {
    my($m) = @_;
    return (
        ["$m.old_password", {
            row_control => ["Model.$m", 'require_old_password'],
        }],
        "$m.new_password",
        "$m.confirm_new_password",
    );
}

sub _prose {
    return vs_text_as_prose('UserAuth', @_);
}

sub _support_mailbox {
    return Mailbox(
        vs_text('support_email'),
        Join([vs_site_name(), ' Support']),
    );
}

sub _support_message {
    my($self, $text) = @_;
    view_put(
        mail_from => _support_mailbox(),
    );
    return $self->internal_body_prose($text . <<'EOF');

You may contact support by replying to this message.

Thank you,
vs_site_name(); Support
EOF
}

1;
