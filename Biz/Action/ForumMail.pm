# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::ForumMail;
use strict;
use base ('Bivio::Biz::Action');
use Bivio::Mail::Outgoing;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my(undef, $req) = @_;
    my($mr) = $req->get('Model.MailReceiveDispatchForm');
    my($in) = Bivio::Biz::Model->new($req, 'RealmMail')->create_from_rfc822(
	$mr->get('message')->{content});
    my($to) = $mr->new_other('RealmEmailList')->get_recipients;
    return unless @$to;
    my($n) = $req->get_nested(qw(auth_realm owner name));
    Bivio::Mail::Outgoing->new($in)
	->set_recipients($to)
	->set_headers_for_list_send(
	    $n,
	    $req->get_nested(qw(auth_realm owner display_name)),
	    0,
	    "[$n]",
	    $req,
        )->enqueue_send($req);
    return;
}

sub _forward_msg {
######################## NEED TO COPY
    my($req, $members_only) = @_;
    my($realm_owner) = $req->get('auth_realm')->get('owner');
    # Do NOT forward message if we detected a potential mail loop

    return if $req->unsafe_get('mail_in_loop');

    my($emails) = Bivio::Biz::Model->new($req, 'ClubUserList')->load_all
	    ->get_outgoing_emails;
    $req->throw_die('NOT_FOUND', 'all emails marked as invalid')
            unless $emails;

    my($msg) = $req->get('mail');
    $msg->add_recipients($emails);

    my($set_reply_to) = Societas::Biz::Model::Preferences
            ->get_club_pref($req, 'MAIL_SET_REPLY_TO');
    $msg->set_headers_for_list_send(
	'recipient',
	$realm_owner->get('display_name'),
	$set_reply_to,
	1,
	$req,
    );
    # Include the club's URI in the header for convenience
    $msg->get_head->replace('Organization',
            $req->format_http(Bivio::Agent::TaskId::CLUB_HOME(),
                    undef, $req->get('auth_realm')));
    $msg->enqueue_send;
    return;
}

1;
