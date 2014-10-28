# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$p
package Bivio::Biz::Model::AuthUserRealmList;
use strict;
use Bivio::Base 'Model.UserRealmList';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_TI) = b_use('Agent.TaskId');
my($_T) = b_use('Agent.Task');
my($_R) = b_use('Auth.Realm');
b_die('v6: no longer supported')
    unless b_use('IO.Config')->if_version(7);

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
	sub {
	    return ($res = shift->can_user_execute_task_in_this_realm($task))
		? 0
		: 1;
	},
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

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 0,
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
    my($fields) = $self->[$_IDI] || b_die('must call load_all_for_task');
    return $fields->{is_defined_for_facade}
	&& $_R->new($self->new_other('RealmOwner')->load_from_properties($row))
	->can_user_execute_task($fields->{task}, $self->req);
}


sub load_all_for_task {
    my($self, $task_id) = @_;
    $task_id = $_TI->from_any($task_id || $self->req('task_id'));
    $self->[$_IDI] = _init($self, $task_id);
    return $self->req->with_realm(
	$self->req('auth_user'),
	sub {
	    return $self->load_all({
		task_id => $task_id,
	    });
	},
    );
}

sub realm_ids {
    return _load(@_)->map_rows(sub {shift->get('RealmUser.realm_id')});
}

sub _init {
    my($self, $task_id) = @_;
    my($t) = $_T->get_by_id($task_id);
    return {
	task => $t,
	is_defined_for_facade => b_use('FacadeComponent.Task')
	    ->is_defined_for_facade($task_id->get_name, $self->req),
    };
}

sub _load {
    my($self, $task_id) = @_;
    return $self
	unless $task_id;
    return $self->load_all_for_task($task_id);
}

1;
