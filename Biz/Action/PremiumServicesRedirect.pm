# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::PremiumServicesRedirect;
use strict;
$Bivio::Biz::Action::PremiumServicesRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::PremiumServicesRedirect::VERSION;

=head1 NAME

Bivio::Biz::Action::PremiumServicesRedirect - redirects to the premium services page

=head1 SYNOPSIS

    use Bivio::Biz::Action::PremiumServicesRedirect;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::PremiumServicesRedirect::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::PremiumServicesRedirect> redirects to the premium services page

=cut

#=IMPORTS
use Bivio::Societas::UI::ViewShortcuts;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_VS) = 'Bivio::Societas::UI::ViewShortcuts';

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request)

Redirects to the taxes page.

=cut

sub execute {
    my($proto, $req) = @_;
    $req->client_redirect($_VS->vs_format_uri_static_site(
	   $req, 'hm/services.html'));
    # DOES NOT RETURN
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
