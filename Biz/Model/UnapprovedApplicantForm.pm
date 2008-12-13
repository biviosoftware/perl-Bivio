# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UnapprovedApplicantForm;
use strict;
use Bivio::Base 'Model.GroupUserForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_T) = b_use('FacadeComponent.Text');
my($_V) = b_use('UI.View');
my($_R) = b_use('Auth.Role');

sub USER_LIST_CLASS {
    return 'UnapprovedApplicantList';
}

sub execute_ok {
    my($self) = @_;
    $self->internal_send_mail;
    return shift->SUPER::execute_ok(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	$self->field_decl(
	    visible => [
		[qw(user_button OKButton)],
	    ],
	    other => [
		qw(mail_body mail_subject),
	    ], 'LongText',
	),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    foreach my $f (@{$self->internal_aux_fields}) {
	$self->internal_put_field($f => 0);
    }
    return shift->SUPER::internal_pre_execute(@_);
}

sub internal_send_mail {
    my($self) = @_;
    my($role) = $self->get('RealmUser.role')->get_name;
    foreach my $f (qw(mail_body mail_subject)) {
	my($v);
	foreach my $r ($role, 'default') {
	    last if $v = ($_T->get_from_source($self->req)
		->unsafe_get_value('UnapprovedApplicantForm', $f, $r))[0];
	}
	return
	    unless $v;
	$self->internal_put_field($f => $v);
    }
    $_V->execute('SiteAdmin->unapproved_applicant_form_mail', $self->req);
    return;
}

sub internal_select_roles {
    return ['UNAPPROVED_APPLICANT', @{shift->SUPER::internal_select_roles(@_)}];
}

1;
