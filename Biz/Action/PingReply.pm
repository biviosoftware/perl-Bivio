# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::PingReply;
use strict;
use Bivio::Base 'Action.EmptyReply';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

sub execute {
    return shift->SUPER::execute(shift, undef, $_DT->now_as_file_name);
}

1;
