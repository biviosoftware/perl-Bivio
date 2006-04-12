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
    my($rm) = Bivio::Biz::Model->new($req, 'RealmMail');
    my($n) = $req->get_nested(qw(auth_realm owner name));
    my($out) = Bivio::Mail::Outgoing->new(
	$rm->create_from_rfc822($mr->get('message')->{content})
    )->set_headers_for_list_send({
	list_name => $n,
	list_email => $req->format_email($n),
	list_title => $req->get_nested(qw(auth_realm owner display_name)),
	reply_to_list => $mr->new_other('Forum')->load->get('want_reply_to'),
#TODO: This should be configurable
	keep_to_cc => 1,
	subject_prefix => "[$n]",
	req => $req,
    });
    my($rmb) = $mr->new_other('RealmMailBounce');
    $mr->new_other('RealmEmailList')->get_recipients(sub {
	my($it) = @_;
	# ASSUMES: Bivio::Mail::Outgoing does not copy body on new().
	# Otherwise, we could blow out the memory if the list got too
	# large.
	$out->new($out)
	    ->set_recipients($it->get('Email.email'), $req)
	    ->set_header(
		'Return-Path' => $rmb->return_path(
		    $it->get(qw(RealmUser.user_id Email.email)),
		    $rm->get('realm_file_id'),
		),
	    )->enqueue_send($req);
	return;
    });
    return;
}

1;
