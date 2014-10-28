# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Motion;
use strict;
use Bivio::Base 'Action.MotionBase';
b_use('IO.ClassLoaderAUTOLOAD');


sub execute_redirect_if_closed {
    return shift->internal_redirect_if_closed(shift, 'Model.Motion');
}

1;
