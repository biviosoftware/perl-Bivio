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

Promote yourself to CFO.  Let your bivio AccountKeeper do all the work for
only \$195 per year, including year-end tax forms:

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

