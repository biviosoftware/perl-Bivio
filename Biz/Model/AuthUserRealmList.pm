# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$p
package Bivio::Biz::Model::AuthUserRealmList;
use strict;
use Bivio::Base 'Model.UserRealmList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_TI) = b_use('Agent.TaskId');
my($_T) = b_use('Agent.Task');

sub assert_realm_exists {
    my($self, $realm_id, $task_id) = @_;
    $self->throw_die(FORBIDDEN => {
	entity => $realm_id,
	message => 'unauthorized realm for task',
	task_id => $self->get_query->get('task_id'),
	auth_user => $self->req('auth_user'),
    }) unless shift->realm_exists(@_);
    return;
}

sub can_user_execute_task_in_any_realm {
    my($self, $task) = @_;
    my($res) = 0;
    $self->do_rows(
	sub {!($res = shift->can_user_execute_task_in_this_realm($task))},
    );
    $self->reset_cursor;
    return $res;
}

sub can_user_execute_task_in_this_realm {
    my($self, $task_id) = @_;
    $self->assert_has_cursor;
    return $self->req->can_user_execute_task(
	$_TI->from_any($task_id), $self->get_model('RealmOwner'));
}

sub realm_exists {
    sub REALM_EXISTS {[[qw(realm_id PrimaryId)], [qw(?task_id Agent.TaskId)]]}
    my($self, $bp) = shift->parameters(\@_);
    my($ok) = _load($self, $bp->{task_id})
	->find_row_by('RealmUser.realm_id' => $bp->{realm_id});
    $self->reset_cursor;
    return $ok ? 1 : 0;
}

sub internal_clear_model_cache {
    my($self) = @_;
    $self->[$_IDI] = undef;
    return shift->SUPER::internal_clear_model_cache(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	other_query_keys => ['task_id'],
	other => [
	    # Add all fields so get_model does not hit db
	    grep(
		!/\.realm_id$/,
		$self->get_instance('RealmOwner')->get_qualified_field_name_list,
	    ),
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    my($task) = $self->[$_IDI]
	||= $_T->get_by_id($self->get_query->get('task_id'));
    return $task->has_realm_type($row->{'RealmOwner.realm_type'})
	&& $self->req->can_user_execute_task(
	    $task,
	    $self->new_other('RealmOwner')->load_from_properties($row),
    );
}


sub load_all_for_task {
    my($self, $task_id) = @_;
    return $self->req->with_realm(
	$self->req('auth_user'),
	sub {
	    return $self->load_all({
		task_id => $_TI->from_any($task_id || $self->req('task_id')),
	    });
	},
    );
}

sub realm_ids {
    return _load(@_)->map_rows(sub {shift->get('RealmUser.realm_id')});
}

sub _load {
    my($self, $task_id) = @_;
    return $self
	unless $task_id;
    return $self->load_all_for_task($task_id);
}

1;
