# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Mail::ClubCreated;
use strict;
$Bivio::UI::Mail::ClubCreated::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Mail::ClubCreated - sends a mail message to the newly created club

=head1 SYNOPSIS

    use Bivio::UI::Mail::ClubCreated;
    Bivio::UI::Mail::ClubCreated->execute();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::Mail::ClubCreated::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::Mail::ClubCreated>

=cut

#=IMPORTS
use Bivio::UI::Mail::CustomerSupport;

#=VARIABLES

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
    my($msg) = Bivio::UI::Mail::CustomerSupport->enqueue_message($req,
	    $recipient,
	    # email software puts into the club's name
	    "Welcome to bivio", <<"EOF");
Thank you for bringing your club to bivio.  You may access your
club's space at the following URL:

    $url

Your club's area is accessible only to members and guests of your
club.  Your area provides your with a host of functions including:
revise and view your books, send to and view your club's message
board, and download financial data.

In addition, you can reach your club members by mailing to the
following address:

    mailto:$recipient

Messages sent to this address will also appear in your club's
message board.
EOF
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;

