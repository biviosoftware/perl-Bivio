# Copyright (c) 2003-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::ServerRedirect;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_next {
    my(undef, $req) = @_;
    return {
	method => 'server_redirect',
	task_id => 'next',
	query => $req->get('query'),
    };
}

1;
