# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Lock;
use strict;
$Bivio::Biz::Model::Lock::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::Lock - mutual exclusion for an area of a realm

=head1 SYNOPSIS

    Bivio::Biz::Model::Lock->execute_accounting_import;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::Lock::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::Lock> process lock. Locks are intended to control
access to a realm resource across processes. This implementation is simple -
only one lock can exists for a realm. The same
process can't acquire the same lock twice.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Bivio::TypeError;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="acquire"></a>

=head2 acquire()

Attempts to acquire a lock for the specified task for the current realm.
Throws an UPDATE_COLLISION exception if it cannot acquire the lock.

You probably shouldn't be calling this method.  Locks should be acquired as a
task item.  Put this instance on the Task:

    Bivio::Biz::Model::Lock

=cut

sub acquire {
    my($self) = @_;
    my($values) = {
	realm_id => $self->get_request->get('auth_id'),
    };

    # try to get the lock
    my($die) = Bivio::Die->catch(sub {$self->create($values)});
    return unless $die;

    # someone already has it or are we trying to acquire it again?
    $self->throw_die('UPDATE_COLLISION', $values)
	    if $die->get('code') == Bivio::TypeError::EXISTS();

    # something else bad happened
    $die->throw_die();
}

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req)

Acquires a lock on this realm.

=cut

sub execute {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    $req->get(ref($self))->die('EXISTS', 'more than one lock on the request')
	    if $req->unsafe_get(ref($self));
    $self->acquire();
    $req->push_txn_resource($self);
    return;
}

=for html <a name="handle_commit"></a>

=head2 handle_commit()

Commit called, delete lock from request before DB commit

=cut

sub handle_commit {
    my($self) = @_;
    $self->release();
    return;
}

=for html <a name="handle_rollback"></a>

=head2 handle_rollback()

Rollback called, delete lock from request.  Won't be committed
so don't need to delete the row.

=cut

sub handle_rollback {
    my($self) = @_;
    # Delete this lock from the request
    $self->get_request->delete(ref($self));
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'lock_t',
	columns => {
            realm_id => ['PrimaryId', 'PRIMARY_KEY'],
	},
	auth_id => 'realm_id',
    };
}

=for html <a name="release"></a>

=head2 release()

Releases this lock.  If lock isn't deleted, throw UPDATE_COLLISION.
I<self> must be on the request.  It will be deleted from the request.

You probably shouldn't be calling this method.  Locks are released by
L<Bivio::Agent::Task|Bivio::Agent::Task>.

=cut

sub release {
    my($self) = @_;

    # NOTE: Bivio::Agent::Task::rollback knows that this method behaves this
    # way.  Keep in synch.

    # Ensure that we are delete the lock on the request first before errors
    my($req) = $self->get_request;
    my($req_lock) = $req->unsafe_get(ref($self));
    $self->throw_die('DIE', 'no locks on request') unless $req_lock;
    $self->throw_die('DIE', {message => 'too many locks on the same request',
	request_lock => $req_lock}) unless $req_lock == $self;
    $req->delete(ref($self));

    # If it can't release the lock, blow up.
    $self->throw_die('UPDATE_COLLISION')
	    unless $self->delete();

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
