# Copyright (c) 2006-2014 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::MailForward;
use strict;
use Bivio::Base 'Biz.Action';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REWRITE_FROM_DOMAIN_URI {
    return 'user';
}

sub execute {
    return _execute(shift, shift);
}

sub execute_rewrite_from_domain {
    my($proto, $req) = @_;
    return _execute($proto, $req, Model_Email()->new($req)->load->get('email'));
}

sub _execute {
    my(undef, $req, $recipient) = @_;
    my($mr) = $req->get('Model.MailReceiveDispatchForm');
    Mail_Outgoing()->new(
	Mail_Incoming()->new($mr->get('message')->{content}),
    )->set_recipients(
	$recipient || $mr->get('recipient'),
	$req,
    )->set_headers_for_forward(
	$mr->unsafe_get('email_alias_incoming'),
	$req,
    )->enqueue_send($req);
    return;
}

1;
