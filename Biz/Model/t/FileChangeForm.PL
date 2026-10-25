# Copyright (c) 2008-2026 bivio Software, Inc.  All Rights Reserved.
FormModel({
    setup_request => sub {
        my(undef, $params) = @_;
        my($p) = delete($params->[0]->{path_info});
        req()->put(path_info => $p);
        return;
    },
});
require(IO_File()->absolute_path('RealmFile.PL'));

