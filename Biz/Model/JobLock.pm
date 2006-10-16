# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::JobLock;
use strict;
$Bivio::Biz::Model::JobLock::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::JobLock::VERSION;

=head1 NAME

Bivio::Biz::Model::JobLock - lock for background jobs

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::JobLock;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::JobLock::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::JobLock>

=cut

#=IMPORTS
use Bivio::Agent::Task;
use Sys::Hostname ();

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="acquire_or_load"></a>

=head2 acquire_or_load(string task_id, hash_ref job_attributes) : boolean

Attempts to create a JobLock and start the background job.
Returns true if successfully, false if the JobLock already exists
for the task.

=cut

sub acquire_or_load {
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

=for html <a name="create"></a>

=head2 create(hash_ref values) : self

Do not call this method - use acquire_or_load() instead.

=cut

sub create {
    Bivio::Die->die(
        'invalid call to create() - call acquire_or_load() instead');
}

=for html <a name="execute_load"></a>

=head2 static execute_load(Bivio::Agent::Request req)

Loads the JobLock for the current task.

=cut

sub execute_load {
    my($proto, $req) = @_;
    $proto->new($req)->load({
        task_id => $req->get('task_id'),
    });
    return 0;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
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

=for html <a name="update"></a>

=head2 update(hash_ref values) : self

Adds modified_date_time to values and calls super class.

=cut

sub update {
    my($self, $values) = @_;
    $values->{modified_date_time} = Bivio::Type::DateTime->now;
    return shift->SUPER::update(@_);
}

=for html <a name="update_and_commit"></a>

=head2 update_and_commit(hash_ref values) : self

Applies the changes and commits changes to the database.

=cut

sub update_and_commit {
    my($self, $values) = @_;
    $self->update($values);
    Bivio::Agent::Task->commit($self->get_request);
    return $self;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
