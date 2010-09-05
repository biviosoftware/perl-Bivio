# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::JobLock;
use strict;
use Bivio::Agent::Task;
use Bivio::Base 'Bivio::Biz::PropertyModel';
use Sys::Hostname ();

# C<Bivio::Biz::Model::JobLock>

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub acquire_or_load {
    # (self, string, hash_ref) : boolean
    # Attempts to create a JobLock and start the background job.
    # Returns true if successfully, false if the JobLock already exists
    # for the task.
    my($self, $task_id, $job_attributes) = @_;
    $task_id = Bivio::Agent::TaskId->from_name($task_id)
        unless ref($task_id);
    Bivio::Die->die('missing realm lock')
        unless $self->new_other('Lock')->is_acquired;
    return 0 if $self->unsafe_load({
        task_id => $task_id
    });
    my($realm_id) = $self->get_request->get('auth_id');
    $self->SUPER::create({
        realm_id => $realm_id,
        task_id => $task_id,
        modified_date_time => Bivio::Type::DateTime->now,
        hostname => Sys::Hostname::hostname(),
        pid => $$,
    });
    Bivio::IO::ClassLoader->simple_require('Bivio::Agent::Job::Dispatcher');
    Bivio::Agent::Job::Dispatcher->enqueue($self->get_request,
        $task_id, {
            %$job_attributes,
            process_cleanup => [
                sub {
                    my($req, $die) = @_;
                    my($job_lock) = Bivio::Biz::Model->new($req, 'JobLock')
                        ->unauth_load_or_die({
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
            ],
        });
    return 1;
}

sub create {
    # (self, hash_ref) : self
    # Do not call this method - use acquire_or_load() instead.
    Bivio::Die->die(
        'invalid call to create() - call acquire_or_load() instead');
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
            task_id => ['Bivio::Agent::TaskId', 'PRIMARY_KEY'],
	    modified_date_time => ['DateTime', 'NOT_NULL'],
            hostname => ['Line', 'NOT_NULL'],
            pid => ['Integer', 'NOT_NULL'],
            percent_complete => ['Amount', 'NONE'],
            message => ['Text', 'NONE'],
            die_code => ['Bivio::DieCode', 'NONE'],
	},
	auth_id => 'realm_id',
    };
}

sub update {
    # (self, hash_ref) : self
    # Adds modified_date_time to values and calls super class.
    my($self, $values) = @_;
    $values->{modified_date_time} = Bivio::Type::DateTime->now;
    return shift->SUPER::update(@_);
}

sub update_and_commit {
    # (self, hash_ref) : self
    # Applies the changes and commits changes to the database.
    my($self, $values) = @_;
    $self->update($values);
    Bivio::Agent::Task->commit($self->get_request);
    return $self;
}

1;
