# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::SiteRoot;
use strict;
use Bivio::Base 'Bivio::Biz::Action::RealmFile';
use Bivio::UI::Text;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_realm_file {
    my($self, $req) = @_;
    return 0
	unless my $realm = Bivio::UI::Text->get_from_source($req)
	    ->unsafe_get_value('site_root_realm');
    $req->set_realm($realm);
    return shift->execute_public(@_);
}

1;
