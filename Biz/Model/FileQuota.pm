# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::FileQuota;
use strict;
$Bivio::Biz::Model::FileQuota::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::FileQuota - interface to file_quota_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::FileQuota;
    Bivio::Biz::Model::FileQuota->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::FileQuota::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::FileQuota> is the create, read, update,
and delete interface to the C<file_quota_t> table.

=cut


=head1 CONSTANTS

=cut

=for html <a name="DEFAULT_MAX_KBYTES"></a>

=head2 DEFAULT_MAX_KBYTES : int

Initial I<max_kbytes> for a realm, 50MB.

=cut

sub DEFAULT_MAX_KBYTES {
    return 50 * 0x400;
}

=for html <a name="DEFAULT_MAX_KBYTES_FOR_DEMO_CLUB"></a>

=head2 DEFAULT_MAX_KBYTES_FOR_DEMO_CLUB : int

Initial I<max_kbytes> for demo club, 1MB.  There can be
one Demo Club per user, so can't be as much as a normal club.

=cut

sub DEFAULT_MAX_KBYTES_FOR_DEMO_CLUB {
    return 0x400;
}

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::Integer;
use Bivio::Type::PrimaryId;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="adjust_kbytes"></a>

=head2 adjust_kbytes(int addend)

Increments I<kbytes> by I<addend>.

=cut

sub adjust_kbytes {
    my($self, $addend) = @_;
#TODO: Make this atomic (UPDATE SET kbytes = kbytes + $addend WHERE 
    $self->update({kbytes => $self->get('kbytes') + $addend});
    return;
}

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Initializes all attributes if not set. I<realm_id> is set to
I<auth_id>.

=cut

sub create {
    my($self, $values) = (shift, shift);
    foreach my $a (qw(kbytes max_kbytes)) {
	$values->{$a} = 0 unless defined($values->{$a});
    }
    $values->{realm_id} = $self->get_request->get('auth_id')
	    unless $values->{realm_id};
    return $self->SUPER::create($values, @_);
}

=for html <a name="get_current_or_load"></a>

=head2 static get_current_or_load(Bivio::Agent::Request req) : Bivio::Biz::Model::FileQuota

=head2 static get_current_or_load(Bivio::Agent::Request req, string realm_id) : Bivio::Biz::Model::FileQuota

Returns file quota on the request if same as I<realm_id> (or req's auth_id)
or loads.

It is critical we try to reuse the same quota instance, because
multiple operations (read "replace") may occur within the same task.

=cut

sub get_current_or_load {
    my($proto, $req, $realm_id) = @_;
    $realm_id ||= $req->get('auth_id');
    my($self) = $req->unsafe_get(ref($proto));
    return $self && $self->get('realm_id') eq $realm_id
	    ? $self
	    : $proto->new($req)->unauth_load_or_die(realm_id => $realm_id);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'file_quota_t',
	columns => {
            realm_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            kbytes => ['Bivio::Type::Integer',
    		Bivio::SQL::Constraint::NOT_NULL()],
            max_kbytes => ['Bivio::Type::Integer',
    		Bivio::SQL::Constraint::NOT_NULL()],
        },
	auth_id => [qw(realm_id)],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
