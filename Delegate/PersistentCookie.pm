# Copyright (c) 2001-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::PersistentCookie;
use strict;
use Bivio::Base 'Delegate.Cookie';

# B<DEPRECATED>. Use L<Bivio::Delegate::Cookie|"Bivio::Delegate::Cookie">.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub new {
    return shift->SUPER::new(@_);
}

1;
