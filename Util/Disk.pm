# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Disk;
use strict;
use base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
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
	} split(/\n/, ${_data($self, $test_data, "df $flag", '')})),
    }
	[capacity => '-k'],
	[iuse => '-i'],
    ));
}

sub check_raid {
    my($self, $test_data) = @_;
    my($d);
    my($err) = [];
#TODO: I don't think the current afa0 code does the right thing.
# perhaps disk status does it?
#
# AFA0> disk show space
# Executing: disk show space
#
# Scsi B:ID:L Usage      Size
# ----------- ---------- -------------
#   0:00:0     Container 64.0KB:33.8GB
#   0:00:0     Free      33.8GB:59.0KB
#   0:01:0     Rebuild   64.0KB:33.8GB
#   0:01:0     Free      33.8GB:59.0KB

    push(@$err, grep(/md\d+.+_/s, split(/\n\s*\n/, $$d)))
	if $d = _data($self, $test_data, '/proc/mdstat');
    foreach my $n (0, 1, 2, 3) {
	push(@$err, grep(s/^\s*// && m{^/dev/rd/c$n} && !/Online/, split(/\n/, $$d)))
	    if $d = _data($self, $test_data, "/proc/rd/c$n/current_status");
    }
    # afacli needs a valid curses terminal
    local($ENV{TERM}) = 'xterm';
    push(@$err, grep(
	/\d+\s+Disk/ && !/Initialized/ || /Rebuild|RUN/,
	map({
	    $_ =~ s/\033(?:\[[\d;]+[a-z]|\d+)//ig;
	    $_;
	} split(/\n/, $$d))
    )) if $test_data || -x '/usr/sbin/afacli'
	and $d = _data($self, $test_data, '/usr/sbin/afacli', <<'EOF');
open afa0
disk list
exit
EOF
    return join('', map("DRIVE FAILURE: $_\n", @$err));
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub _data {
    my($self, $test_data, $file, $input) = @_;
    return $test_data ? ($test_data->{$file} ? \$test_data->{$file} : undef)
	: defined($input) ? $self->piped_exec($file, $input)
	: -f $file ? Bivio::IO::File->read($file)
	: undef;
}

1;
