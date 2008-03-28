# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::SiteForum;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = __PACKAGE__->use('FacadeComponent.Constant');

sub execute {
    my($proto, $req) = @_;
    $req->set_realm($_C->get_value('site_realm_id', $req));
    return 0;
}

1;
