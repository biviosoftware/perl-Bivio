# Copyright (c) 2004-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Delegate::Location;
use strict;
use Bivio::Base 'Type.EnumDelegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
	PRIMARY => [1],
        BILL_TO => [2, 'Bill To Address'],
        SHIP_TO => [3, 'Shipping Address'],
    ];
}

1;
