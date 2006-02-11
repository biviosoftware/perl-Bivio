# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileTreeList;
use strict;
use base 'Bivio::Biz::Model::TreeBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LIST_FORM_CLASS {
    return 'RealmFileTreeListForm';
}

1;
