# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::ShellUtil;
Bivio::Test->unit([
    Bivio::ShellUtil => [
	group_args => [
	    [2, ['a', 'b', 'c', 'd']] => [[['a', 'b'], ['c', 'd']]],
	    [3, ['a', 'b', 'c', 'd']] => Bivio::DieCode->DIE,
	],
    ],
]);
