# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Lock;
use strict;
$Bivio::Biz::Model::Lock::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::Lock::VERSION;

=head1 NAME

Bivio::Biz::Model::Lock - mutual exclusion for an area of a realm

=head1 RELEASE SCOPE

bOP

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
use Bivio::IO::Trace;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::SQL::Connection;
use Bivio::TypeError;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

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
    my($req) = $self->get_request;
    $req->get(ref($self))->throw_die(
	'EXISTS', {
	    message => 'more than one lock on the request',
	}) if $req->unsafe_get(ref($self));
    my($values) = {realm_id => $req->get('auth_id')};
    _read_request_input($req);
    # try to get the lock
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

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req)

Acquires a lock on this realm.

=cut

sub execute {
    my($proto, $req) = @_;
    $proto->new($req)->acquire;
    return;
}

=for html <a name="execute_general"></a>

=head2 static execute_general(Bivio::Agent::Request req)

Acquires lock on the GENERAL realm, used for locking access on entire
database so use sparingly.

=cut

sub execute_general {
    my($proto, $req) = @_;
    my($old_realm) = $req->get('auth_realm');
    $req->set_realm(Bivio::Auth::Realm->get_general);
    $proto->new($req)->acquire;
    $req->set_realm($old_realm);
    return;
}

=for html <a name="execute_unless_acquired"></a>

=head2 static execute_unless_acquired(Bivio::Agent::Request req)

Executes the lock on I<req.auth_realm> if not already acquired on I<req>.

=cut

sub execute_unless_acquired {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    $self->acquire unless $self->is_acquired;
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
    $self->delete_from_request;
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
	    # We don't link here, because the lock shouldn't be deleted
	    # if 
            realm_id => ['PrimaryId', 'PRIMARY_KEY'],
	},
	auth_id => 'realm_id',
    };
}

=for html <a name="is_acquired"></a>

=head2 is_acquired() : boolean

=head2 is_acquired(any realm_or_id) : boolean

Returns true if I<realm_or_id> (default: req.auth_realm) is already acquired.

=cut

sub is_acquired {
    my($self) = shift;
    my($req) = $self->get_request;
    return 0 unless my $other = $req->unsafe_get(ref($self));
    return $other->get('realm_id') eq $req->get('auth_realm')->id_from_any(@_)
	? 1 : 0;
}

=for html <a name="is_general_acquired"></a>

=head2 is_general_acquired() : boolean

Returns true if general lock is acquired.

=cut

sub is_general_acquired {
    my($self) = @_;
    return $self->is_acquired(Bivio::Auth::Realm->get_general);
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
    _trace($self) if $_TRACE;
    $self->delete_from_request;

    # If it can't release the lock and database is writable, blow up.
    $self->throw_die('UPDATE_COLLISION')
	    unless $self->delete() || Bivio::SQL::Connection->is_read_only;
    return;
}

#=PRIVATE METHODS

sub _read_request_input {
    my($req) = @_;
    my($r) = $req->unsafe_get('r');
    return unless $r;
    my($m) = lc($r->method) eq 'post' ? 'get_form' : 'get_content';
    $req->$m();
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
