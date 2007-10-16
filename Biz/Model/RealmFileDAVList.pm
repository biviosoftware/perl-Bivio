# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileDAVList;
use strict;
use Bivio::Base 'Model.RealmFileBaseDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LIST_MODEL {
    return 'RealmFileList';
}

1;
