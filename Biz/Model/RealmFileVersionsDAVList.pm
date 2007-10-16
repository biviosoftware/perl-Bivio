# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileVersionsDAVList;
use strict;
use Bivio::Base 'Model.RealmFileBaseDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LIST_MODEL {
    return 'RealmFileVersionsList';
}

1;
