# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::Example;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
b_use('Action.PingReply')->register_handler(__PACKAGE__);

sub eg1 {
    return shift->internal_body(Simple('hello, world!'));
}

sub handle_ping_reply {
    my($self, $req) = @_;
    return ($req->unsafe_get('query') || {})->{'View.Example'} ? 0 : 1;
}

1;
