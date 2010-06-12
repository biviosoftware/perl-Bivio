# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::BoardRealmMail;
use strict;
use Bivio::Base 'Action.RealmMailBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
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

1;
