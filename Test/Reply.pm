# Copyright (c) 2002-2014 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Reply;
use strict;
use Bivio::Base 'Agent.Reply';


sub send_append_header {
    shift;
    return b_use('AgentHTTP.Reply')->send_append_header(@_);
}

sub set_cache_private {
    my($self) = @_;
    $self->put(cache_private => 1);
    return;
}

1;
