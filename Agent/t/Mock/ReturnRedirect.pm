# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::t::Mock::ReturnRedirect;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    return 'REDIRECT_TEST_2';
}

1;
