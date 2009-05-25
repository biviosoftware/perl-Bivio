# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::BlogRecentList;
use strict;
use Bivio::Base 'Model.BlogList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub PAGE_SIZE {
    return 10;
}

sub execute_load_all {
    my($proto, $req) = @_;
    $proto->new($req)->load_page;
    return;
}

1;
