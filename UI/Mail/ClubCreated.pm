# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Mail::ClubCreated;
use strict;
$Bivio::UI::Mail::ClubCreated::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Mail::ClubCreated::VERSION;

=head1 NAME

Bivio::UI::Mail::ClubCreated - sends a mail message to the newly created club

=head1 SYNOPSIS

    use Bivio::UI::Mail::ClubCreated;

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::Mail::ClubCreated::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::Mail::ClubCreated>

=cut

#=IMPORTS
use Bivio::UI::Mail::SupportAuthor;
use Bivio::UI::Widget;
use Bivio::Societas::UI::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::Societas::UI::ViewShortcuts';


=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Sends an email to the newly created club.

=cut

sub execute {
    my(undef, $req) = @_;
#TODO: This is fragile.  Need to ensure the realm owner is the club
    my($club) = $req->get('Bivio::Biz::Model::RealmOwner');
    my($url) = $club->format_http();
    my($recipient) = $club->format_email();
    my($http) = $req->format_http_prefix;
    my($subscribe) = $http
	    .$_VS->vs_format_uri_static_site($req, 'need-link-to-form'');
    my($as) = $http
	    .$_VS->vs_format_uri_static_site($req, 'hm/account-sync.html');
    my($ak) = $http
	    .$_VS->vs_format_uri_static_site($req, 'hm/account-keeper.html');
    my($msg) = Bivio::UI::Mail::SupportAuthor->enqueue_message($req,
	    $recipient,
	    # For syntax see Common::_text_to_html
	    "Welcome to bivio", <<"EOF");
Congratulations on creating a bivio club.  Your private club homepage is:

    $url

Use bivio to:

    * Keep your club books.
    * Generate financial and performance reports.
    * Exchange messages and documents with club members.
    * Fill out IRS tax forms.

Your club will have complete access to bivio for 3 full months (only tax
features are disabled during the free trial).  You can subscribe at any
time by visiting:

    $subscribe

Upgrade your subscription to AccountSync, and never enter a transaction
by hand again - your books will be updated automatically.  AccountSync
works with many popular brokerages, including Charles Schwab, E*Trade,
TD Waterhouse, Ameritrade and BUYandHOLD.  

    $as

A final tip.  To send a message to your club, use this email address:

    $recipient
EOF
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;

