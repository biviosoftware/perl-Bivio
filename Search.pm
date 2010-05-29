# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search;
use strict;
use Bivio::Base 'Bivio.Delegator';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DELEGATE);

sub internal_delegate_package {
    return $_DELEGATE
	||= b_use(
	    'Search',
	    b_use('Agent.TaskId')->unsafe_from_name('JOB_XAPIAN_COMMIT')
		? 'Xapian' : 'None',
	);
}

1;
