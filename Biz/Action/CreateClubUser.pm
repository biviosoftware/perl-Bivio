# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::CreateClubUser;
use strict;
$Bivio::Biz::Action::CreateClubUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::CreateClubUser - creates a new user

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::CreateClubUser::ISA = qw(Bivio::Biz::Action);

=head1 DESCRIPTION

C<Bivio::Biz::Action::CreateClubUser>

=cut

#=IMPORTS
use Bivio::Auth::Role;
use Bivio::Type::MailMode;
use Bivio::Biz::Action::CreateUser;

#=VARIABLES
my(@_REALM_USER_FIELDS) = qw(
    role
);
my(%_ROLE_IDS) = map {
    ($_, 1);
} qw(ADMINISTRATOR MEMBER GUEST);

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(User user, Request req)

Creates a new user record in the database using values specified in the
request.

=cut

sub execute {
    my($self, $req) = @_;
    # These must be set
    my($club_id) = $req->get('auth_id');
#TODO: This is fragile.
    my($user) = $req->get('Bivio::Biz::Model::User');
    my($user_id) = $user->get('user_id');
    # not checking find result, should have succeeded or
    # it wouldn't be this far
    my($values) = $req->get_fields('form', \@_REALM_USER_FIELDS);
    my($role) = $values->{role};
    die("invalid role ($role)")
	    unless defined($_ROLE_IDS{$role});
    my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);
    $realm_user->create({
	'realm_id' => $club_id,
	'user_id' => $user_id,
	'role' => Bivio::Auth::Role->$role(),
    });

    my($club_user) = Bivio::Biz::Model::ClubUser->new($req);
    $club_user->create({
	'club_id' => $club_id,
	'user_id' => $user_id,
	'mail_mode' => Bivio::Type::MailMode::WANT_ALL(),
    });
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
