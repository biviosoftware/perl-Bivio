# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ForwardClubMail;
use strict;
$Bivio::Biz::Action::ForwardClubMail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::ForwardClubMail - creates a new bivio club

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::ForwardClubMail::ISA = qw(Bivio::Biz::Action);

=head1 DESCRIPTION

C<Bivio::Biz::Action::ForwardClubMail> creates a club and its administrator.

=cut

#=IMPORTS
use Bivio::Mail::Outgoing;
use Bivio::Biz::Model::MailMessage;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Auth::RealmType;
use Bivio::IO::Trace;

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
    my(undef, $req) = @_;
    my($realm_owner) = $req->get('auth_realm')->get('owner');
    die('auth_realm not a club')
	    unless $realm_owner->get('realm_type') ==
		    Bivio::Auth::RealmType::CLUB();
    my($club) = Bivio::Biz::Model::Club->new($req);
    $club->load(club_id => $realm_owner->get('realm_id'));
    my($msg) = $req->get('message');
    &_trace($realm_owner, ': ', $msg->get_message_id) if $_TRACE;
    my($in_msg);
    $in_msg = Bivio::Biz::Model::MailMessage->new($req);
    $in_msg->create($msg, $realm_owner, $club);
    my($out_msg) = Bivio::Mail::Outgoing->new($msg);
    $out_msg->set_recipients($club->get_outgoing_emails());
    $out_msg->set_headers_for_list_send($realm_owner->get('name'),
	    $realm_owner->get('display_name'), 1, 1);
    $out_msg->enqueue_send;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
