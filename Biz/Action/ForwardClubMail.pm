# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ForwardClubMail;
use strict;
$Bivio::Biz::Action::ForwardClubMail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::ForwardClubMail - forwards mail to a club's members

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::ForwardClubMail::ISA = qw(Bivio::Biz::Action);

=head1 DESCRIPTION

C<Bivio::Biz::Action::ForwardClubMail> forwards mail to a club's members.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Auth::Realm;
use Bivio::Auth::RealmType;
use Bivio::Biz::Model::MailMessage;
use Bivio::Biz::Model::RealmOwner;
use Bivio::IO::Trace;
use Bivio::Mail::Outgoing;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Request req)

Creates a new club record in the database using values specified in the
request.

=cut

sub execute {
    my($proto, $req) = @_;
    my($realm_owner) = $req->get('auth_realm')->get('owner');
    die('auth_realm not a club')
	    unless $realm_owner->get('realm_type') ==
		    Bivio::Auth::RealmType::CLUB();
    my($club) = Bivio::Biz::Model::Club->new($req);
    $club->load(club_id => $realm_owner->get('realm_id'));
    my($msg) = $req->get('message');
    my($headers) = $msg->get_headers;
    if (exists($headers->{'x-bivio-forwarded'})) {
        $req->die('MAIL_LOOP', 'msg has X-Bivio-Forwarded set, avoid mail loops');
    }
    &_trace($realm_owner, ': ', $msg->get_message_id) if $_TRACE;
    $proto->store($realm_owner, $club, $msg);
    $proto->send($realm_owner, $club, $msg);
    return;
}

=for html <a name="send"></a>

=head2 static send(Bivio::Biz::Model::RealmOwner realm_owner, Bivio::Biz::Model::Club club, Bivio::Mail::Incoming msg)

Sends the mail to the club members.

=cut

sub send {
    my(undef, $realm_owner, $club, $msg) = @_;

    my($req) = $realm_owner->get_request;
    _trace($req->unsafe_get('auth_realm'), ': ', $msg->get_message_id)
	    if $_TRACE;

    # Get the outgoing addresses
    my($emails) = $club->get_outgoing_emails();

    # Bounce mail if couldn't find a valid email
    $req->die('NOT_FOUND', 'alls emails marked as invalid')
	    unless $emails;

    # Forward the message
    my($out_msg) = Bivio::Mail::Outgoing->new($msg);
    $out_msg->set_recipients($emails);
    my($display_name) = $realm_owner->get('display_name');
    $out_msg->set_headers_for_list_send($realm_owner->get('name'),
	    $display_name, 1, 1);
    # Include the club's URI in the header for convenience
    $out_msg->set_header('Organization',
	    $realm_owner->get_request->format_http(
	    Bivio::Agent::TaskId::CLUB_HOME(),
	    undef, Bivio::Auth::Realm->new($realm_owner)));
    # Add a tag to catch mail loops
    $out_msg->set_header('X-Bivio-Forwarded', $realm_owner->get('name'));
    $out_msg->enqueue_send;
    return;
}

=for html <a name="store"></a>

=head2 static store(Bivio::Biz::Model::RealmOwner realm_owner, Bivio::Biz::Model::Club club, Bivio::Mail::Incoming msg)

Stores the mail in the club message board.z

=cut

sub store {
    my(undef, $realm_owner, $club, $msg) = @_;
    my($in_msg);
    $in_msg = Bivio::Biz::Model::MailMessage->new($club->get_request);
    $in_msg->create($msg, $realm_owner, $club);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
