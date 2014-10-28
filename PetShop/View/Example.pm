# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::Example;
use strict;
use Bivio::Base 'View.Base';
b_use('UI.ViewLanguageAUTOLOAD');

Action_PingReply()->register_handler(__PACKAGE__);

sub eg1 {
    return shift->internal_body(Join([
	Simple('hello, world!'),
	ProgressBar(25, 100),
    ]));
}

sub handle_ping_reply {
    my($self, $req) = @_;
    return ($req->unsafe_get('query') || {})->{'View.Example'} ? 0 : 1;
}

1;
