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
CORE::system("rm -rf $_tmp; mkdir $_tmp; cp -a LinuxConfig/* $_tmp; find $_tmp -name CVS -exec rm -rf {} \\; -prune");

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
			my($file, $exp) = @$v;
			my($data) = Bivio::IO::File->read("$_tmp/$file");
			if (ref($exp) eq 'CODE') {
			    next if &$exp($data);
			    print(STDERR "custom expect failed for $file\n");
			    return 0;
			}
			unless ($$data =~ /$exp/s) {
			    print(STDERR "$exp: not found in $file\n");
			    return 0;
			}
			if ($$data =~ /$exp.*$exp/s) {
			    print(STDERR "$exp: repeated in $file\n");
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
	    'serial_console', [] => [
		['etc/securetty', '/dev/ttyS0'],
		['etc/inittab', 'getty\s+ttyS0'],
		['etc/grub.conf', '#splash'],
		['etc/grub.conf', 'serial\s+--unit=0'],
		['etc/grub.conf', 'md2 console=ttyS0,38400'],
	    ],
	], [
            'disable_iptables_counters', [] => [
		['etc/rc.d/init.d/iptables', 'iptables-restore \&\&'],
	    ],
	], [
	    'add_sendmail_class_line', ['relay-domains', '10.1.1.1'] => [
		['etc/mail/relay-domains', '10.1.1.1'],
	    ],
	], [
	    'delete_sendmail_class_line', ['relay-domains', 'not-found'] => [
		# Assumes previous test is an add of 10.1.1.1
		['etc/mail/relay-domains', sub {${shift(@_)} =~ /10.1.1.1/}],
	    ],
	], [
	    'add_crontab_line', ['existing', '0 * * * * echo exists'] => [
		['var/spool/cron/existing', 'exists'],
	    ],
	], [
	    'add_crontab_line', ['root', '* 1 * * * OK1', '* * 2 * * OK2'] => [
		['var/spool/cron/root', 'OK1'],
		['var/spool/cron/root', 'OK2'],
	    ],
	], [
	    'delete_crontab_line', ['root', '* 1 * * * OK1', '* * 2 * * OK2'] => [
		# File should be empty
		['var/spool/cron/root', sub {length(${shift(@_)}) == 0}],
	    ],
	], [
	    'allow_any_sendmail_smtp', [99999] => [
		['etc/sendmail.cf', "\nO MaxMessageSize=99999\n"],
		['etc/sendmail.cf', "O DaemonPortOptions=Port=smtp, Name=MTA"],
	    ],
	], [
	    'sshd_param', ['PermitRootLogin', 'no', 'VerifyReverseMapping', 'yes'] => [
		['etc/ssh/sshd_config', "\nPermitRootLogin no(?!yes)"],
		['etc/ssh/sshd_config', "\nVerifyReverseMapping yes(?!no)"],
	    ],
	], [
	    'create_ssl_crt', [qw(US Colorado Boulder LinuxCrazyMan www.linuxcrazy.man)] => [
		['ssl.key/www.linuxcrazy.man.key', '--END RSA PRIVATE KEY'],
		['ssl.crt/www.linuxcrazy.man.crt', '--END CERTIFICATE--'],
		['ssl.csr/www.linuxcrazy.man.csr', '--END CERTIFICATE REQ'],
	    ],
	], [
	    'add_users_to_group', [qw(root root larry)] => [
		['etc/group', 'larry'],
	    ],
	], [
            'rhn_up2date_param', ['pkgSkipList', ''] => [
		['etc/sysconfig/rhn/up2date', 'pkgSkipList=;'],
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
