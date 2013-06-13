# Copyright (c) 2006-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::MailForward;
use strict;
use Bivio::Base 'Biz.Action';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my(undef, $req) = @_;
    my($mr) = $req->get('Model.MailReceiveDispatchForm');
    Mail_Outgoing()->new(
	Mail_Incoming()->new($mr->get('message')->{content}),
    )->set_recipients(
	$mr->get('recipient'),
	$req,
    )->set_headers_for_forward(
	$mr->unsafe_get('email_alias_incoming'),
	$req,
    )->enqueue_send($req);
    return;
}

1;
