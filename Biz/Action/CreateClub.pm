# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::CreateClub;
use strict;
$Bivio::Biz::Action::CreateClub::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::CreateClub - creates a new bivio club

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::CreateClub::ISA = qw(Bivio::Biz::Action);

=head1 DESCRIPTION

C<Bivio::Biz::Action::CreateClub> creates a club and its administrator.

=cut

#=IMPORTS
use Bivio::Biz::Action::CreateClubUser;
use Bivio::Biz::PropertyModel::ClubUser;
use Bivio::Biz::PropertyModel::MailMessage;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my(@_ALLOWED_FIELDS) = qw(name full_name);

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Request req)

Creates a new club record in the database using values specified in the
request.

=cut

sub execute {
    my(undef, $req) = @_;
    my($user) = $req->get('auth_user');

    my($values) = $req->get_fields('form', \@_ALLOWED_FIELDS);
    my($club) = Bivio::Biz::PropertyModel::Club->new($req);
    # There has to be an auth_user or can't create a club
    $values->{'bytes_in_use'} = 0;
    $values->{'bytes_max'} = 8 * 1024 * 1024;
    $club->create($values);

    # Create the first club user, the auth_user as administrator
    $req->get('form')->{role} = Bivio::Auth::Role::ADMINISTRATOR->as_int;
    Bivio::Biz::Action::CreateClubUser->execute($req);

    # Initialize the message manager
    my($mm) = Bivio::Biz::PropertyModel::MailMessage->new($req);
    $mm->setup_club($club);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
