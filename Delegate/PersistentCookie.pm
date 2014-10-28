# Copyright (c) 2001-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::PersistentCookie;
use strict;
use Bivio::Base 'Delegate.Cookie';

# B<DEPRECATED>. Use L<Bivio::Delegate::Cookie|"Bivio::Delegate::Cookie">.


sub new {
    return shift->SUPER::new(@_);
}

1;
