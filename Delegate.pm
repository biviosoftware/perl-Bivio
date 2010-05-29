# Copyright (c) 2001-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

# A base class which documents delegates.  A delegate does not have
# to subclass this module to be delegated by a Bivio.Delegator.

1;
