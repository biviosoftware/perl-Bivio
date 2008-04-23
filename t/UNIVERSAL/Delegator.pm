# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::UNIVERSAL::Delegator;
use strict;
use Bivio::Base 'Bivio::t::UNIVERSAL::DelegatorSuper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Bivio::t::UNIVERSAL::Delegate');

sub as_string {
    return shift->simple_package_name;
}

sub echo {
    return shift->delegate_method($_D, @_);
}

1;
