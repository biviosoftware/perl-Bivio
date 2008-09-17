# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMThread;
use strict;
use Bivio::Base 'Model.OrdinalBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->use('Model.RealmMail')->register('Model.CRMThread');
my($_PS) = ${__PACKAGE__->use('Auth.PermissionSet')->from_array(
    ['FEATURE_CRM'],
)} if __PACKAGE__->use('Auth.Permission')->unsafe_from_name('FEATURE_CRM');
my($_EMS) = __PACKAGE__->use('Type.MailSubject')->EMPTY_VALUE;
my($_CTS) = __PACKAGE__->use('Type.CRMThreadStatus');
my($_SUBJECT_RE) = qr{\#\s*(\d+)\s*\]};
my($_REQ_ATTR) = __PACKAGE__ . '.pre_create';
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_RECENT) = 60;
my($_MS) = __PACKAGE__->use('Type.MailSubject');

sub ORD_FIELD {
    return 'crm_thread_num';
}

sub USER_ID_FIELD {
    return '';
}

sub clean_subject {
    my(undef, $subject) = @_;
    $subject =~ s{.*$_SUBJECT_RE\s*}{};
    $subject =~ s{\b(?:Re|Aw|Fwd?):|\[fwd\]}{}ig;
    $subject =~ s{^\s+|\s+$}{}g;
    $subject =~ s{\s+}{ }g;
    return length($subject) ? $subject : $_EMS;
}

sub create {
    my($self, $values) = @_;
    $values->{crm_thread_status} ||= $_CTS->NEW;
    _fixup_values($self, $values);
    return shift->SUPER::create(@_);
}

sub handle_mail_post_create {
    my($proto, $realm_mail, $in) = @_;
    my($req) = $realm_mail->req;
    return
	unless $proto->is_enabled_for_auth_realm($req);
    my($v) = {
	subject => $proto->clean_subject($realm_mail->get('subject')),
    };
    if (my $self = $proto->internal_get_existing_thread($req)) {
	my($tid) = $self->get('thread_root_id');
	$realm_mail->update({
	    thread_root_id => $tid,
	    thread_parent_id => $tid,
	}) unless $tid eq $realm_mail->get('thread_root_id');
	$self->update({
	    %$v,
	    _status_for_update_mail($self, $realm_mail),
	});
	return;
    }
    $proto->new($req)->create({
	%$v,
	thread_root_id => $realm_mail->get('thread_root_id'),
    });
    return;
}

sub handle_mail_pre_create_file {
    my($proto, $realm_mail, $rfc822) = @_;
    my($req) = $realm_mail->req;
    return
	unless $proto->is_enabled_for_auth_realm($req);
    my($self) = $proto->new($req);
    $$rfc822 =~ s{(?<=^subject:)(.*)}{_subject($self, $1)}emi;
    return;
}

sub internal_get_existing_thread {
    my(undef, $req) = @_;
    return $req->unsafe_get($_REQ_ATTR);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'crm_thread_t',
	columns => {
	    $self->REALM_ID_FIELD => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    crm_thread_num => ['CRMThreadNum', 'PRIMARY_KEY'],
            subject => ['MailSubject', 'NOT_NULL'],
            subject_lc => ['MailSubject', 'NOT_NULL'],
	    modified_date_time => ['DateTime', 'NOT_NULL'],
	    modified_by_user_id => ['User.user_id', 'NONE'],
	    thread_root_id => ['RealmMail.realm_file_id', 'NOT_NULL'],
	    crm_thread_status => ['CRMThreadStatus', 'NOT_ZERO_ENUM'],
	    owner_user_id => ['User.user_id', 'NONE'],
	    lock_user_id => ['User.user_id', 'NONE'],
	    customer_realm_id => ['RealmOwner.realm_id', 'NONE'],
        },
    });
}

sub is_enabled_for_auth_realm {
    my(undef, $req) = @_;
    return 0
	unless $_PS;
    return $req->get('auth_realm')->does_user_have_permissions($_PS, $req);
}

sub make_subject {
    my($self, $subject) = @_;
    return _prefix($self) . $self->clean_subject($subject);
}

sub update {
    my($self, $values) = @_;
    _fixup_values($self, $values);
    return shift->SUPER::update(@_);
}

sub _fixup_values {
    my($self, $values) = @_;
    $values->{subject_lc} = $self->clean_subject(
	$_MS->clean_and_trim($values->{subject}),
    ) if defined($values->{subject});
    return;
}

sub _is_realm_member {
    my($self, $realm_mail) = @_;
    return 1
	if $self->req('auth_realm')->does_user_have_permissions(
	    ['DATA_WRITE'],
	    $self->req,
	);
    my($f) = $realm_mail->get('from_email');
    return grep($f eq $_, @{$self->new_other('CRMForm')->get_realm_emails})
	? 1 : 0;
}

sub _subject {
    my($self, $value) = @_;
    my($req) = $self->req;
    $req->delete($_REQ_ATTR);
    my($num);
    if ($value =~ s{.*$_SUBJECT_RE\s*}{}) {
	$num = $1;
	if ($self->unsafe_load({crm_thread_num => $num})) {
	    $req->put($_REQ_ATTR => $self);
	}
	else {
#TODO: Fix for imports
	    $self->req->warn(
		$num, ': crm_thread_num not found, ignoring; subject=', $value);
	    $num = undef;
	}
    }
    $value =~ s/^\s+|\s+$//g;
    return ' '
	. _prefix($self, $num || $self->internal_next_ord)
	. $value;
}

sub _prefix {
    my($self, $crm_thread_num) = @_;
    return '['
	. ($self->new_other('RowTag')->get_value(
	    $self->req('auth_id'), 'CRM_SUBJECT_PREFIX',
	  ) || $self->req(qw(auth_realm owner display_name)))
	. ' #'
	. $self->get_or_default(crm_thread_num => $crm_thread_num)
	. '] ';
}

sub _status_for_update_mail {
    my($self, $realm_mail) = @_;
#TODO: THis is a hack.  Need to understand closed from header
    return $self->get('crm_thread_status')->eq_closed
	&& !_is_realm_member($self, $realm_mail)
        ? (crm_thread_status => $_CTS->OPEN)
	: ();
}

1;
