# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::JobLock;
use strict;
use Bivio::Base 'Biz.PropertyModel';


sub acquire_or_load {
    # (self, string, hash_ref) : boolean
    # Attempts to create a JobLock and start the background job.
    # Returns true if successfully, false if the JobLock already exists
    # for the task.
    my($self, $task_id, $job_attributes) = @_;
    $task_id = b_use('Agent.TaskId')->from_name($task_id)
        unless ref($task_id);
    b_die('missing realm lock')
        unless $self->new_other('Lock')->is_acquired;
    return 0 if $self->unsafe_load({
        task_id => $task_id
    });
    my($realm_id) = $self->get_request->get('auth_id');
    $self->SUPER::create({
        realm_id => $realm_id,
        task_id => $task_id,
        modified_date_time => b_use('Type.DateTime')->now,
        hostname => b_use('Bivio.BConf')->bconf_host_name,
        pid => $$,
    });
    b_use('AgentJob.Dispatcher')->enqueue(
        $self->req,
        $task_id,
        {
            %$job_attributes,
            process_cleanup => sub {
                my(undef, $req, $die) = @_;
                my($job_lock) = $self->new->unauth_load_or_die({
                    realm_id => $realm_id,
                    task_id => $task_id,
                });
                if ($die) {
                    $job_lock->update({
                        die_code => $die->get('code'),
                    });
                }
                else {
                    $job_lock->delete;
                }
                return;
            },
        },
    );
    return 1;
}

sub create {
    b_die('invalid call to create() - call acquire_or_load() instead');
    # DOES NOT RETURN
}

sub execute_load {
    # (proto, Agent.Request) : undef
    # Loads the JobLock for the current task.
    my($proto, $req) = @_;
    $proto->new($req)->load({
        task_id => $req->get('task_id'),
    });
    return 0;
}

sub internal_initialize {
    # (self) : hash_ref
    # B<FOR INTERNAL USE ONLY>
    return {
        version => 1,
        table_name => 'job_lock_t',
        columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            task_id => [b_use('Agent.TaskId'), 'PRIMARY_KEY'],
            modified_date_time => ['DateTime', 'NOT_NULL'],
            hostname => ['Line', 'NOT_NULL'],
            pid => ['Integer', 'NOT_NULL'],
            percent_complete => ['Amount', 'NONE'],
            message => ['Text64K', 'NONE'],
            die_code => [b_use('Bivio.DieCode'), 'NONE'],
        },
        auth_id => 'realm_id',
    };
}

sub update {
    # (self, hash_ref) : self
    # Adds modified_date_time to values and calls super class.
    my($self, $values) = @_;
    $values->{modified_date_time} = b_use('Type.DateTime')->now;
    return shift->SUPER::update(@_);
}

sub update_and_commit {
    # (self, hash_ref) : self
    # Applies the changes and commits changes to the database.
    my($self, $values) = @_;
    $self->update($values);
    b_use('Agent.Task')->commit($self->get_request);
    return $self;
}

1;
