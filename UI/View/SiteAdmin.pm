# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::SiteAdmin;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AUL) = __PACKAGE__->use('Model.AdmUserList');

sub substitute_user_form {
    return shift->internal_body(vs_simple_form(SiteAdminSubstituteUserForm => [qw{
	SiteAdminSubstituteUserForm.login
    }]));
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
	    vs_text('support_name'),
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
