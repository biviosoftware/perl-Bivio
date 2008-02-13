# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::MailForward;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my(undef, $req) = @_;
    my($mr) = $req->get('Model.MailReceiveDispatchForm');
    Bivio::Mail::Outgoing->new(
	Bivio::Mail::Incoming->new($mr->get('message')->{content}),
    )->set_recipients($mr->get('recipient'), $req)
	->set_headers_for_forward
	    ->enqueue_send($req);
    return;
}

1;
