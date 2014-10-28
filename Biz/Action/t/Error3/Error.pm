# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::t::Error3::Error;
use strict;
use Bivio::Base 'Action';


sub internal_render_content {
    my(undef, $req) = @_;
    return $req->get('Error3');
}

1;
