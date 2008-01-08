# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Lock;
use strict;
use Bivio::Base 'Biz.PropertyModel';
use Bivio::IO::Trace;

# C<Bivio::Biz::Model::Lock> process lock. Locks are intended to control
# access to a realm resource across processes. This implementation is simple -
# only one lock can exists for a realm. The same
# process can't acquire the same lock twice.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);

sub acquire {
    # (self) : undef
    # Attempts to acquire a lock for the specified task for the current realm.
    # Throws an UPDATE_COLLISION exception if it cannot acquire the lock.
    #
    # You probably shouldn't be calling this method.  Locks should be acquired as a
    # task item.  Put this instance on the Task:
    #
    #     Bivio::Biz::Model::Lock
    my($self) = @_;
    my($req) = $self->get_request;
    if (my $other = $req->unsafe_get(ref($self))) {
	$other->throw_die(ALREADY_EXISTS => {
	    message => 'more than one lock on the request',
	});
	# DOES NOT RETURN
    }
    my($values) = {realm_id => $req->get('auth_id')};
    _read_request_input($req);
    my($die) = Bivio::Die->catch(sub {$self->create($values)});
    if ($die) {
	# someone already has it or are we trying to acquire it again?
	if ($die->get('code')->equals_by_name('DB_CONSTRAINT')) {
	    my($a) = $die->unsafe_get('attrs');
	    $self->throw_die('UPDATE_COLLISION', $values)
		if ref($a) && ref($a->{type_error})
		    && $a->{type_error}->equals_by_name('EXISTS');
	}
	# something else bad happened
	$die->throw_die();
	# DOES NOT RETURN
    }
    _trace($self) if $_TRACE;
    $req->push_txn_resource($self);
    return;
}

sub acquire_general {
    # (self) : undef
    # Acquires lock on the GENERAL realm, used for locking access on entire
    # database so use sparingly.
    my($self) = @_;
    my($req) = $self->get_request;
    my($old_realm) = $req->get('auth_realm');
    $req->set_realm(Bivio::Auth::Realm->get_general);
    $self->acquire;
    $req->set_realm($old_realm);
    return;
}

sub acquire_unless_exists {
    # (self) : undef
    # Acquires the lock on I<req.auth_realm> if not already acquired on I<req>.
    my($self) = @_;
    $self->acquire
	unless $self->is_acquired;
    return;
}

sub execute {
    # (proto, Agent.Request) : undef
    # Acquires a lock on this realm.
    my($proto, $req) = @_;
    $proto->new($req)->acquire;
    return;
}

sub execute_general {
    # (proto, Agent.Request) : undef
    # Calls I<acquire_general>.
    my($proto, $req) = @_;
    $proto->new($req)->acquire_general;
    return;
}

sub execute_unless_acquired {
    # (proto, Agent.Request) : undef
    # Calls I<acquire_unless_exists>.
    my($proto, $req) = @_;
    $proto->new($req)->acquire_unless_exists;
    return;
}

sub handle_commit {
    # (self) : undef
    # Commit called, delete lock from request before DB commit
    my($self) = @_;
    $self->release();
    return;
}

sub handle_rollback {
    # (self) : undef
    # Rollback called, delete lock from request.  Won't be committed
    # so don't need to delete the row.
    my($self) = @_;
    $self->delete_from_request;
    return;
}

sub internal_initialize {
    # (self) : hash_ref
    # B<FOR INTERNAL USE ONLY>
    return {
	version => 1,
	table_name => 'lock_t',
	columns => {
	    # We don't link here, because the lock shouldn't be deleted
	    # if 
            realm_id => ['PrimaryId', 'PRIMARY_KEY'],
	},
	auth_id => 'realm_id',
    };
}

sub is_acquired {
    # (self) : boolean
    # (self, any) : boolean
    # Returns true if I<realm_or_id> (default: req.auth_realm) is already acquired.
    my($self) = shift;
    my($req) = $self->get_request;
    return 0 unless my $other = $req->unsafe_get(ref($self));
    return $other->get('realm_id') eq $req->get('auth_realm')->id_from_any(@_)
	? 1 : 0;
}

sub is_general_acquired {
    # (self) : boolean
    # Returns true if general lock is acquired.
    my($self) = @_;
    return $self->is_acquired(Bivio::Auth::Realm->get_general);
}

sub release {
    # (self) : undef
    # Releases this lock.  If lock isn't deleted, throw UPDATE_COLLISION.
    # I<self> must be on the request.  It will be deleted from the request.
    #
    # You probably shouldn't be calling this method.  Locks are released by
    # L<Bivio::Agent::Task|Bivio::Agent::Task>.
    my($self) = @_;


    # NOTE: Bivio::Agent::Task::rollback knows that this method behaves this
    # way.  Keep in synch.

    # Ensure that we are delete the lock on the request first before errors
    my($req) = $self->get_request;
    my($req_lock) = $req->unsafe_get(ref($self));
    $self->throw_die('DIE', 'no locks on request') unless $req_lock;
    $self->throw_die('DIE', {message => 'too many locks on the same request',
	request_lock => $req_lock}) unless $req_lock == $self;
    _trace($self) if $_TRACE;
    $self->delete_from_request;

    # If it can't release the lock and database is writable, blow up.
    $self->throw_die('UPDATE_COLLISION')
	    unless $self->delete() || Bivio::SQL::Connection->is_read_only;
    return;
}

sub _read_request_input {
    my($req) = @_;
    my($r) = $req->unsafe_get('r');
    return unless $r;
    my($m) = lc($r->method) eq 'post' ? 'get_form' : 'get_content';
    $req->$m();
    return;
}

1;
