# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TupleMoniker;
use strict;
use Bivio::Base 'Type.TupleLabel';


sub REGEX {
    # IMPLICIT COUPLING: with SQL.Support->split_qualified_prefix
    return qr{[a-z]\w+};
}

1;
