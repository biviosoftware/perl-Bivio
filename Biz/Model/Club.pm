# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Club;
use strict;
use Bivio::Base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create_realm {
    # (self, hash_ref, hash_ref) : array
    # Creates the Club, RealmOwner, and RealmUser models.  I<realm_owner> may be an
    # empty hash_ref.  I<realm_owner>.password will be invalid.
    #
    # B<Does not set the realm to the new club.>
    #
    # Returns (club, realm_owner) models.
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

sub internal_initialize {
    return {
	version => 1,
	table_name => 'club_t',
	columns => {
            club_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    start_date => ['Date', 'NONE'],
        },
	other => [
            [qw(club_id RealmOwner.realm_id)],
	],
	auth_id => 'club_id',
    };
}

1;
