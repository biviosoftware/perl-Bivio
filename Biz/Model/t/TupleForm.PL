# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
FormModel({
    setup_request => sub {
	my($params) = shift->get('params');
	req()->put(
	    query => ref($params->[0]) || !defined($params->[0]) ? undef
		: {this => shift(@$params)},
	);
	return;
    },
});
1;
