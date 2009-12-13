# Copyright (c) 2002-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::TableRowClass;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    HEADING => 1,
    DATA => 2,
    FOOTER => 3,
]);

1;
