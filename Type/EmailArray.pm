# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::EmailArray;
use strict;
use Bivio::Base 'Type.StringArray';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_E) = __PACKAGE__->use('Type.Email');

sub UNDERLYING_TYPE {
    return $_E;
}

sub from_literal_validator {
    my($proto, $value) = @_;
#TODO: Full address parsing with coments
    return $_E->from_literal($value);
}

sub get_width {
    return 1000;
}

1;
