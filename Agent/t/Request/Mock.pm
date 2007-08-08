# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::t::Request::Mock;
use strict;
use Bivio::Base 'Bivio::Agent::Request';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub client_redirect {
    Bivio::Die->throw('CLIENT_REDIRECT_TASK');
}

sub new {
    return shift->SUPER::internal_new({});
}

sub server_redirect {
    Bivio::Die->throw('SERVER_REDIRECT_TASK');
}

1;
