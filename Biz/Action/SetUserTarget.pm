# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::SetUserTarget;
use strict;
$Bivio::Biz::Action::SetUserTarget::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::SetUserTarget - sets user_target in the request

=head1 SYNOPSIS

    use Bivio::Biz::Action::SetUserTarget;
    Bivio::Biz::Action::SetUserTarget->execute($req);

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::SetUserTarget::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Action::SetUserTarget> looks up C<auth_realm> to
determing if the target of the request should be C<auth_realm> or
C<auth_user>.  It is C<auth_user> in club realm.

Sets C<user_target> in the request which is used by forms.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Set C<user_target> to either C<auth_realm> or C<auth_user>.

=cut

sub execute {
    my(undef, $req) = @_;
    my($auth_realm, $target) = $req->get('auth_realm', 'auth_user');
    if ($auth_realm->get('type') == Bivio::Auth::RealmType::USER()) {
	$target = $auth_realm->get('owner');
    }
    elsif (!defined($target)) {
	$req->die(Bivio::DieCode::NOT_FOUND(),
	       'anonymous user has no target in realm');
    }
    $req->put(user_target => $target);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
