# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::Login;
use strict;
$Bivio::Biz::Action::Login::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::Login - forces a login

=head1 SYNOPSIS

    use Bivio::Biz::Action::Login;
    Bivio::Biz::Action::Login->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::Login::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Action::Login> forces a login by always dying
with AUTH_REQUIRED.

=cut

#=IMPORTS
use Bivio::DieCode;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) 

Throws L<Bivio::DieCode::AUTH_REQUIRED|Bivio::DieCode::AUTH_REQUIRED>

=cut

sub execute {
    my(undef, $req) = @_;
    $req->die(Bivio::DieCode::AUTH_REQUIRED(), {
	message => 'forcing login'});
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
