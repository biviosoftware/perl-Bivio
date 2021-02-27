# Copyright (c) 2021 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Action::t::Mock::Reply;
use strict;
use Bivio::Base 'Collection.Attributes';
b_use('IO.ClassLoaderAUTOLOAD');

sub header_in {
    return shift->get(@_);
}

1;
