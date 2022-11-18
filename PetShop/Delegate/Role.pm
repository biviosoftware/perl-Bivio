# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Delegate::Role;
use strict;
use Bivio::Base 'Delegate';


sub get_delegate_info {
    return [
        @{shift->SUPER::get_delegate_info(@_)},
        TEST_ROLE1 => [21],
        TEST_ROLE2 => [22],
    ];
}

1;
