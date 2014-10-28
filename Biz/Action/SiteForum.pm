# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::SiteForum;
use strict;
use Bivio::Base 'Biz.Action';

my($_C) = b_use('FacadeComponent.Constant');

sub execute {
    my($proto, $req) = @_;
    $req->set_realm($_C->get_value('site_realm_id', $req));
    return 0;
}

1;
