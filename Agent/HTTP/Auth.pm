# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Auth;
use strict;
$Bivio::Agent::HTTP::Auth::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::Auth - user and club authorization support

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::Auth;
    my($club, $club_user) = Bivio::Agent::HTTP::Auth->authorize_admin($req);
    if ($club) {
        # success
    }

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::HTTP::Auth::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Auth> provides static methods for user and club
authorization.

=cut

#=IMPORTS
use Bivio::Biz::Club;
use Bivio::Biz::ClubUser;
use Bivio::Biz::FindParams;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="authorize_admin"></a>

=head2 static authorize_admin(Request $req) : (Club, ClubUser)

Authorizes that the current user is an administrator of the current club.
Returns the club and club-user instances if sucessful, otherwise undef.

=cut

sub authorize_admin {
    my($self, $req) = @_;

    my($club, $club_user) = $self->authorize_club_user($req);

    $club || return undef;

    # is the user an admin of the club?
    return undef if $club_user->get('role') != 0;

    return ($club, $club_user);
}

=for html <a name="authorize_club_user"></a>

=head2 authorize_club_user(Request $req) : (Club, ClubUser)

Authorizes that the current user is a user of the current club.
Returns the club and club-user instances if sucessful, otherwise undef.

=cut

sub authorize_club_user {
    my(undef, $req) = @_;

    my($user) = $req->get_user();

    # has the user logged in?
    return undef if ! $user;

    # do the password's match?
    unless($req->get_password()
	    && $req->get_password() eq $user->get('password')) {
	return undef;
    }

    my($club) = Bivio::Biz::Club->new();
    $club->find(Bivio::Biz::FindParams->new(
	    {name => $req->get_target_name()}));

    # does the club exist?
    return undef if ! $club->get_status()->is_OK();

    my($club_user) = Bivio::Biz::ClubUser->new();
    $club_user->find(Bivio::Biz::FindParams->new(
	    {club => $club->get('id'), user => $user->get('id')}));

    # is the user a member of the club?
    return undef if ! $club_user->get_status()->is_OK();

    return ($club, $club_user);
}



#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
