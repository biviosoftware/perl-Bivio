# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Util::Release;
Bivio::Test->unit([
    Bivio::Util::Release => [
	find_files => [
	    ['Release/files.t1', 'Release/root.t1', '%config'] => [<<'EOF'],
%config /etc/t1
EOF
	],
    ],
]);
