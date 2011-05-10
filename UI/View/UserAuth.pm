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

sub login {
    return shift->internal_body(vs_simple_form(UserLoginForm => [qw(
        UserLoginForm.login
	UserLoginForm.RealmOwner.password
    )]));
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
    return _mail(shift(@_), 'UserPasswordQueryForm');
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
    return _mail(shift(@_), 'UserRegisterForm');
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
        'UserSettingsListForm.time_zone_selector',
        @$extra_fields,
	['UserSettingsListForm.RealmOwner.name', {
	    row_control => [qw(Model.UserSettingsListForm show_name)],
	}],
	'UserSettingsListForm.Email.email',
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

sub _mail {
    my($self, $form) = @_;
    my($n) = $self->my_caller;
    view_put(
	mail_to => Mailbox(["Model.$form", 'Email.email']),
	mail_subject => _prose($n, 'subject'),
    );
    return $self->internal_body_prose(_prose($n, 'body'));
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

sub _prose {
    return vs_text_as_prose('UserAuth', @_);
}

1;
