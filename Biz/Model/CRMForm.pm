# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMForm;
use strict;
use Bivio::Base 'Model.MailForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RFC) = b_use('Mail.RFC822');
my($_CTS) = b_use('Type.CRMThreadStatus');
my($_CT) = b_use('Model.CRMThread');
my($_BRM) = b_use('Action.BoardRealmMail');
my($_I) = b_use('Mail.Incoming');
my($_TAG_ID) = 'CRMThread.thread_root_id';
b_use('ClassWrapper.TupleTag')->wrap_methods(
    __PACKAGE__, __PACKAGE__->TUPLE_TAG_INFO);
#TODO: Locked needs to limit users from acting (are you sure?)
#TODO: Verify that auth_realm is in the list of emails????
#TODO: Bounce handling

sub TUPLE_TAG_INFO {
    return {
	moniker => $_CT->TUPLE_TAG_PREFIX,
	primary_id_field => $_TAG_ID,
    };
}

sub execute_cancel {
    my($self) = @_;
    _if_crm_thread($self, sub {_release_lock(@_)});
    return shift->SUPER::execute_cancel(@_);
}

sub execute_empty {
    my($self) = @_;
    shift->SUPER::execute_empty(@_);
    $self->internal_put_field(
	_if_crm_thread(
	    $self,
	    sub {
		my($ct, $cal) = @_;
		_acquire_lock($ct)
		    unless my $discuss = $self->internal_query_who->eq_realm;
		return (
		    action_id => _action_id_for_owner_and_status(
			$self, $ct, $cal, $discuss),
		    subject => $ct->clean_subject($self->get('subject')),
		);
	    },
	    sub {
		return (
		    to => undef,
		    cc => $self->get('to'),
		    action_id => shift->status_to_id_in_list(
			$self->internal_empty_status_when_new),
		);
	    },
	),
    );
    return;
}

sub execute_ok {
    my($self) = @_;
    my($res) = $self->unsafe_get('update_only') ? $self->internal_return_value
	: shift->SUPER::execute_ok(@_);
    my($ct) = $self->req('Model.CRMThread');
    my($cal, $cid) = $self->unsafe_get(
	qw(crm_action_list CRMThread.customer_realm_id));
    my($id) = $self->get('action_id');
    my($status) = $cal->id_to_status($id);
    $ct->update({
	crm_thread_status => $status,
	owner_user_id => $cal->id_to_owner($id),
	modified_by_user_id => $self->req('auth_user_id'),
	lock_user_id => $status->eq_locked ? $self->req('auth_user_id')
	    : undef,
	subject => $self->get('subject'),
	$cid ? (customer_realm_id => $cid) : (),
    });
    $self->internal_put_field(
	$_TAG_ID => $ct->get('thread_root_id'));
    return $res;
}

sub internal_empty_status_when_exists {
    return $_CTS->CLOSED;
}

sub internal_empty_status_when_new {
    return $_CTS->OPEN;
}

sub internal_format_from {
    my($self, @args) = @_;
    return _if_crm_thread(
	$self,
	sub {
	    return $_RFC->format_mailbox(
		$self->new_other('EmailAlias')->format_realm_as_incoming,
		$self->req(qw(auth_realm owner display_name)),
	    );
	},
	sub {$self->SUPER::internal_format_from(@args)},
    );
}

sub internal_format_subject {
    my($self, @args) = @_;
    return _if_crm_thread(
	$self,
	sub {shift->make_subject($self->get('subject'))},
	sub {$self->SUPER::internal_format_subject(@args)},
    );
}

sub internal_get_reply_incoming {
    my($self, $in) = @_;
    return shift->SUPER::internal_get_reply_incoming(@_)
	unless $in;
    my($trid) = $self->get('RealmMail.thread_root_id');
    return shift->SUPER::internal_get_reply_incoming(@_)
	if $trid eq $self->get('RealmMail.realm_file_id');
    return $_I->new(
	$self->new_other('RealmMail')->load({realm_file_id => $trid}),
    );
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	$self->field_decl(
	    visible => [
		[qw(action_id CRMActionId)],
		[qw(update_only OKButton)],
	    ],
	    other => [
		$_TAG_ID,
		[qw(crm_action_list Model.CRMActionList)],
	    ],
	),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    if (my $trid = $self->get('RealmMail.thread_root_id')) {
	$self->internal_put_field($_TAG_ID => $trid);
	$self->new_other('CRMThread')->load({thread_root_id => $trid});
    }
    $self->internal_put_field(
	crm_action_list => $self->new_other('CRMActionList')->load_all,
	board_always => 1,
    );
    return @res;
}

sub validate {
    my($self) = @_;
    if ($self->unsafe_get('update_only')) {
	return $self->internal_put_error(to => 'MUTUALLY_EXCLUSIVE')
	    unless $self->unsafe_get($_TAG_ID);
	foreach my $f (qw(to body)) {
	    $self->internal_clear_error($f);
	}
    }
    else {
	shift->SUPER::validate(@_);
    }
    return _if_crm_thread($self, sub {
        my(undef, $cal) = @_;
	$self->internal_put_error(action_id => 'SYNTAX_ERROR')
	    unless $self->get_field_error('action_id')
	    || $cal->validate_id($self->get('action_id'));
	return;
    });
}

sub _acquire_lock {
    my($ct) = @_;
    return $ct->update({
	lock_user_id => $ct->req('auth_user_id'),
	crm_thread_status => $_CTS->LOCKED,
    });
}

sub _action_id_for_owner_and_status {
    my($self, $ct, $cal, $discuss) = @_;
    return $discuss ? $self->ureq(qw(Model.CRMThread owner_user_id))
        || $cal->status_to_id_in_list($ct->get('crm_thread_status'))
            : $cal->status_to_id_in_list(
                $self->internal_empty_status_when_exists);
}

sub _if_crm_thread {
    my($self, $true, $false) = @_;
    my($cal) = $self->get('crm_action_list');
    return $false && $false->($cal)
	unless my $ct = $self->ureq('Model.CRMThread');
    return $true->($ct, $cal);
}

sub _release_lock {
    return shift->update({
	lock_user_id => undef,
	crm_thread_status => $_CTS->OPEN,
    });
}

1;
