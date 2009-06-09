# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::UserAuth;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub adm_substitute_user {
    return shift->internal_body(vs_simple_form(AdmSubstituteUserForm => [qw{
	AdmSubstituteUserForm.login
    }]));
}

sub general_contact_mail {
    return shift->internal_put_base_attr(
	from => ['Model.ContactForm', 'from'],
	to => Mailbox(
	    vs_text('support_email'),
	    vs_text_as_prose('support_name'),
	),
	subject => Join([vs_site_name(), ' Web Contact']),
	body => ['Model.ContactForm', 'text'],
    );
}

sub general_contact {
    return shift->internal_body(vs_simple_form(ContactForm => [qw(
        ContactForm.from
	ContactForm.text
    )]));
}

sub login {
    return shift->internal_body(vs_simple_form(UserLoginForm => [qw(
        UserLoginForm.login
	UserLoginForm.RealmOwner.password
    )]));
}

sub missing_cookies {
    return shift->internal_body(DIV_prose(Join([
	P('It seems that your browser does not support cookies, or cookies have been disabled. Cookies are required for you to sign-in.'),
	H3('Enabling Cookies in your Browser'),
	P(q{The members area application requires the use of Cookies. By default, cookies are enabled in your browser. If you were directed to this page by our software, you or someone else has disable cookies in your browser. The following instructions are meant as a guide only. Please consult your browser's help system for a complete description. Scroll down this page until you find your browser. We apologize if your browser isn't in our list yet.}),
	map((
	    H4(shift(@$_)),
	    OL(Join([map(LI($_), @$_)])),
	), [
	    'Internet Explorer 6.0',
	    'Click on the Tools menu (at the very top of your window)',
	    'Select Internet Options',
	    'Switch to the Privacy tab',
	    'Slide the vertical slider to Medium',
	], [
	    'AOL 6.0 and above',
	    'Click on My AOL at the top of the AOL window',
	    'Select Preferences from the menu',
	    'Click on the WWW icon',
	    'Switch to the Privacy tab',
	    'Slide the vertical slider to Medium',
	], [
	    'Older Internet Explorer Versions',
	    'Click on the Tools menu (at the very top of your window)',
	    'Select Internet Options',
	    'Switch to the Security tab',
	    'Click on Internet in the Select a Web content zone',
	    'Further down, press the Custom Level button',
	    'Scroll down to the Cookies section in the Settings box',
	    'Click on Enable for Allow cookies that are stored option',
	    'Click on Enable for Allow per-session cookies option',
	], [
	    'Older AOL Versions',
	    'Click on My AOL at the top of the AOL window',
	    'Select Preferences from the menu',
	    'Click on the WWW icon',
	    'Click on Internet in the Select a Web content zone',
	    'Further down, press the Custom Level button',
	    'Scroll down to the Cookies section in the Settings box',
	    'Click on Enable for Allow cookies that are stored option',
	    'Click on Enable for Allow per-session cookies option',
	], [
	    'Netscape Communicator',
	    'Click on the Edit menu (at the very top of your window)',
	    'Select Preferences',
	    'Click on Advanced in the Category box',
	    'Click on Accept all cookies in the Cookies box',
	]),
    ])));
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
    return _mail(shift(@_), 'UserPasswordQueryForm', <<'EOF');
Please follow the link to reset your password:

Join([['Model.UserPasswordQueryForm', 'uri']]);

For your security, this link may be used one time only to set your
password.

You may contact customer support by replying to this message.

Thank you,
vs_site_name(); Support
EOF
}

sub create {
    return shift->internal_body(vs_simple_form(UserRegisterForm => [
	'UserRegisterForm.Email.email',
    ]));
}

sub create_done {
    return shift->internal_body(DIV_prose(Prose(<<'EOF')));
We have sent a confirmation email to
String(['Model.UserRegisterForm', 'Email.email']);.
Please follow the instructions in this email message to complete
your registration with vs_site_name();.
EOF
}

sub create_mail {
    return _mail(shift(@_), 'UserRegisterForm', <<'EOF');
Thank you for registering with vs_site_name();.
In order to complete your registration, please click on the
following link:

String(['Model.UserRegisterForm', 'uri']);

For your security, this link may be used one time only to set your
password.

You may contact customer support by replying to this message.

Thank you,
vs_site_name(); Support
EOF
}

sub internal_settings_form_extra_fields {
    return [];
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
        @$extra_fields,
	['UserSettingsListForm.RealmOwner.name', {
	    row_control => [qw(Model.UserSettingsListForm show_name)],
	}],
	['UserSettingsListForm.Email.email', {
	    row_control => [qw(Model.UserSettingsListForm show_email)],
	}],
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
    }));
}

sub unapproved_applicant_mail {
    return shift->internal_put_base_attr(
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

sub _mail {
    my($self, $form, $body) = @_;
    my($n) = $self->my_caller;
    view_put(
	mail_to => Mailbox(["Model.$form", 'Email.email']),
	mail_subject => vs_text_as_prose($n . '_subject'),
    );
    return $self->internal_body_prose($body);
}

sub _password_fields {
    my($m) = @_;
    return (
	["$m.old_password", {
	    row_control => ["Model.$m", 'display_old_password'],
	}],
	"$m.new_password",
	"$m.confirm_new_password",
    );
}

1;
