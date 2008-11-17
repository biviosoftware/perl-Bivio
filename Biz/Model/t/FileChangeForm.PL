# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
FormModel({
    setup_request => sub {
	my(undef, $params) = @_;
	my($p) = delete($params->[0]->{path_info});
	req()->put(path_info => $p);
	return;
    },
});
require 'RealmFile.PL';

