# Copyright (c) 2010-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::BoardRealmMail;
use strict;
use Bivio::Base 'Action.RealmMailBase';

my($_RM) = b_use('Model.RealmMail');

sub TASK_URI {
    return 'board';
}

sub execute_receive {
    my($self, $req, $rfc822) = @_;
    $_RM->new($req)->create_from_rfc822(
	$rfc822
	    || $req->get('Model.MailReceiveDispatchForm')
	    ->get('message')->{content},
    );
    return;
}

sub want_reply_to {
    return 0;
}

1;
