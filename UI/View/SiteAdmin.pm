# Copyright (c) 2008-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::SiteAdmin;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AUL) = __PACKAGE__->use('Model.AdmUserList');

sub remote_file_copy_form {
    return shift->internal_body(vs_simple_form(RemoteFileCopyListForm => [
	List(RemoteFileCopyListForm => [
	    SPAN_field(
		Join([
		    vs_descriptive_field('RemoteFileCopyListForm.want_realm')->[0],
		    String([['->get_list_model'], 'realm']),
		]),
	    ),
	    DIV(Join([
		If(['prepare_ok'],
		    Join([
			map((
			    Prose("RemoteFileCopyListForm.$_"),
			    If([$_, '->is_specified'],
			       UL_none(With([$_], LI(String(['value'])))),
			       Prose("RemoteFileCopyListForm.$_.empty")),
			), qw(to_delete to_update to_create)),
		    ]),
		    UL_none(
			With([['->get_list_model'], 'folder'],
			    LI(String(['value'])),
			),
		    ),
		),
	    ])),
	]),
    ]));
}

sub substitute_user_form {
    return shift->internal_body(vs_simple_form(SiteAdminSubstituteUserForm => [qw{
	SiteAdminSubstituteUserForm.login
    }]));
}

sub task_log {
    my($self) = @_;
    my($f) = $self->use('Model.TaskLogQueryForm');
    $self->internal_put_base_attr(selector => Join([
	ECMAScript(<<"EOF"),
function task_log_x_filter_onfocus (field) {
    if (field.value == "@{[$f->X_FILTER_HINT]}") {
        field.value = "";
    }
    field.className = "element enabled";
    return;
}
EOF
	Form($f->simple_package_name, Join([
	    Text({
		field => 'x_filter',
		id => 'x_filter',
		class => 'element disabled',
		ONFOCUS => 'task_log_x_filter_onfocus(this)',
		size => b_use('Type.Name')->get_width,
		max_width => b_use('Type.Line')->get_width,
	    }),
	    ScriptOnly({
		widget => Simple(''),
		alt_widget => FormButton('ok_button')->put(label => 'Refresh'),
	    }),
	]), {
	    form_method => 'get',
	    want_timezone => 0,
	    want_hidden_fields => 0,
	}),
    ]));
    return $self->internal_body(vs_paged_list('TaskLogList', [
	['TaskLog.date_time', {
	    column_widget => Join([
		Join([
		    SPAN_date(DateTime(['TaskLog.date_time'], 'DATE_TIME')),
		    Join([
			SPAN_super_user(
			    String(['super_user.RealmOwner.name'])),
			' acting as',
		    ], {control => ['TaskLog.super_user_id']}),
		    SPAN_author(Join([
			String(['RealmOwner.display_name']),
			String(
			    Join(['<', ['Email.email'], '>']),
			    {escape_html => 1},
			),
			String(['Phone.phone']),
		    ], {join_separator => ' '})),
		], {join_separator => ' '}),
		DIV_uri(String(['TaskLog.uri'])),
	    ]),
	}],
    ], {
	class => 'paged_list task_log',
	show_headings => 0,
    }));
}

sub unapproved_applicant_form {
    my($self, $extra_columns) = @_;
    return shift->internal_body(vs_simple_form(UnapprovedApplicantForm => [
	['UnapprovedApplicantForm.RealmUser.role', {
	    choices => ['->req', 'Model.RoleSelectList'],
	    list_display_field => 'display',
	    list_id_field => 'RealmUser.role',
	}],
	@{$extra_columns || []},
    ]));
}

sub unapproved_applicant_form_mail {
    return shift->internal_put_base_attr(
	from => Mailbox(
	    vs_text('support_email'),
	    vs_text_as_prose('support_name'),
	),
	to => Mailbox(
	    ['Model.UnapprovedApplicantList', 'Email.email'],
	    ['Model.UnapprovedApplicantList', 'RealmOwner.display_name'],
	),
	subject => Prose(['Model.UnapprovedApplicantForm', 'mail_subject']),
	body => Prose(['Model.UnapprovedApplicantForm', 'mail_body']),
    );
}

sub unapproved_applicant_list {
    my($self, $extra_columns) = @_;
    vs_user_email_list(
	'UnapprovedApplicantList',
	[
	    [privileges => {
		wf_list_link => {
		    query => 'THIS_DETAIL',
		    task => 'SITE_ADMIN_UNAPPROVED_APPLICANT_FORM',
		},
	    }],
	    @{$extra_columns || []},
	],
    );
    return;
}

sub user_list {
    my($self, $extra_columns) = @_;
    vs_user_email_list('SiteAdminUserList', [
	@{$extra_columns || []},
    ]);
    return;
}

1;
