# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::PublicRealm;
use strict;
$Bivio::Biz::Action::PublicRealm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::PublicRealm - sets realm_is_public attribute on the request

=head1 SYNOPSIS

    use Bivio::Biz::Action::PublicRealm;
    Bivio::Biz::Action::PublicRealm->execute($req);

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::PublicRealm::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Action::PublicRealm> sets the C<realm_is_public> attribute
on the request.  This is used by lists, forms and UI modules to allow, but
restrict anonymous access.

=cut

#=IMPORTS
use Bivio::DieCode;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Set C<realm_is_public> to I<true> if realm allows public access
to its club space.

Set C<is_realm_user> to I<true> is user is a member or guest.

=cut

sub execute {
    my($self, $req) = @_;

    my($user) = $req->get('auth_user');
    my($club_id) = $req->get('auth_id');

    # Check user is either a member or guest of the club
    my($is_realm_user) = 0;
    if (defined($user)) {
        my($user_id) = $user->get('realm_id');
        my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);
        $is_realm_user = $realm_user->unauth_load(
		realm_id => $club_id, user_id => $user_id)
		&& $realm_user->is_member_or_guest();
    }

    # Check ANONYMOUS role has DOCUMENT_READ access
    my($rr) = Bivio::Biz::Model::RealmRole->new();
    my($realm_is_public) = 0;
    if ($rr->unauth_load(realm_id => $club_id,
            role => Bivio::Auth::Role::ANONYMOUS())) {
        my($ps) = $rr->get('permission_set');
        $realm_is_public = Bivio::Auth::PermissionSet->is_set(\$ps,
                Bivio::Auth::Permission::DOCUMENT_READ());
    }

    $req->put(
            is_realm_user => $is_realm_user,
            realm_is_public => $realm_is_public,
           );
    return;
}

#=PRIVATE METHODS


=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
