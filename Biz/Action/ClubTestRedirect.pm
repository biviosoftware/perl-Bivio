# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ClubTestRedirect;
use strict;
$Bivio::Biz::Action::ClubTestRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::ClubTestRedirect - testing club redirects

=head1 SYNOPSIS

    use Bivio::Biz::Action::ClubTestRedirect;
    Bivio::Biz::Action::ClubTestRedirect->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::ClubTestRedirect::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Action::ClubTestRedirect>

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Bivio::Agent::TaskId;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute() : 

=cut

sub execute {
    my(undef, $req) = @_;
    $req->server_redirect(Bivio::Agent::TaskId::CLUB_MEMBER_LIST());
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
