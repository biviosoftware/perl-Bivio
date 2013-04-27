# Copyright (c) 2004-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Delegate::ECService;
use strict;
use Bivio::Base 'Bivio::Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    return [
        ANIMAL => [1],
    ];
}

1;
