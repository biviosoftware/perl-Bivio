# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Util::LinuxConfig;
my($_tmp) = "$ENV{PWD}/LinuxConfig.tmp/";
Bivio::IO::Config->introduce_values({
    'Bivio::Util::LinuxConfig' => {
	root_prefix => $_tmp,
    },
});
CORE::system("rm -rf $_tmp; mkdir $_tmp; cp -a LinuxConfig/* $_tmp");

Bivio::Test->unit([
    Bivio::Util::LinuxConfig => [
	(map {
	    my($method, $args, $tests) = @$_;
	    ({
		method => $method,
		result_ok => sub {
		    my($object, $method, $params, $expect, $actual) = @_;
		    return 0 unless ref($actual) eq 'ARRAY';
		    foreach my $v (@$tests) {
			my($data) = Bivio::IO::File->read("$_tmp/$v->[0]");
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
		[@$args] => [],
		[@$args] => [],
	    ]);
	} [
	    serial_console => [], [
		['etc/securetty', '/dev/ttyS0'],
		['etc/inittab', 'getty\s+ttyS0'],
		['etc/grub.conf', '#splash'],
		['etc/grub.conf', 'serial\s+--unit=0'],
		['etc/grub.conf', 'md2 console=ttyS0,38400'],
	    ],
	], [
	    relay_domains => ['10.1.1.1'], [
		['etc/mail/relay-domains', '10.1.1.1'],
	    ],
	], [
	    sshd_param =>
	    ['PermitRootLogin', 'no', 'VerifyReverseMapping', 'yes'], [
		['etc/ssh/sshd_config', "\nPermitRootLogin no"],
		['etc/ssh/sshd_config', "\nVerifyReverseMapping yes"],
	    ],
	], [
	    create_ssl_crt =>
		[qw(US Colorado Boulder LinuxCrazyMan www.linuxcrazy.man)], [
		['ssl.key/www.linuxcrazy.man.key', '--END RSA PRIVATE KEY'],
		['ssl.crt/www.linuxcrazy.man.crt', '--END CERTIFICATE--'],
		['ssl.csr/www.linuxcrazy.man.csr', '--END CERTIFICATE REQ'],
	    ],
	]),
	rename_rpmnew => [
	    ['/etc/logrotate.conf.rpmnew'] => [
		"Updated: $_tmp/etc/logrotate.conf\n"],
	    ['/etc/logrotate.conf.rpmnew'] => [''],
        ],
    ],
    Bivio::Util::LinuxConfig->new(['-noexecute']) => [
	add_user => [
	    ['root:0'] => [''],
	    ['notuuu'] => [
		"Would have executed: groupadd 'notuuu' 2>&1\n"
		. "Would have executed: useradd -m -g 'notuuu' 'notuuu' 2>&1\n"],
	    ['notuuu', '', '/bin/false'] => [
		"Would have executed: groupadd 'notuuu' 2>&1\n"
		. "Would have executed: useradd -m -g 'notuuu' -s '/bin/false' 'notuuu' 2>&1\n"],
	    ['notuuu:99'] => [
		"Would have executed: groupadd -g '99' 'notuuu' 2>&1\n"
		. "Would have executed: useradd -m -u '99' -g 'notuuu' 'notuuu' 2>&1\n"],
	    ['notuuu:99', 'notggg'] => [
		"Would have executed: groupadd 'notggg' 2>&1\n"
		. "Would have executed: useradd -m -u '99' -g 'notggg' 'notuuu' 2>&1\n"],
	    ['notuuu:99', 'notggg:777'] => [
		"Would have executed: groupadd -g '777' 'notggg' 2>&1\n"
		. "Would have executed: useradd -m -u '99' -g 'notggg' 'notuuu' 2>&1\n"],
        ],
    ],
]);
