# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Constraint;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    NONE => [0],
    PRIMARY_KEY => [1],
    NOT_NULL => [2],
    NOT_NULL_UNIQUE => [3],
    NOT_ZERO_ENUM => [4],
    NOT_NULL_SET => [5],
]);

1;
