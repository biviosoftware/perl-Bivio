# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::UserRealmList;
use strict;
$Bivio::Biz::Model::UserRealmList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::UserRealmList - a list of realms to which a user belongs

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::UserRealmList;
    Bivio::Biz::Model::UserRealmList->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::UserRealmList::ISA = qw(Bivio::Biz::ListModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::UserRealmList> finds the realms to which a user
belongs.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	other => [qw(
            RealmOwner.name
	    RealmUser.role
	    RealmUser.honorific
	    RealmOwner.realm_type
	)],
	primary_key => [
	    [qw(RealmUser.realm_id RealmOwner.realm_id)],
	],
	auth_id => ['RealmUser.user_id'],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
