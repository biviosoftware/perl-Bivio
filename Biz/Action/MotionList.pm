# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::MotionList;
use strict;
use Bivio::Base 'Action.MotionBase';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_redirect_if_closed {
    return shift->internal_redirect_if_closed(shift, 'Model.MotionList');
}

1;
