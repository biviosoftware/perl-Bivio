# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::NoECService;
use strict;
use Bivio::Base 'Bivio::Delegate';

# C<Bivio::Delegate::NoECService>

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    # (self) : array_ref
    # Returns an enumerated type with one value, UNKNOWN.
    return [
	UNKNOWN => [0],
    ];
}

1;
