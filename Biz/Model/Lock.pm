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
only one lock can exists for a (type, realm_id) pair. The same
process can't acquire the same lock twice (it is not a spin lock).

There is no reply, so any task that tries to write a reply will
fail with unknown attribute.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Alert;
use Bivio::SQL::Constraint;
use Bivio::Type::Boolean;
use Bivio::Type::DateTime;
use Bivio::Type::Integer;
use Bivio::Type::Line;
use Bivio::Type::Lock;
use Bivio::Type::PrimaryId;
use Bivio::TypeError;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
_compile();

=head1 METHODS

=cut

=for html <a name="acquire"></a>

=head2 acquire(Bivio::Type::Lock type)

Attempts to acquire a lock for the specified task for the current realm.
Throws an UPDATE_COLLISION exception if it cannot acquire the lock.

You probably shouldn't be calling this method.  Locks should be acquired as a
task item.  Put the execute_LOCK_TYPE before any actions or forms in your
task item list, e.g.

    Bivio::Biz::Model::Lock->execute_accounting_import

=cut

sub acquire {
    my($self, $type) = @_;
    my($values) = {
	type => $type,
	realm_id => $self->get_request->get('auth_id'),
    };

    # try to get the lock
    my($die) = Bivio::Die->catch(sub {$self->create($values)});
    return unless $die;

    # someone already has it or are we trying to acquire it again?
    $self->die('UPDATE_COLLISION', $values)
	    if $die->get('code') == Bivio::TypeError::EXISTS();

    # something else bad happened
    $die->die();
}

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Overrides
L<Bivio::Biz::PropertyModel::create|Bivio::Biz::PropertyModel/"create">
to default the date to now. Also defaults host and process id to the
current system values. The sentinel defaults to 1.

=cut

sub create {
    my($self, $new_values) = @_;

    # default creation date, host, process_id and sentinel if necessary
    $new_values->{creation_date_time} = Bivio::Type::DateTime->now()
	    unless exists($new_values->{creation_date_time});
    $new_values->{host} = $self->get_request->get('this_host')
	    unless exists($new_values->{host});
    $new_values->{process_id} = $$ unless exists($new_values->{process_id});
    $new_values->{sentinel} = 1 unless exists($new_values->{sentinel});

    $self->SUPER::create($new_values);
    return;
}

=for html <a name="delete"></a>

=head2 delete()

=head2 static delete(hash load_args) : boolean

Deletes the current model from the database, ensuring I<host> and
I<process_id> match if deleting I<self>.

If I<load_args> are supplied, does no validation of I<host> and
I<process_id>.

=cut

sub delete {
    my($self) = shift;
    # No validation, just delete what user specified
    return $self->SUPER::delete(@_) if @_;

    # Do the delete ourselves, because we must make sure host and
    # process_id are the same as the lock.
    my($sth) = Bivio::SQL::Connection->execute(<<'EOF',
	DELETE FROM lock_t
	WHERE type = ?
        AND realm_id = ?
	AND host = ?
        AND process_id = ?
EOF
	[$self->get('type')->as_sql_param,
		 $self->get(qw(realm_id host process_id))], $self);
    my($rows) = $sth->rows;
    $sth->finish();
    return $rows ? 1 : 0;
}

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req, Bivio::Type::Lock type)

Acquires I<type> lock for for this realm.

Usually, one uses the execute_LOCK_TYPE calls which are dynamically
generated for each L<Bivio::Type::Lock|Bivio::Type::Lock>.

=cut

sub execute {
    my($proto, $req, $type) = @_;
    die('missing type parameter') unless ref($type);
    my($self) = $proto->new($req);
    $req->get(ref($self))->die('EXISTS', 'more than one lock on the request')
	    if $req->unsafe_get(ref($self));
    $self->acquire($type);
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

Rollback called, delete lock from request.  Won't be committed.

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
	    type => ['Lock', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'PRIMARY_KEY'],
	    host => ['Line', 'NOT_NULL'],
	    process_id => ['Integer', 'NOT_NULL'],
	    sentinel => ['Boolean', 'NOT_NULL'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
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

    # Ensure that we are deleting the lock on the request
    my($req) = $self->get_request;
    my($req_lock) = $req->unsafe_get(ref($self));
    $self->die('DIE', 'no locks on request') unless $req_lock;
    $self->die('DIE', {message => 'too many locks on the same request',
	request_lock => $req_lock}) unless $req_lock == $self;
    $req->delete(ref($self));

    # If it can't release the lock, blow up.
    $self->die('UPDATE_COLLISION')
	    unless $self->delete();

    return;
}

#=PRIVATE METHODS

# _compile()
#
# Compiles the execute_LOCK functions.
#
sub _compile {
    foreach my $t (Bivio::Type::Lock->get_list) {
	my($n) = $t->get_name;
	my($ln) = lc($n);
	eval(<<"EOF") || die($@);
        sub execute_$ln {
	    my(undef, \$req) = \@_;
            return __PACKAGE__->execute(\$req, Bivio::Type::Lock::$n());
        }
        1;
EOF
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
