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

C<Bivio::Biz::Action::MyClubRedirect> looks up C<auth_user> to find
to which clubs she belongs.  Redirects request

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Auth::Realm::Club;
use Bivio::Auth::Realm::User;
use Bivio::Biz::Model::UserClubList;

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
    # Change to this user's realm, so we can look at UserClubList
    $req->set_realm(Bivio::Auth::Realm::User->new($req->get('auth_user')));
#TODO: Optimize to user request's user_realms
    my($clubs) = Bivio::Biz::Model::UserClubList->new($req);
    $clubs->load;
    my($num_clubs) = $clubs->get_result_set_size;
#TODO: Probably want to redirect to "create club"
    $req->die(Bivio::DieCode::NOT_FOUND, {entity => 'UserClubList'})
	    unless $num_clubs;
    $clubs->next_row;
    _trace($clubs->get_model('RealmOwner'), ', ',
	    $clubs->get('RealmUser.role')) if $_TRACE;
#TODO: If more than one club, then provide list or lookup default?
#TODO: Look for club where user is not a guest.
    $req->set_realm(Bivio::Auth::Realm::Club->new(
	    $clubs->get_model('RealmOwner')));
    # Go to the task for my_club
    $req->redirect($req->get('task')->get('next'));
    # DOES NOT RETURN
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
