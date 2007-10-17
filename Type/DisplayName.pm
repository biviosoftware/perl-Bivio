# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DisplayName;
use strict;
use Bivio::Base 'Type.Line';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_width {
    return 500;
}

sub to_camel_case {
    my(undef, $value) = @_;
    return !$value ? $value
	: join(' ', map(ucfirst($_), split(/[\W_]+/, $value)));
}

1;
