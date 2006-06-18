# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Club;
use strict;
$Bivio::Biz::Model::Club::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::Club::VERSION;

=head1 NAME

Bivio::Biz::Model::Club - interface to club_t SQL table

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::Club;
    Bivio::Biz::Model::Club->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::Club::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::Club> is the create, read, update,
and delete interface to the C<club_t> table.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_realm"></a>

=head2 create_realm(hash_ref club, hash_ref realm_owner) : array

Creates the Club, RealmOwner, and RealmUser models.  I<realm_owner> may be an
empty hash_ref.  I<realm_owner>.password will be invalid.

B<Does not set the realm to the new club.>

Returns (club, realm_owner) models.

=cut

sub create_realm {
    my($self, $club, $realm_owner, $first_admin_id) = @_;
    $self->create($club);
    my($ro) = $self->new_other('RealmOwner')->create({
	%$realm_owner,
	realm_type => Bivio::Auth::RealmType->CLUB,
	realm_id => $self->get('club_id'),
    });
    $self->new_other('RealmUser')->create({
	realm_id => $self->get('club_id'),
	user_id => $first_admin_id || $self->get_request->get('auth_user_id'),
        role => Bivio::Auth::Role->ADMINISTRATOR,
    });
    return ($self, $ro);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'club_t',
	columns => {
            club_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    start_date => ['Date', 'NONE'],
        },
	auth_id => 'club_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
