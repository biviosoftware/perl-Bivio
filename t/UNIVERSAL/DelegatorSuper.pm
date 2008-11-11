# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::UNIVERSAL::DelegatorSuper;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Bivio::t::UNIVERSAL::Delegate');

sub as_string {
    return shift->delegate_method($_D, @_);
}

sub echo {
    return shift->delegate_method($_D, @_);
}

1;
