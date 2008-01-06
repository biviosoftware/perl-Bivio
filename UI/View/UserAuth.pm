# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
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
	to => Join([
	    Mailbox(
		vs_text('support_email'),
		vs_text_as_prose('support_name'),
	    ),
	    ['Model.ContactForm', 'from'],
	], ', '),
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
	['UserPasswordForm.old_password', {
	    row_control => [
		'Model.UserPasswordForm', 'display_old_password',
	    ],
	}],
	'UserPasswordForm.new_password',
	'UserPasswordForm.confirm_new_password',
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

sub _mail {
    my($self, $form, $body) = @_;
    my($n) = $self->my_caller;
    view_put(
	mail_to => Mailbox(["Model.$form", 'Email.email']),
	mail_subject => vs_text_as_prose($n . '_subject'),
    );
    return $self->internal_body_prose($body);
}

1;
