# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::MailForward;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my(undef, $req) = @_;
    my($mr) = $req->get('Model.MailReceiveDispatchForm');
    my($msg) = $mr->get('message')->{content};
    # fix up test recipient for remote acceptance tests
    $$msg =~ s/^(@{[Bivio::Mail::Common->TEST_RECIPIENT_HDR]}:\s).*$/$1@{[$mr->get('recipient')]}/m;
    # Let sendmail handle mail loop detection (for now)
    Bivio::Mail::Incoming->new($msg)
        ->set_recipients($mr->get('recipient'), $req)->enqueue_send($req);
    return;
}

1;
