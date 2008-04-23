# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::UNIVERSAL::DelegateSuper;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_) = __PACKAGE__->use('Bivio::t::UNIVERSAL::Delegate');

sub simple_package_name {
    return shift->delegate_method($_D, @_);
}

1;
