# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::SuperAUTOLOAD;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);

sub import {
    my($pkg) = caller();
    my($sub, $super) = $pkg->super_for_method('AUTOLOAD');
    no strict qw(refs);
    *{$pkg . '::AUTOLOAD'} = sub {
	${*{*{$super . '::AUTOLOAD'}}{SCALAR}} = $AUTOLOAD;
	return $sub->(@_);
    };
    return;
}

1;
