# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Action::UserRedirect;
use strict;
$Bivio::PetShop::Action::UserRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Action::UserRedirect::VERSION;

=head1 NAME

Bivio::PetShop::Action::UserRedirect - redirects to the user's realm

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Action::UserRedirect;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::PetShop::Action::UserRedirect::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::PetShop::Action::UserRedirect>

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Auth::RealmType;
use Bivio::UI::Task;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req)

Redirects user to My Site.
Takes into account path_info and redirects to the task identified
by the path_info within user area.  If no path_info, redirects to "next".

=cut

sub execute {
    my(undef, $req) = @_;
    _redirect($req, $req->get('auth_user')->get('name'),
	    Bivio::Auth::RealmType::USER());
    # DOES NOT RETURN
}

#=PRIVATE METHODS

# _redirect(Bivio::Agent::Request req, string realm, Bivio::Auth::RealmType type)
#
# Redirects to the task of interest.
#
sub _redirect {
    my($req, $realm, $type) = @_;
    my($uri) = $req->unsafe_get('path_info') || '';
    my($task);
    if (length($uri)) {
	$task = Bivio::UI::Task->unsafe_get_from_uri($uri, $type, $req);
	$req->throw_die('NOT_FOUND',
		{entity => $uri, message => 'no task for URI'})
		unless $task;
    }
    else {
	$task = $req->get('task')->get('next');
    }
    _trace($uri, '->', $task) if $_TRACE;

    # Redirect without context
    $req->client_redirect($task, $realm, $req->unsafe_get('query'), undef, 1);
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
