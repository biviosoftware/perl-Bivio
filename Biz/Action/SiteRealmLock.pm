# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::SiteRealmLock;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_L) = b_use('Model.Lock');
my($_C) = b_use('FacadeComponent.Constant');

sub execute {
    my($proto, $req) = @_;
    $req->with_realm($_C->get_value('site_realm_name', $req), sub {
        $_L->execute_unless_acquired($req);
	return;
    });
    return 0;
}

1;
