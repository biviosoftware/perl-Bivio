# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::ShellUtil;
use Bivio::t::ShellUtil::T1;
# Needed for the usage_error (DIE below).  Take out for debugging
Bivio::IO::Alert->set_printer(sub {});
Bivio::Test->unit([
    'Bivio::ShellUtil' => [
	group_args => [
	    [2, ['a', 'b', 'c', 'd']] => [[['a', 'b'], ['c', 'd']]],
	    [3, ['a', 'b', 'c', 'd']] => Bivio::DieCode->DIE,
	],
	lock_action => [
	    [sub {return}, 'Bivio::ShellUtil::t::ShellUtil'] => 1,
	    [sub {die('bad')}, 'Bivio::ShellUtil::t::ShellUtil']
	        => Bivio::DieCode->DIE,
	    [sub {return}, 'Bivio::ShellUtil::t::ShellUtil'] => 1,
	    [sub {
		 Bivio::ShellUtil->lock_action(sub {
		     die("shouldn't get here");
		 }, 'Bivio::ShellUtil::t::ShellUtil'
		 ) and die('lock should not be obtained');
		 return;
	    }, 'Bivio::ShellUtil::t::ShellUtil'] => 1,
	],
    ],
    'Bivio::t::ShellUtil::T1' => [
	main => [
	    t1 => [],
	],
    ],
]);
