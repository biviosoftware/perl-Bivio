# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Lock;
use strict;
$Bivio::Biz::Model::Lock::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::Lock - process lock

=head1 SYNOPSIS

    use Bivio::Type::LockType;
    use Bivio::Biz::Model::Lock;

    my($lock) = Bivio::Type::Lock->new($req);
    if ($lock->aquire(Bivio::Type::LockType::ACCOUNTING_IMPORT())) {
        # locked

        # ...

        $lock->release(Bivio::Type::LockType::ACCOUNTING_IMPORT());
        # unlocked
    }

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::Lock::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::Lock> process lock. Locks are intended to control
access to a realm resource across processes. This implementation is simple -
only one lock can exists for a (lock_type, realm_id) pair. The same
process can't aquire the same lock twice (it is not a spin lock).

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
use Bivio::Type::LockType;
use Bivio::Type::PrimaryId;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="aquire"></a>

=head2 aquire(Bivio::Type::LockType lock_type) : boolean

Attempts to aquire a lock for the specified task for the current realm.
Returns 1 on success, 0 on failure.

=cut

sub aquire {
    my($self, $lock_type) = @_;

    my($lock_values) = {
	lock_type => $lock_type,
	realm_id => $self->get_request->get('auth_id'),
    };

    # see if the current process already owns the lock
    if ($self->unsafe_load(%$lock_values)) {
	my($host, $process_id) = _get_host_and_process_id();
	if ($host eq $self->get('host')
		&& $process_id == $self->get('process_id')) {

	    # can't let same process aquire the lock twice
	    # it isn't a spin lock, so the first release
	    # wouldn't do the right thing.
	    Bivio::IO::Alert->warn("duplicate lock aquire attempted
                    $host, $process_id");
	}
	return 0;
    }

    # try to get the lock
    my($die) = Bivio::Die->catch(sub {$self->create($lock_values)});

    if ($die) {
	if ($die->get('code') == Bivio::DieCode::ALREADY_EXISTS()) {
	    # someone already has it
	    return 0;
	}
	# something else bad happened
	$die->die();
    }
    # lock aquired
    return 1;
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
    my($host, $process_id) = _get_host_and_process_id();
    $new_values->{host} = $host unless exists($new_values->{host});
    $new_values->{process_id} = $process_id
	    unless exists($new_values->{process_id});
    $new_values->{sentinel} = 1 unless exists($new_values->{sentinel});

    $self->SUPER::create($new_values);
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
	    lock_type => ['Bivio::Type::LockType',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
            realm_id => ['Bivio::Type::PrimaryId',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    host => ['Bivio::Type::Line',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    process_id => ['Bivio::Type::Integer',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    sentinel => ['Bivio::Type::Boolean',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    creation_date_time => ['Bivio::Type::DateTime',
		    Bivio::SQL::Constraint::NOT_NULL()],
	},
	auth_id => 'realm_id',
    };
}

=for html <a name="release"></a>

=head2 release(Bivio::Type::LockType lock_type)

Release the lock of the specified type for the current realm.

=cut

sub release {
    my($self, $lock_type) = @_;
    die("missing lock_type") unless defined($lock_type);

    my($lock_values) = {
	lock_type => $lock_type,
	realm_id => $self->get_request->get('auth_id'),
    };

    my($host, $process_id) = _get_host_and_process_id();

    # see if the current process already owns the lock
    if ($self->unsafe_load(%$lock_values)) {
	if (($host eq $self->get('host'))
		&& ($process_id == $self->get('process_id'))) {

	    # release it
	    $self->delete();
	}
	else {
	    # didn't own the lock!
	    Bivio::IO::Alert->warn("attempt to release lock by non owner!
                    $host != ".$self->get('host')."
                    $process_id != ".$self->get('process_id'));
	}
    }
    else {
	# no lock!
	Bivio::IO::Alert->warn("attempt to release non existent lock!
                $host, $process_id");
    }
    return;
}

#=PRIVATE METHODS

# _get_host_and_process_id() : (string, int)
#
# Returns the current host and process_id.
#
sub _get_host_and_process_id {
    my($host) = `hostname`;
    chop($host);
    return ($host, $$);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
