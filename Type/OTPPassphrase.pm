# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::OTP::Type::OTPPassphrase;
use strict;
use Bivio::Base 'Type.String';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_width {
    # OPIE allows this length
    return 127;
}

1;
