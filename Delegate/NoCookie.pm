# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::NoCookie;
use strict;
use Bivio::Base 'Bivio::Collection::Attributes';

# C<Bivio::Delegate::NoCookie> is a placeholder for
# L<Bivio::Agent::HTTP::Cookie|Bivio::Agent::HTTP::Cookie>.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub assert_is_ok {
    # (self, Agent.Request) : boolean
    # This cookie is always OK.
    return 1;
}

sub header_out {
    # (self, Agent.Request, Apache.Request) : boolean
    # Does nothing.
    return;
}

1;
