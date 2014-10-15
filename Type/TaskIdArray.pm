# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TaskIdArray;
use strict;
use Bivio::Base 'Type.ArrayBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub UNDERLYING_TYPE {
    # store task id integer value, this way missing tasks will not die
    return b_use('Type.Integer');
}

1;
