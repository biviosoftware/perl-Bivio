# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMForm;
use strict;
use Bivio::Base 'Model.MailForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RFC) = __PACKAGE__->use('Mail.RFC822');
my($_CLOSED) = __PACKAGE__->use('Type.CRMThreadStatus')->CLOSED;
my($_TTF) = __PACKAGE__->use('Model.TupleTagForm');
my($_IDI) = __PACKAGE__->instance_data_index;
my($_TAG_ID) = 'crmthread.CRMThread.thread_root_id';

#TODO: Locked needs to limit users from acting (are you sure?)
#TODO: Verify that auth_realm is in the list of emails????
#TODO: Bounce handling
sub TUPLE_TAG_IDS {
    return [$_TAG_ID];
}

sub execute_cancel {
    my($self) = @_;
    _with($self, sub {
	my($ct) = @_;
	$ct->release_lock;
	return;
    });
    return shift->SUPER::execute_cancel(@_);
}

sub execute_empty {
    my($self) = @_;
    shift->SUPER::execute_empty(@_);
    _with($self, sub {
        my($ct, $cal) = @_;
	my($discuss) = $self->internal_query_who->eq_realm;
	$ct->acquire_lock
	    unless $discuss;
	$self->internal_put_field(
	    subject => $ct->clean_subject($self->get('subject')));
	$self->internal_put_field(
	    action_id => $cal->status_to_id(
		$discuss ? $ct->get('crm_thread_status') : $_CLOSED,
	    ));
	return;
    });
    $self->delegate_method($_TTF, @_);
    return;
}

sub execute_ok {
    my($self) = @_;
    _with($self, sub {
	my($ct, $cal) = @_;
	$ct->update({
	    crm_thread_status => $cal->id_to_status($self->get('action_id')),
	    owner_user_id => $cal->id_to_owner($self->get('action_id')),
	    modified_by_user_id => $self->req('auth_user_id'),
	});
	$self->internal_put_field(
	    subject => $ct->make_subject($self->get('subject')),
	);
	return;
    });
    my($res) = shift->SUPER::execute_ok(@_);
    $self->internal_put_field(
	$_TAG_ID => $self->req('Model.CRMThread')->get('thread_root_id'));
    $self->delegate_method($_TTF, @_);
    return $res;
}

sub get_field_info {
    return shift->delegate_method($_TTF, @_);
}

sub internal_format_from {
    my($self) = @_;
    return $_RFC->format_mailbox(
	$self->get('realm_emails')->[0],
	$self->req(qw(auth_user display_name)),
    );
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
	    ],
	    other => $self->TUPLE_TAG_IDS,
	}),
    );
}

sub internal_pre_execute {
    my($self) = shift;
    $self->SUPER::internal_pre_execute(@_);
    if (my $m = $self->req->unsafe_get('Model.RealmMail')) {
	my($trid) = $m->get('thread_root_id');
	$self->new_other('CRMThread')->load({thread_root_id => $trid});
	$self->internal_put_field($_TAG_ID => $trid);
	$self->new_other('CRMActionList')->load_all;
    }
    $self->delegate_method($_TTF, @_);
    return;
}

sub show_action {
    my($self) = @_;
    return _with($self, sub {1}) || 0;
}

sub tuple_tag_form_state {
    return shift->[$_IDI] ||= {};
}

sub validate {
    my($self) = @_;
    shift->SUPER::validate(@_);
    _with($self, sub {
        my(undef, $cal) = @_;
	$self->internal_put_error(action_id => 'SYNTAX_ERROR')
	    unless $self->get_field_error('action_id')
	    || $cal->validate_id($self->get('action_id'));
	return;
    });
    return;
}

sub _with {
    my($self, $op) = @_;
    return unless my $ct = $self->req->unsafe_get('Model.CRMThread');
    return $op->($ct, $self->req('Model.CRMActionList'));
}

1;
