# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::WikiBaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub return_with_validate {
    my($self) = shift;
    return b_use('Action.WikiValidator')->return_with_validate(@_);
}

1;
