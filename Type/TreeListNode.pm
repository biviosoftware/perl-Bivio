# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TreeListNode;
use strict;
use base 'Bivio::Type::Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->compile_with_numbers([qw(
    LEAF_NODE
    NODE_COLLAPSED
    NODE_EXPANDED
    LOCKED_LEAF_NODE
    NODE_EMPTY
)]);

1;
