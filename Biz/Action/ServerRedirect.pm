# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::ServerRedirect;
use strict;
use Bivio::Base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_next {
    return {
	method => 'server_redirect',
	task_id => 'next',
    };
}

1;
