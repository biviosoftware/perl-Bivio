# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RemoteFileCopyListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FPA) = b_use('Type.FilePathArray');
my($_RFC) = b_use('Action.RemoteFileCopy');
my($_A) = b_use('Action.Acknowledgement');

sub execute_empty_row {
    my($self) = @_;
    $self->internal_put_field(want_realm => 1)
	unless defined($self->unsafe_get('want_realm'));
    return
	unless $self->get('want_realm');
    $self->validate_row;
    return;
}

sub execute_ok_end {
    my($self) = @_;
    if ($self->unsafe_get('prepare')) {
	unless ($self->get('need_update')) {
	    $_A->save_label(
		REMOTE_FILE_COPY_FORM_no_update => $self->req, my $q = {});
	    return {
		task => 'next',
		query => $q,
	    };
	}
	$self->internal_put_field(prepare_ok => 1);
	$self->internal_stay_on_page;
    }
    return;
}

sub execute_ok_row {
    my($self) = @_;
    return
	unless $self->get('want_realm');
    return _prepare($self)
	if $self->unsafe_get('prepare');
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'RemoteFileCopyList',
	$self->field_decl(
	    visible => [
		[qw(want_realm Boolean)],
		{name => 'prepare', type => 'OKButton', in_list => 0},
	    ],
	    hidden => [
		qw(to_delete to_create to_update),
		{name => 'prepare_ok', type => 'Boolean', in_list => 0},
	    ],
	    other => [
		{name => 'need_update', type => 'Boolean', in_list => 0},
	    ],
	    {type => 'FilePathArray', in_list => 1},
	),
    });
}

sub internal_initialize_list {
    my($self) = @_;
    $self->new_other('RemoteFileCopyList')->load_all;
    return shift->SUPER::internal_initialize_list(@_);
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field(need_update => 0);
    return shift->SUPER::internal_pre_execute(@_);
}

sub validate_row {
    my($self) = @_;
    my($lm) = $self->get_list_model;
    my($ro) = $self->new_other('RealmOwner');
    return $self->internal_put_error(want_realm => 'NOT_FOUND')
	unless $ro->unauth_load({name => $lm->get('realm')});
    return $self->internal_put_error(want_realm => 'PERMISSION_DENIED')
	unless $self->req->can_user_execute_task($self->req('task_id') => $ro);
    return $self->internal_put_error(want_realm => 'EMPTY')
	unless $lm->get('folder')->is_specified;
    return;
}

sub _prepare {
    my($self) = @_;
    my($lm) = $self->get_list_model;
    my($res, $err) = $self->req->with_realm(
	$lm->get('realm'),
	sub {$_RFC->diff_lists($lm)},
    );
    return $self->internal_put_error_and_detail(
	qw(want_realm SYNTAX_ERROR), $err,
    ) if $err;
    while (my($k, $v) = each(%$res)) {
	$self->internal_put_field(need_update => 1)
	    if $v->is_specified;
	$self->internal_put_field($k => $v);
    }
    return;
}

1;
