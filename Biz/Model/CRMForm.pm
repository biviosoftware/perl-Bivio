# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMForm;
use strict;
use Bivio::Base 'Model.MailForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RFC) = b_use('Mail.RFC822');
my($_CTS) = __PACKAGE__->use('Type.CRMThreadStatus');
my($_TTF) = b_use('Model.TupleTagForm');
my($_IDI) = __PACKAGE__->instance_data_index;
my($_TAG_ID) = 'b_ticket.CRMThread.thread_root_id';

#TODO: Locked needs to limit users from acting (are you sure?)
#TODO: Verify that auth_realm is in the list of emails????
#TODO: Bounce handling
sub TUPLE_TAG_IDS {
    return [$_TAG_ID];
}

sub execute_cancel {
    my($self) = @_;
    _with($self, sub {_release_lock(@_)});
    return shift->SUPER::execute_cancel(@_);
}

sub execute_empty {
    my($self) = @_;
    shift->SUPER::execute_empty(@_);
    _with($self, sub {
        my($ct, $cal) = @_;
	my($discuss) = $self->internal_query_who->eq_realm;
	_acquire_lock($ct)
	    unless $discuss;
	$self->internal_put_field(
	    subject => $ct->clean_subject($self->get('subject')),
	    action_id => $cal->status_to_id_in_list(
		$discuss ? $ct->get('crm_thread_status')
                    : $self->internal_empty_status_when_exists,
	    ));
	return;
    }, sub {
	$self->internal_put_field(action_id =>
            shift->status_to_id_in_list($self->internal_empty_status_when_new));
    });
    $self->delegate_method($_TTF, @_);
    return;
}

sub execute_ok {
    my($self) = @_;
    my($res) = $self->unsafe_get('update_only') ? $self->internal_return_value
	: shift->SUPER::execute_ok(@_);
    my($ct) = $self->req('Model.CRMThread');
    my($cal) = $self->req('Model.CRMActionList');
    my($id) = $self->get('action_id');
    my($status) = $cal->id_to_status($id);
    my($cid) = $self->unsafe_get('CRMThread.customer_realm_id');
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
    $self->delegate_method($_TTF, @_);
    return $res;
}

sub get_field_info {
    return shift->delegate_method($_TTF, @_);
}

sub internal_empty_status_when_exists {
    return $_CTS->CLOSED;
}

sub internal_empty_status_when_new {
    return $_CTS->OPEN;
}

sub internal_format_from {
    my($self, @args) = @_;
    return _with(
	$self,
	sub {
	    return $_RFC->format_mailbox(
		$self->new_other('EmailAlias')->format_realm_as_incoming,
		$self->req(qw(auth_realm owner display_name)),
	    );
	},
	sub {
	    return $self->SUPER::internal_format_from(@args);
	},
    );
}

sub internal_format_subject {
    my($self) = @_;
    return shift->SUPER::internal_format_subject(@_)
	unless my $ct = $self->req->unsafe_get('Model.CRMThread');
    return $ct->make_subject($self->get('subject'));
}

sub internal_initialize {
    my($self) = @_;
    return $self->delegate_method(
	$_TTF,
	$self->merge_initialize_info($self->SUPER::internal_initialize, {
	    version => 1,
	    visible => [
		{
		    name => 'action_id',
		    type => 'CRMActionId',
		    constraint => 'NONE',
		},
		{
		    name => 'update_only',
		    type => 'OKButton',
		    constraint => 'NONE',
		},
	    ],
	    other => $self->TUPLE_TAG_IDS,
	}),
    );
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = return shift->SUPER::internal_pre_execute(@_);
    if (my $trid = $self->get('RealmMail.thread_root_id')) {
	$self->new_other('CRMThread')->load({thread_root_id => $trid});
	$self->internal_put_field($_TAG_ID => $trid);
    }
    $self->new_other('CRMActionList')->load_all;
    return @res;
}

sub tuple_tag_form_state {
    return shift->[$_IDI] ||= {};
}

sub tuple_tag_map_slots {
    return shift->delegate_method($_TTF, @_);
}

sub tuple_tag_slot_choice_select_list {
    return shift->delegate_method($_TTF, @_);
}

sub tuple_tag_slot_has_choices {
    return shift->delegate_method($_TTF, @_);
}

sub tuple_tag_slot_label {
    return shift->delegate_method($_TTF, @_);
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
    _with($self, sub {
        my(undef, $cal) = @_;
	$self->internal_put_error(action_id => 'SYNTAX_ERROR')
	    unless $self->get_field_error('action_id')
	    || $cal->validate_id($self->get('action_id'));
	return;
    });
    return;
}

sub _acquire_lock {
    my($ct) = @_;
    return $ct->update({
	lock_user_id => $ct->req('auth_user_id'),
	crm_thread_status => $_CTS->LOCKED,
    });
}

sub _release_lock {
    return shift->update({
	lock_user_id => undef,
	crm_thread_status => $_CTS->OPEN,
    });
}

sub _with {
    my($self, $true, $false) = @_;
    my($cal) = $self->req('Model.CRMActionList');
    return $false && $false->($cal)
	unless my $ct = $self->req->unsafe_get('Model.CRMThread');
    return $true->($ct, $cal);
}

1;
