# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::PublicRedirect;
use strict;
$Bivio::Biz::Action::PublicRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::PublicRedirect - sets realm_is_public attribute on the request

=head1 SYNOPSIS

    use Bivio::Biz::Action::PublicRedirect;
    Bivio::Biz::Action::PublicRedirect->execute($req);

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::PublicRedirect::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Action::PublicRedirect> redirects to /files/index.htm[l]
in case the file exists. For anonymous users, only redirects if the
file is public.

=cut

#=IMPORTS
use Bivio::Biz::Model::File;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Redirect to club home page (index.htm[l]) if file exists.
For anonymous users, only redirect if file is public.

=cut

sub execute {
    my($self, $req) = @_;

    # Club must be public or user a club member for this feature
    return unless $req->get('realm_is_public') || $req->get('is_realm_user');

    my($realm_id) = $req->get('auth_id');
    my($volume) = $req->get('Bivio::Type::FileVolume');
    my($root_id) = $volume->get_root_directory_id($realm_id);
    my($file) = Bivio::Biz::Model::File->new;
    my($redirect_uri) = $req->format_http(
            Bivio::Agent::TaskId::CLUB_COMMUNICATIONS_FILE_READ) . '/';

    foreach my $name ('index.htm', 'index.html') {
        $req->client_redirect($redirect_uri.$name)
                if $file->unauth_load(name => $name, realm_id => $realm_id,
                        volume => $volume) && ($req->get('is_realm_user')
                                || $file->get('is_public'));
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
