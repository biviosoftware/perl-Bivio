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
use Bivio::UI::HTML::Widget;

#=VARIABLES
my($_W) = 'Bivio::UI::HTML::Widget';

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
    my($as) = $http
	    .$_W->format_uri_static_site($req, 'hm/account-sync.html');
    my($ak) = $http
	    .$_W->format_uri_static_site($req, 'hm/account-keeper.html');
    my($msg) = Bivio::UI::Mail::SupportAuthor->enqueue_message($req,
	    $recipient,
	    # For syntax see Common::_text_to_html
	    "Welcome to bivio", <<"EOF");
Thank you for bringing your club to bivio.  Your private club homepage is:

    $url

Use bivio to:

    * Keep your club books.
    * Generate financial and performance reports.
    * Share documents and exchange messages.

Sign up to AccountSync your brokerage accounts electronically to bivio,
and avoid entering transactions by hand.  AccountSync is only \$95 per
year (or about 50 cents per member per month):

    $as

Promote yourself to CFO with our highest level of service, AccountKeeper.
Your bivio AccountKeeper does all the work.  We will even sign your tax
forms, all for only \$195 per year (or about \$1 per member per month):

    $ak

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

