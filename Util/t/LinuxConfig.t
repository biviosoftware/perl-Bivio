# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
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
CORE::system("rm -rf $_tmp; mkdir $_tmp; cp -pR LinuxConfig/* $_tmp; find $_tmp -name CVS -exec rm -rf {} \\; -prune");

my($_true) = grep(-x $_, qw(/bin/true /usr/bin/true));
my($user) = $ENV{USER};
my($group) = `groups` =~ /^(\S+)/;
die('could not find "true"')
    unless $_true;
sub _not_exists {\&_not_exists}
Bivio::Test->unit([
    'Bivio::Util::LinuxConfig' => [
	split_file => [
	    'LinuxConfig/split_file.txt' => [['c', 'a a', 'b']],
	],
	(map {
	    my($method, $args, $tests) = @$_;
	    ({
		method => $method,
		check_return => sub {
		    foreach my $v (@$tests) {
			my($file, $exp) = @$v;
			my($f) = "$_tmp/$file";
			if ($exp eq _not_exists()) {
			    return -e $f ? 0 : 1;
			}
			my($data) = Bivio::IO::File->read($f);
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
	    'replace_file', ['/hello', $user, $group, 0600, 'hello'] => [
		['hello' => 'hello'],
	    ],
	], [
	    'delete_file', ['/hello'] => [
		['hello' => _not_exists()],
	    ],
	], [
	    'postgres_base', [] => [
		['etc/rc.d/init.d/postgresql', qr{^# chkconfig: 345 84 16}m],
		['var/lib/pgsql/data/postgresql.conf', qr{^timezone = UTC}m],
		['var/lib/pgsql/data/pg_hba.conf', qr{^local\s+all\s+all\s+trust}m],
	    ],
        ], [
#		['etc/sysctl.conf', 'kernel/shmmax = 128000000'],
#		['var/lib/pgsql/data/postgresql.conf', 'timezone = UTC'],
#		['var/lib/pgsql/data/postgresql.conf', 'shared_buffers = '],
#		['var/lib/pgsql/data/postgresql.conf', 'timezone = UTC'],
#	    ],
#	], [
	    'serial_console', [] => [
		['etc/securetty', '(?<!/dev/)ttyS0'],
		['etc/inittab', 'getty\s+ttyS0'],
		['etc/grub.conf', '#splash'],
		['etc/grub.conf', 'serial\s+--unit=0'],
		['etc/grub.conf', 'md2 console=ttyS0,38400'],
	    ],
	], [
            'ifcfg_static', ['eth0', '
any.host
other.host
', '1.2.3.4/28', '99'] => [
		['etc/sysconfig/network', "HOSTNAME=any.host\n"],
		['etc/sysconfig/network-scripts/ifcfg-eth0',
		    "NETMASK=255.255.255.240\nGATEWAY=1.2.3.99\n"],
		['etc/hosts', "1.2.3.4\tany.host other.host\n"],
		['etc/hosts', "127.0.0.1\tlocalhost.localdomain localhost\n"],
		['etc/hosts', sub {${shift(@_)} !~ /99.*any.host/im}],
	    ],
	], [
            'ifcfg_static', ['eth0', '
any.host
other.host
', '1.2.3.4/28'] => [
		['etc/sysconfig/network', "HOSTNAME=any.host\n"],
		['etc/sysconfig/network-scripts/ifcfg-eth0',
		    "NETMASK=255.255.255.240\n"],
		['etc/hosts', "1.2.3.4\tany.host other.host\n"],
		['etc/hosts', "127.0.0.1\tlocalhost.localdomain localhost\n"],
		['etc/hosts', sub {${shift(@_)} !~ /99.*any.host/im}],
	    ],
	], [
            'resolv_conf', [qw(my.dom 1.2.3.4 1.2.3.5)] => [
		['etc/resolv.conf', "domain my.dom\n"],
		['etc/resolv.conf', "nameserver 1.2.3.4\nnameserver 1.2.3.5\n"],
	    ],
	], [
	    'serial_console', [9600] => [
		['etc/securetty', '(?<!/dev/)ttyS0'],
		['etc/inittab', 'getty\s+ttyS0'],
		['etc/grub.conf', '#splash'],
		['etc/grub.conf', 'serial\s+--unit=0'],
		['etc/grub.conf', 'md2 console=ttyS0,9600'],
	    ],
	], [
            'disable_iptables_counters', [] => [
		['etc/rc.d/init.d/iptables', 'iptables-restore \&\&'],
	    ],
	], [
	    'add_bashrc_d', [] => [
		['etc/bashrc', '/etc/bashrc.d/'],
	    ],
	], [
	    'add_aliases', ['a: b:c', 'd:e', 'i::include:/foo'] => [
		['etc/aliases', "a:\tb:c\n"],
		['etc/aliases', "d:\te\n"],
		['etc/aliases', "i:\t:include:/foo\n"],
	    ],
	], [
	    'delete_aliases', ['d'] => [
		['etc/aliases', sub {${shift(@_)} !~ /\nd:/}],
	    ],
	], [
	    'add_virtusers', ['a: b', 'e:f'] => [
		['etc/mail/virtusertable', "a\tb\n"],
		['etc/mail/virtusertable', "e\tf\n"],
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
		['etc/sendmail.cf', "O DoubleBounceAddress=devnull"],
	    ],
	], [
	    'add_sendmail_http_agent', ['localhost:80/my_uri', $_true] => [
		['etc/sendmail.cf', 'localhost:80/my_uri'],
 		['etc/sendmail.cf', '\$#bsendmailhttp.*\$#bsendmailhttp'],
 		['etc/sendmail.cf', 'Mbsendmailhttp'],
 		['etc/sendmail.cf', sub {${shift(@_)} =~ m{R=EnvToL}}],
 		['etc/sendmail.cf', 'A=true'],
 		['etc/sendmail.cf', "names\nFP/etc/mail"],
 		['etc/sendmail.cf', '\$=w.*bsendmailhttp \$@ \$2 \$: \$1'],
	    ],
	    'add_sendmail_http_agent', ['localhost:8000/my_uri', $_true] => [
		['etc/sendmail.cf', 'localhost:8000/my_uri'],
 		['etc/sendmail.cf', 'A=true'],
	    ],
	], [
	    'sshd_param', ['PermitRootLogin', 'no', 'VerifyReverseMapping', 'yes'] => [
		['etc/ssh/sshd_config', "\nPermitRootLogin no(?!yes)"],
		['etc/ssh/sshd_config', "\nVerifyReverseMapping yes(?!no)"],
	    ],
	], [
	    'add_users_to_group', [qw(root root larry)] => [
		['etc/group', 'larry'],
	    ],
	], [
	    'add_users_to_group', [qw(tty tommy)] => [
		['etc/group', 'tommy'],
	    ],
	], [
            'rhn_up2date_param', ['pkgSkipList', ''] => [
		['etc/sysconfig/rhn/up2date', 'pkgSkipList='],
	    ],
	], [
            'rhn_up2date_param', ['pkgSkipList', 'apache*;'] => [
		['etc/sysconfig/rhn/up2date', 'pkgSkipList=apache\*;'],
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
