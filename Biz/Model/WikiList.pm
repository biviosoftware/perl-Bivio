# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::WikiList;
use strict;
use Bivio::Base 'Model.RealmFileList';

my($_WN) = b_use('Type.WikiName');

sub internal_pre_load {
    return '';
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $self->prepare_statement_for_access_mode($stmt, $_WN);
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
