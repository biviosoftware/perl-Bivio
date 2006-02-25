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
	->set_headers_for_list_send({
	    list_name => $n,
	    list_title => $req->get_nested(qw(auth_realm owner display_name)),
	    reply_to_list => $mr->new_other('Forum')->load->get('want_reply_to'),
	    subject_prefix => "[$n]",
	    req => $req,
# From, Return_path, etc.
    })->enqueue_send($req);
    return;
}

1;
