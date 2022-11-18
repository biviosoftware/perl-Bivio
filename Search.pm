# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search;
use strict;
use Bivio::Base 'Bivio.Delegator';

my($_CL) = b_use('IO.ClassLoader');

sub delegate_search_xapian {
    return
        unless $_CL->delegate_get_map_entry(__PACKAGE__) eq 'Bivio::Search::None';
    $_CL->delegate_replace_map_entry(__PACKAGE__, 'Bivio::Search::Xapian');
    return;
}

1;
