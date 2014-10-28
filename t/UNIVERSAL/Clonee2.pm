# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::UNIVERSAL::Clonee2;
use strict;
use Bivio::Base 'Bivio::t::UNIVERSAL::Clonee';


sub clone_return_is_self {
    return 1;
}

1;
