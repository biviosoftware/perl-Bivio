# Copyright (c) 2013 IEEE SA, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::MotionBase;
use strict;
use Bivio::Base 'Biz.Action';
b_use('IO.ClassLoaderAUTOLOAD');


sub internal_redirect_if_closed {
    my($self, $req, $model) = @_;
    my($m) = $req->ureq($model);
    return
        if !$m || !$m->is_loaded;
    return 'closed_task'
        unless $m->is_open;
    return;
}

1;
