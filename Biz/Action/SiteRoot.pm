# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::SiteRoot;
use strict;
use Bivio::Base 'Action.RealmFile';


sub execute_realm_file {
    my($self, $req) = @_;
    return 0
        unless my $realm = b_use('FacadeComponent.Text')->get_from_source($req)
            ->unsafe_get_value('site_root_realm');
    $req->set_realm($realm);
    return shift->execute_public(@_);
}

1;
