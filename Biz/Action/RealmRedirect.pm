# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::RealmRedirect;
use strict;
$Bivio::Biz::Action::RealmRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::RealmRedirect - redirects to a realm in query string

=head1 SYNOPSIS

    use Bivio::Biz::Action::RealmRedirect;
    Bivio::Biz::Action::RealmRedirect->execute($req);

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::RealmRedirect::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Action::RealmRedirect> looks redirects to a realm
in the query string.

=cut


=head1 CONSTANTS

=cut

=for html <a name="QUERY_TAG"></a>

=head2 QUERY_TAG : string

Returns tag to be used in query string

=cut

sub QUERY_TAG {
    return 'x';
}

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Util;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Redirects user to club start page if user is a member of a club.

=cut

sub execute {
    my(undef, $req) = @_;

    # If there is a query, use that as the name of the realm
    my($query) = $req->unsafe_get('query');
    if ($query && defined($query->{QUERY_TAG()})) {
#TODO: Assumes realm is always first name...
	$req->client_redirect('/'.Bivio::Util::escape_uri(
		lc($query->{QUERY_TAG()})));
    }
    # Just redirect to the configured default
    $req->client_redirect($req->get('task')->get('next'));
    # DOES NOT RETURN
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
