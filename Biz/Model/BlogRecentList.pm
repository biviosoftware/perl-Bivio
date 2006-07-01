# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::BlogRecentList;
use strict;
use base 'Bivio::Biz::Model::BlogList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_load_all {
    my($proto, $req) = @_;
    $proto->new($req)->load_page;
    return;
}

1;
