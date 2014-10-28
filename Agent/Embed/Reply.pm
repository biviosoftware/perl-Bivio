# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::Embed::Reply;
use strict;
use Bivio::Base 'Agent.Reply';


sub set_output {
    my($self, $value) = @_;
    $self->get('parent_request')->put(ref($self) => $self);
    return shift->SUPER::set_output(@_);
}

1;
