# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
my($_tmp);
BEGIN {
    use Bivio::IO::Config;
    $_tmp = "$ENV{PWD}/LinuxConfig.tmp";
    Bivio::IO::Config->introduce_values({
	'Bivio::Util::LinuxConfig' => {
	    root_prefix => "$ENV{PWD}/LinuxConfig.tmp",
	},
    });
}
use Bivio::Test;
use Bivio::Util::LinuxConfig;
CORE::system("rm -rf $_tmp; mkdir $_tmp; cp -a LinuxConfig/* $_tmp");

Bivio::Test->unit([
    Bivio::Util::LinuxConfig => [
	{
	    method => 'make_serial_console',
	    result_ok => sub {
		my($object, $method, $params, $expect, $actual) = @_;
		return 0 unless ref($actual) eq 'ARRAY';
		foreach my $v (
		    ['securetty', '/dev/ttyS0'],
		    ['inittab', 'getty\s+ttyS0'],
		    ['grub.conf', '#splash'],
		    ['grub.conf', 'serial\s+--unit=0'],
		    ['grub.conf', 'md2 console=ttyS0,38400'],
		    ) {
		    my($data) = Bivio::IO::File->read("$_tmp/etc/$v->[0]");
		    unless ($$data =~ /$v->[1]/s) {
			print(STDERR "$v->[1]: not found in $v->[0]\n");
			return 0;
		    }
		    if ($$data =~ /$v->[1].*$v->[1]/s) {
			print(STDERR "$v->[1]: repeated in $v->[0]\n");
			return 0;
		    }
		}
		return 1;
	    },
	} => [
	    [] => [],
	    [] => [],
        ],
    ],
]);
