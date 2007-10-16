# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileList;
use strict;
use Bivio::Base 'Model.RealmFileBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_pre_load {
    return shift->SUPER::internal_pre_load(@_)
	. q{ AND POSITION(';' IN path_lc) = 0};
}

1;
