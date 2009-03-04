# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Reply;
use strict;
use Bivio::Base 'Agent.Reply';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub set_cache_private {
    my($self) = @_;
    $self->put(cache_private => 1);
    return;
}

1;
