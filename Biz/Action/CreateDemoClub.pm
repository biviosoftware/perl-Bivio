# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::CreateDemoClub;
use strict;
$Bivio::Biz::Action::CreateDemoClub::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::CreateDemoClub - 

=head1 SYNOPSIS

    use Bivio::Biz::Action::CreateDemoClub;
    Bivio::Biz::Action::CreateDemoClub->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::CreateDemoClub::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::CreateDemoClub>

=cut

=head1 CONSTANTS

=cut

=for html <a name="NAME_SUFFIX"></a>

=head2 NAME_SUFFIX : string

the suffix of a user's demo club

=cut

sub NAME_SUFFIX {
    return '_demo_club';
}

#=IMPORTS
use Bivio::Auth::Role;
use Bivio::Biz::Action::CopyClub;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Biz::Model::RealmUser;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request)

Creates a demo club for the 'user' argument of the request.

=cut

sub execute {
    my(undef, $req) = @_;

#TODO: This probably should be auth_user
    my($user) = $req->get('user');
    my($realm) = Bivio::Biz::Model::RealmOwner->new($req);
    $realm->unauth_load(realm_id => $user->get('user_id'));

    # load and copy the demo club
    my($name) = $realm->get('name')
	    .Bivio::Biz::Action::CreateDemoClub::NAME_SUFFIX();
    $realm->unauth_load(name => 'demo')
	    || die("couldn't find demo realm");;
    $req->put(source => $realm);
    $req->put(target_name => $name);
    $req->put(target_display_name => $realm->get('display_name')
	."'s Demo Club");
    Bivio::Biz::Action::CopyClub->get_instance()->execute($req);

    # add the user to its demo club
    $realm->unauth_load(name => $name);
    my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);

    # guard against the silly case where the current user is a demo user
    unless ($realm_user->unauth_load(
	'realm_id' => $realm->get('realm_id'),
	'user_id' => $user->get('user_id'))) {

	$realm_user->create({
	    'realm_id' => $realm->get('realm_id'),
	    'user_id' => $user->get('user_id'),
	    'role' => Bivio::Auth::Role::ADMINISTRATOR(),
	});
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
