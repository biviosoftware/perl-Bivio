# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::MyClubRedirect;
use strict;
$Bivio::Biz::Action::MyClubRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::MyClubRedirect - redirects member to a club

=head1 SYNOPSIS

    use Bivio::Biz::Action::MyClubRedirect;
    Bivio::Biz::Action::MyClubRedirect->execute($req);

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::MyClubRedirect::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Action::MyClubRedirect> looks up preferences and
sends to I<LAST_CLUB_VISITED>.

=cut

#=IMPORTS
use Bivio::Auth::Realm;
use Bivio::Agent::TaskId;
use Bivio::Biz::Model::RealmUser;
use Bivio::Biz::Model::UserClubList;
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Redirects user to club start page if user is a member of a club.

=cut

sub execute {
    my(undef, $req) = @_;

    # Must have auth_user
    my($user_id) = $req->get('auth_user')->get('realm_id');

    my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);
    my($club_id) = $req->get_user_pref('CLUB_LAST_VISITED');
    if (defined($club_id)) {
	# Still a user?
	if ($realm_user->unauth_load(
		realm_id => $club_id, user_id => $user_id)
		&& $realm_user->is_member_or_guest()) {
	    $req->client_redirect(
		    $req->get('task')->get('next'),
		    Bivio::Auth::Realm->new($club_id, $req),
		    undef, undef);
	    # DOES NOT_RETURN
	}
	# Not a user
    }

    my($list) = Bivio::Biz::Model::UserClubList->new($req);
    $list->unauth_load_all({auth_id => $user_id});

    while ($list->next_row) {
	next if $list->is_demo_club();

	# Got a club, go to it.  Don't bother setting pref.  Will
	# get set when user comes back in from redirect
	$req->client_redirect(
		$req->get('task')->get('next'),
		Bivio::Auth::Realm->new($list->get('RealmUser.realm_id'),
			$req),
		undef, undef);
	# DOES NOT RETURN
    }

    # Not a valid club and no valid clubs.  Unset preference.
    $req->set_user_pref('CLUB_LAST_VISITED', undef);

    # Redirect to a logical place in user's site (list of clubs)
    $req->client_redirect(Bivio::Agent::TaskId::USER_CLUB_LIST());
    # DOES NOT RETURN
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
