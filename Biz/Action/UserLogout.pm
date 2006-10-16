# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::UserLogout;
use strict;
$Bivio::Biz::Action::UserLogout::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::UserLogout::VERSION;

=head1 NAME

Bivio::Biz::Action::UserLogout - logs the user out

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::UserLogout;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::UserLogout::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::UserLogout> clears the user on the request
and in the cookie.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : Bivio::Agent::TaskId

Calls the I<Model.LoginForm> to clear the user.

=cut

sub execute {
    my(undef, $req) = @_;
    return Bivio::Biz::Model->get_instance('UserLoginForm')->execute(
	$req, {realm_owner => undef});
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
