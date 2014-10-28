# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Disk;
use strict;
use base 'Bivio::ShellUtil';

Bivio::IO::Config->register(my $_CFG = {
    check_use_capacity => [
	[qr{.} => 90],
    ],
    check_use_iuse => [
	[qr{.} => 90],
    ],
});

sub USAGE {
    return <<'EOF';
usage: b-disk [options] command [args..]
commands
  check_use -- check disk usage
  check_raid -- check raid disks
EOF
}

sub check_use {
    my($self, $test_data) = @_;
    return join('', map({
	my($which, $flag) = @$_;
	my($cfg) = $_CFG->{"check_use_$which"};
	map({
	    my($dev, $cap, $mount) = (split(' ', $_))[0, 4, 5];
	    chop($cap);
	    $dev =~ m{^/dev} ? map({
		my($re, $max) = @$_;
		my($r);
		if ($dev && $mount =~ $re && $cap > $max) {
		    $r = "PARTITION FULL: $mount ($dev) $which at $cap\% (max $max\%)\n";
		    $dev = '';
	        }
		$r ? $r : ();
	    } @$cfg) : ();
	} split(/\n/, ${_data($self, $test_data, "/bin/df --portability $flag", '')})),
    }
	[capacity => '-k'],
	[iuse => '-i'],
    ));
}

sub check_raid {
    my($self, $test_data) = @_;
    my($d);
    my($err) = [];
    # afacli needs a valid curses terminal
    local($ENV{TERM}) = 'xterm';
    foreach my $x (
	['/proc/mdstat', \&_check_mdstat],
	['/usr/sbin/afacli', \&_check_afacli, <<'EOF'],
open afa0
disk list
exit
EOF
	['/sbin/tw_cli /c0 show unitstatus', \&_check_tw_cli, ''],
	['/sbin/zpool status -x', \&_check_zpool, ''],
    ) {
	my($file, $op, $in) = @$x;
	next
	    unless my $d = _data($self, $test_data, $file, $in);
	push(@$err, $op->($d))
    }
    return join('', map("DRIVE FAILURE: $_\n", @$err));
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub _check_afacli {
    my($d) = @_;
    return grep(
	/\d+\s+Disk/ && !/Initialized/ || /Rebuild|RUN/,
	map(
	    {
		$_ =~ s/\033(?:\[[\d;]+[a-z]|\d+)//ig;
		$_;
	    }
	    split(/\n/, $$d),
	),
    );
}

sub _check_mdstat {
    my($d) = @_;
    $$d =~ s/read_ahead \d+ sectors//g;
    return grep(
	/[_F]/,
	split(/\n\s*\n/, $$d),
    );
}

sub _check_tw_cli {
    my($d) = @_;
    return grep(
	/^u\d+\s/s && !/^u\d+\s+\S+\s+OK/s,
	split(/\n/, $$d),
    );
}

sub _check_zpool {
    my($d) = @_;
    return grep(
	/pool:/ && !/state: ONLINE/,
	split(/(?=pool\:)/, $$d),
    );
}

sub _data {
    my($self, $test_data, $file, $input) = @_;
    return $test_data
	? $test_data->{$file}
	? \$test_data->{$file}
        : undef
	: defined($input)
	? -x ($file =~ m{^(\S+)})[0]
	? $self->piped_exec($file, $input)
	: undef
	: -f $file
	? Bivio::IO::File->read($file)
	: undef;
}

1;
