# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::AddClubUser;
use strict;
$Bivio::Biz::AddClubUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::AddClubUser - creates a new user

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::AddClubUser::ISA = qw(Bivio::Biz::Action);

=head1 DESCRIPTION

C<Bivio::Biz::Action::AddClubUser>

=cut

#=IMPORTS
use Bivio::Biz::Action::CreateUser;
use Bivio::Biz::Action::CreateClubUser;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Request req)

Creates a new user record in the database using values specified in the
request.

=cut

sub execute {
    my(undef, $req) = @_;
    CreateUser->execute($req);
    CreateClubUser->execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
