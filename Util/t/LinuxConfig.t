# Copyright (c) 2002-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Util::VC;
use Bivio::Util::LinuxConfig;
my($_tmp) = "$ENV{PWD}/LinuxConfig.tmp/";
Bivio::IO::Config->introduce_values({
    'Bivio::Util::LinuxConfig' => {
	root_prefix => $_tmp,
    },
});
my($vc_find) = Bivio::Util::VC->CONTROL_DIR_FIND_PREDICATE;
CORE::system("rm -rf $_tmp; mkdir $_tmp; cp -pR LinuxConfig/* $_tmp; find $_tmp $vc_find -exec rm -rf {} \\; -prune");

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
			    next
				if $exp->($data);
			    print(STDERR "custom expect failed for $file\n");
			    return 0;
			}
			if (!ref($exp) && $exp =~ s/^!//) {
			    if ($$data =~ /$exp/s) {
				print(STDERR "$exp: found in $file\n");
				return 0;
			    }
			}
			else {
			    unless ($$data =~ /$exp/s) {
				print(STDERR "$exp: not found in $file\n");
				return 0;
			    }
			    if ($$data =~ /$exp.*$exp/s) {
				print(STDERR "$exp: repeated in $file\n");
				return 0;
			    }
			}
		    }
		    return 1;
		},
	    } => [
		[@$args] => [],
		[@$args] => [],
	    ]);
	} [
	    'postgres_base', [] => [
		['etc/rc.d/init.d/postgresql', qr{^# chkconfig: 345 84 16}m],
		['var/lib/pgsql/data/postgresql.conf', qr{^timezone = UTC}m],
		['var/lib/pgsql/data/pg_hba.conf', qr{^local\s+all\s+all\s+trust}m],
		['var/lib/pgsql/data/pg_hba.conf', qr{host.*127.0..*password}],
		['var/lib/pgsql/data/pg_hba.conf', qr{128.*password}],
	    ],
	], [
	    'serial_console', [] => [
		['etc/securetty', '(?<!/dev/)ttyS0'],
		['boot/grub/menu.lst', '#splash'],
		['boot/grub/menu.lst', 'serial\s+--unit=0'],
		['boot/grub/menu.lst', 'NO_DM console=ttyS0,57600'],
	    ],
	], [
	    'serial_console', [9600] => [
		['etc/securetty', '(?<!/dev/)ttyS0'],
		['boot/grub/menu.lst', '#splash'],
		['boot/grub/menu.lst', '#hidden'],
		['boot/grub/menu.lst', 'serial\s+--unit=0'],
		['boot/grub/menu.lst', 'NO_DM console=ttyS0,9600'],
		['boot/grub/menu.lst', '!rhgb'],
		['boot/grub/menu.lst', '!quiet'],
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
	    'add_crontab_line', ['existing', '0 * * * * echo exists'] => [
		['var/spool/cron/existing', 'exists'],
	    ],
	], [
	    'add_crontab_line', ['root', '* 1 * * * OK1', '* * 2 * * OK2'] => [
		['var/spool/cron/root', 'OK1'],
		['var/spool/cron/root', 'OK2'],
	    ],
	], [
	    'sshd_param', ['PermitRootLogin', 'no', 'VerifyReverseMapping', 'yes'] => [
		['etc/ssh/sshd_config', "\nPermitRootLogin no(?!yes)"],
		['etc/ssh/sshd_config', "\nVerifyReverseMapping yes(?!no)"],
	    ],
	], [
	    'sshd_param', ['PermitRootLogin', 'without-password'] => [
		['etc/ssh/sshd_config', "\nPermitRootLogin without-password"],
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
            'sh_param', [qw(etc/any.conf commented 1 uncommented 2)] => [
		['etc/any.conf', "commented='1'"],
		['etc/any.conf', "uncommented='2'"],
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
