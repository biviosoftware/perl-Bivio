# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::NullBoolean;
use strict;
use Bivio::Base 'Type.Boolean';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub from_literal {
    my($self, $value) = @_;
    return undef
	unless defined($value);
    return shift->SUPER::from_literal(@_);
}

1;
