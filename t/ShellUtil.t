# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::ShellUtil;
use Bivio::t::ShellUtil::T1;
# Needed for the usage_error (DIE below).  Take out for debugging
Bivio::IO::Alert->set_printer(sub {});
my($myarg_re) = qr/@{[join('.*', map("myarg=$_\n", 0..4))]}/s;
Bivio::Test->unit([
    'Bivio::ShellUtil' => [
	group_args => [
	    [2, ['a', 'b', 'c', 'd']] => [[['a', 'b'], ['c', 'd']]],
	    [3, ['a', 'b', 'c', 'd']] => Bivio::DieCode->DIE,
	],
	lock_action => [
	    [sub {
		 -d '/tmp/Bivio.Test.__ANON__.lockdir'
		     or die('wrong default name'),
	    }] => 1,
	    [sub {return}] => 1,
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
	    sub {
		# Test to see if we delete the lock when owner dies
		my($child) = fork;
		if ($child) {
		    waitpid($child, 0) == $child
			or die('wrong process died');
		    $? >> 8 == 0
			or die($?, ": bad exit code");
		    return [sub {return}, 'Bivio::ShellUtil::t::ShellUtil'];
	        }
		Bivio::ShellUtil->lock_action(sub {
		    kill('KILL', $$);
		}, 'Bivio::ShellUtil::t::ShellUtil',
		);
	        die("shouldn't get here!");
	    } => 1,
	    sub {
		my($case) = @_;
		$SIG{TERM} = sub {
		    # Gets called after the lock was removed
		    die('/tmp/ShellUtil.t.mylock.lockdir: exists')
			if -d '/tmp/ShellUtil.t.mylock.lockdir';
		    $case->put(got_sig_term => 1);
		};
		return [
		    sub {
			die('/tmp/ShellUtil.t.mylock.lockdir: not found')
			    unless -d '/tmp/ShellUtil.t.mylock.lockdir';
			kill('TERM', $$);
		    },
		    'ShellUtil.t.mylock',
		];
	    } => sub {
		my($case) = @_;
		$case->get('got_sig_term');
		return 1;
	    },
	],
    ],
    'Bivio::t::ShellUtil::T1' => [
	main => [
	    t1 => [],
	    # If these tests are failing, check ShellUtil/mylog.log
	    rd1 => $myarg_re,
	    ['rd1', 'rd2'] => $myarg_re,
	    ['rd1', 'rd3'] => sub {
		my($case, $actual) = @_;
		my($r) = $actual->[0];
		return $$r !~ /myarg/
		    && $$r =~ /@{[join('.*', map("Sent SIGTERM", 0..4))]}/s
		    ? 1 : 0;
	    },
	],
    ],
]);
