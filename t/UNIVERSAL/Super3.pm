# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::UNIVERSAL::Super3;
use strict;
use Bivio::Base 'Bivio::t::UNIVERSAL::Super2';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_X) = b_use('Model.RealmOwner');

sub s1 {
    return shift->call_super_before(\@_, sub {
        die unless $_X;
        return ['Super3'];
    });
}

1;
