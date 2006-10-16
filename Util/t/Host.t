# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Util::Host;

Bivio::Test->unit([
    Bivio::Util::Host->new(['-noexecute']) => [
	exec_if => [
	    ['localhost', 'OK'] => ["Would have executed: OK\n"],
	    ['no-such-host', 'FAILED'] => Bivio::DieCode->DIE,
	    ['www.yahoo.com', 'FAILED'] => ["Not this host\n"],
	],
    ],
]);
