# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::WantReplyTo;
use strict;
use Bivio::Base 'Type.Boolean';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = b_use('Model.Forum');

sub is_set_for_realm {
    my($self, $req) = @_;
    return $req->get_nested(qw(auth_realm type))->eq_forum
 	&& $_F->new($req)->load->get('want_reply_to');
}

1;
