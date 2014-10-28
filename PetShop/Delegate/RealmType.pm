# Copyright (c) 2005-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Delegate::RealmType;
use strict;
use Bivio::Base 'Delegate';


sub get_delegate_info {
    return [
        @{shift->SUPER::get_delegate_info},
        ORDER => [20],
    ];
}

1;
