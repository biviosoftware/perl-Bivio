# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ClientRedirect;
use strict;
$Bivio::Biz::Action::ClientRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::ClientRedirect - redirects to next or cancel tasks

=head1 SYNOPSIS

    use Bivio::Biz::Action::ClientRedirect;
    Bivio::Biz::Action::ClientRedirect->execute_next($req);
    Bivio::Biz::Action::ClientRedirect->execute_cancel($req);

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::ClientRedirect::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Action::ClientRedirect> redirects to the cancel or
next task values.  There is no I<execute>, you must be explicit.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_cancel"></a>

=head2 execute_cancel(Bivio::Agent::Request req)

Redirect to I<cancel> task.

=cut

sub execute_cancel {
    my(undef, $req) = @_;
    $req->client_redirect($req->get('task')->get('cancel'));
    # DOES NOT RETURN
}

=for html <a name="execute_next"></a>

=head2 execute_next(Bivio::Agent::Request req)

Redirect to I<next> task.

=cut

sub execute_next {
    my(undef, $req) = @_;
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
