# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::HandleUnknownMail;
use strict;
$Bivio::Biz::Action::HandleUnknownMail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::HandleUnknownMail - handle unknown mail recipient

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::HandleUnknownMail::ISA = qw(Bivio::Biz::Action);

=head1 DESCRIPTION

C<Bivio::Biz::Action::HandleUnknownMail> handles mail sent to an
unknown user.
We throw away mail sent to C<ignore-*>.
Other mail gets bounced with a not-found.

=cut

#=IMPORTS
use Bivio::DieCode;
use Bivio::Biz::Action::ForwardClubMail;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Biz::Model::Club;
use Bivio::Type::Email;

#=VARIABLES
my($_IGNORE) = Bivio::Type::Email->IGNORE_PREFIX;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Request req)

Looks at recipient to determine action:
 ignore-club : toss
 club-owner  : forward to administrators only (address used for bounces)
 club-people : forward to all users of club, but don't store in message board
 club-board  : only store in message board

=cut

sub execute {
    my(undef, $req) = @_;
    my($msg) = $req->get('message');

    # There should only be one recipient
    my($who) = $msg->get_recipients->[0];
    # Ignore?
    return if $who =~ /^$_IGNORE/oi;

    if ($who =~ /^(\w+)-(people|board|owner)$/i) {
	my($name, $which) = (lc($1), $2);
	my($realm_owner) = Bivio::Biz::Model::RealmOwner->new($req);
	if ($realm_owner->unauth_load(name => $name)
		&& $realm_owner->get('realm_type')
		== Bivio::Auth::RealmType::CLUB()) {
	    my($club) = Bivio::Biz::Model::Club->new($req);
	    $club->unauth_load(club_id => $realm_owner->get('realm_id'));
	    if ($which eq 'people') {
		Bivio::Biz::Action::ForwardClubMail->send(
			$realm_owner, $club, $msg);
	    }
	    elsif ($which eq 'board') {
		Bivio::Biz::Action::ForwardClubMail->store(
			$realm_owner, $club, $msg);
	    }
            else {
                # club-owner
                # Forward message unchanged to the Administrators
                my($out_msg) = Bivio::Mail::Outgoing->new($msg);
                my($admins) = Bivio::Biz::Model::RealmAdminList->new($req);
                $admins->unauth_load_all({auth_id => $club->get('club_id')});
                $out_msg->set_recipients($admins->get_outgoing_emails);
                $out_msg->set_envelope_from($req->get('support_email'));
                $out_msg->enqueue_send;
            }
	    return;
	}
    }
    $req->die(Bivio::DieCode::NOT_FOUND(), entity => $who);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
