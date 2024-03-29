# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMThread;
use strict;
use Bivio::Base 'Model.OrdinalBase';

my($_PS) = ${b_use('Auth.PermissionSet')->from_array(
    ['FEATURE_CRM'],
)} if b_use('Auth.Permission')->unsafe_from_name('FEATURE_CRM');
my($_EMS) = b_use('Type.MailSubject')->EMPTY_VALUE;
my($_CTS) = b_use('Type.CRMThreadStatus');
my($_SUBJECT_RE) = qr{\#\s*(\d+)\s*\]};
my($_REQ_ATTR) = __PACKAGE__ . '.pre_create';
my($_DT) = b_use('Type.DateTime');
my($_MS) = b_use('Type.MailSubject');
my($_I) = b_use('Mail.Incoming');
my($_RECENT) = 60;
b_use('Model.RealmMail')->register('Model.CRMThread');
#TODO: Share with CRMForm & CRMThreadRootList
b_use('ClassWrapper.TupleTag')->wrap_methods(__PACKAGE__,  {
    moniker => __PACKAGE__->TUPLE_TAG_PREFIX,
    primary_id_field => 'thread_root_id',
});

sub ORD_FIELD {
    return 'crm_thread_num';
}

sub TUPLE_TAG_PREFIX {
    return 'b_ticket';
}

sub USER_ID_FIELD {
    return '';
}

sub cascade_delete {
    my($self, $query) = @_;
    $self->new->do_iterate(
        sub {
            my($it) = @_;
            $self->new_other('TupleTag')
                ->delete_all({primary_id => $it->get('thread_root_id')});
            return 1;
        },
        $query || {thread_root_id => $self->get('thread_root_id')},
    );
    return shift->SUPER::cascade_delete(@_);
}

sub clean_subject {
    my(undef, $subject) = @_;
    $subject =~ s{.*$_SUBJECT_RE\s*}{};
    $subject =~ s{\b(?:Re|Aw|Fwd?)(?:\:|\b)|\[fwd\]}{}ig;
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
    my($proto, $realm_mail, $in, $file) = @_;
    my($req) = $realm_mail->req;
    return
        unless $proto->is_enabled_for_auth_realm($req);
    my($v) = {
        subject => $proto->clean_subject($realm_mail->get('subject')),
        _user_id_for_mail($realm_mail),
    };
    my($self, $tid);
    if ($self = $req->unsafe_get($_REQ_ATTR)) {
        $tid = $self->get('thread_root_id');
        $realm_mail->update({
            thread_root_id => $tid,
            thread_parent_id => $tid,
        }) unless $tid eq $realm_mail->get('thread_root_id');
        $self->update({
            %$v,
            _status_for_update_mail($self, $realm_mail),
        });
#TODO: Create tuple tag?
        return;
    }
    # Just in case RealmMail bound to an old message, but the user wants a new
    # request.
    $realm_mail->update({
        thread_root_id => $realm_mail->get('realm_file_id'),
        thread_parent_id => undef,
    });
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
    $$rfc822 =~ s{(?<=^subject:)(.*)}{_create_subject($self, $1, $rfc822)}emi;
    return;
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

sub _create_subject {
    my($self, $value, $rfc822) = @_;
    my($req) = $self->req;
    $req->delete($_REQ_ATTR);
    my($num);
    if ($value =~ s{.*$_SUBJECT_RE\s*}{}) {
        $num = $1;
        unless ($self->unsafe_load({crm_thread_num => $num})) {
            $self->req->warn(
                $num, ': crm_thread_num not found, ignoring; subject=', $value);
            $num = undef;
        }
    }
    elsif (my $l = $self->new_other('RealmMailReferenceList')
        ->load_first_from_incoming($_I->new($rfc822))
    ) {
        if (_strip_subject($self, $l->get('RealmMail.subject_lc'))
            eq _strip_subject($self, $value)
            && $self->unsafe_load({
                thread_root_id => $l->get('RealmMail.thread_root_id')})
        ) {
            $num = $self->get('crm_thread_num');
        }
    }
    $req->put($_REQ_ATTR => $self)
        if $self->is_loaded;
    $value =~ s/^\s+|\s+$//g;
    return ' '
        . _prefix($self, $num || $self->internal_next_ord)
        . $value;
}

sub _fixup_values {
    my($self, $values) = @_;
    $values->{subject_lc} = _strip_subject($self, $values->{subject})
        if defined($values->{subject});
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

sub _strip_subject {
    return $_MS->clean_and_trim(shift->clean_subject(shift));
}

sub _user_id_for_mail {
    my($realm_mail) = @_;
    my($user_id) = $realm_mail->new_other('Email')
        ->unsafe_user_id_from_email($realm_mail->get('from_email'));
    return $user_id
        ? (modified_by_user_id => $user_id)
        : ();
}

1;
