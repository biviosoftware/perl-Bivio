# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::LinuxConfig;
use strict;
$Bivio::Util::LinuxConfig::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::LinuxConfig::VERSION;

=head1 NAME

Bivio::Util::LinuxConfig - manipulate Linux configuration files

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::LinuxConfig;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::LinuxConfig::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::LinuxConfig> manipulates various config files in Linux.
Syntax is rigid, but the commands die if anything is out of the
ordinary.

TODO:
   sendmail_cf b-sendmail-http
   see files in LinuxConfig dir

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns usage.

=cut

sub USAGE {
    return <<'EOF';
usage: b-linux-config [options] command [args...]
commands:
    allow_any_sendmail_smtp [max_message_size] -- open up sendmail while making more secure
    add_crontab_line user entry... -- add entries to crontab
    add_group group[:gid] -- add a group
    add_sendmail_class_line filename line ... -- add values trusted-users, relay-domains, etc.
    add_sendmail_http_agent uri -- configures sendmail to pass mail b-sendmail-http
    add_user user[:uid] [group[:gid] [shell]] -- create a user
    add_users_to_group group user... -- add users to group
    append_lines file owner group perms line ... -- appends lines to a file if they don't already exist
    create_ssl_crt iso_country state city organization hostname -- create ssl certificate
    delete_crontab_line user entry... -- delete entries from crontab
    delete_sendmail_class_line filename line ... -- delete values trusted-users, relay-domains, etc.
    disable_iptables_counters -- disables saving counters in iptables state file
    disable_service service... -- calls chkconfig and stops services
    enable_service service ... -- enables service
    rename_rpmnew all | file.rpmnew... -- renames rpmnew to orig and rpmsaves orig
    rhn_up2date_param param value ... -- update params in up2date config
    serial_console [speed] -- configure grub and init for serial port console
    sshd_param param value ... -- add or delete a parameter from sshd config
EOF
}

#=IMPORTS
use Bivio::IO::Config;

#=VARIABLES
Bivio::IO::Config->register(my $_CFG = {
    root_prefix => '',
});

=head1 METHODS

=cut

=for html <a name="add_bashrc_d"></a>

=head2 add_bashrc_d() : string

Updates /etc/bashrc to search /etc/bashrc.d.

=cut

sub add_bashrc_d {
    my($self) = @_;
    return _mkdir($self, '/etc/bashrc.d', 0755)
	. _edit($self, '/etc/bashrc', ['$', <<'EOF', qr#/etc/bashrc.d/#]);

# Load local bashrcs
for i in /etc/bashrc.d/*.sh ; do
    if [ -r $i ]; then
        . $i
    fi
done

unset i
EOF
}

=for html <a name="add_crontab_line"></a>

=head2 add_crontab_line(string user, string entry, ...) : string

Add I<entry>s to this I<user>'s crontab.

=cut

sub add_crontab_line {
    my($self, $user, @entry) = @_;
    return $self->append_lines("/var/spool/cron/$user", 'root', $user, 0600,
	@entry);
}

=for html <a name="add_group"></a>

=head2 add_group(string group) : string

If you want a specific gid, append it with a colon, e.g.

   add_group support:498

Returns string if it created the group.  Does nothing if group exists.

=cut

sub add_group {
    my($self, $group) = @_;
    $self->usage_error('must supply a group') unless $group;
    my($gname, $gid) = split(/:/, $group);
    my($real) = (getgrnam($gname))[2];
    if (defined($real)) {
	Bivio::IO::Alert->warn("$gname: expected gid ($gid) but got ($real)")
	    if defined($gid) && $real != $gid;
	return '';
    }
    return _exec($self, 'groupadd '
	    . (defined($gid) ? "-g '$gid' " : '')
	    . "'$gname'")
}

=for html <a name="add_sendmail_class_line"></a>

=head2 static add_sendmail_class_line(string file, string value, ...)

Adds I<value>s to class file (e.g. trusted-users),
creating if it doesn't exist.

=cut

sub add_sendmail_class_line {
    my($self, $file, @value) = @_;
    return $self->append_lines("/etc/mail/$file", 'root', 'mail', 0640,
	@value);
}

=for html <a name="add_sendmail_http_agent"></a>

=head2 add_sendmail_http_agent(string uri) : string

Sets up C<b-sendmail-http> agent interface in sendmail.cf.

=cut

sub add_sendmail_http_agent {
    my($self, $uri) = @_;
    return _edit($self, '/etc/sendmail.cf',
	[qr/\$#local \$: \$1/, '$#bsendmailhttp $: $1'],
	# We don't set "w", sendmail-http does it itself
	['$', <<"EOF", qr/\nMbsendmailhttp/],
Mbsendmailhttp,	P=/usr/bin/b-sendmail-http,
	F=9:|/\@ADFhlMnsPqS,
	S=EnvFromL/HdrFromL, R=EnvToL/HdrToL, T=DNS/RFC822/X-Unix,
	A=b-sendmail-http \${client_addr} \$u $uri /usr/bin/procmail -t -Y -a \$h -d \$u
EOF
    );
}

=for html <a name="add_user"></a>

=head2 add_user(string user, string group, string shell) : string

Adds I<user> with optional I<group> and I<shell>.  Set I<group> is '', if you
want to set I<shell>.  User isn't added if it exists.

If you want a specific uid or gid, append it with a colon, e.g.

   add_user support:498 support:498

=cut

sub add_user {
    my($self, $user, $group, $shell) = @_;
    $self->usage_error('must at least supply a user') unless $user;
    my($res) = '';
    $group = $user unless $group;
    $res .= $self->add_group($group);
    $group =~ s/:.*//;
    my($uname, $uid) = split(/:/, $user);
    my($real) = (getpwnam($uname))[2];
    if (defined($real)) {
	Bivio::IO::Alert->warn("$uname: expected uid ($uid) but got ($real)")
	    if defined($uid) && $uid != $real;
	return '';
    }
    return $res . _exec($self, 'useradd -m '
	    . (defined($uid) ? "-u '$uid' " : '')
	    . ($group ? "-g '$group' " : '')
	    . ($shell ? "-s '$shell' " : '')
	    . "'$uname'");
}

=for html <a name="add_users_to_group"></a>

=head2 add_users_to_group(string group, string user, ...) : string

Adds users to /etc/group.

=cut

sub add_users_to_group {
    my($self, $group, @user) = @_;
    my($res) = _edit($self, '/etc/group', map {
	my($user) = $_;
	[
	    qr/^($group:.*:)(.*)/m,
	    sub {$1 . (length($2) ? "$2,$user" : "$user")},
	    qr/^$group:.*[:,]$user(,|$)/m,
	];
    } @user);
    $res .= _exec($self, 'grpconv') if $res && $> == 0;
    return $res;
}

=for html <a name="allow_any_sendmail_smtp"></a>

=head2 allow_any_sendmail_smtp(string max_message_size) : string

Enable sendmail's smtp to listen from anywhere.  Makes privacy options
stricter.  Closes off /var/spool/mqueue.  Sets max message size,
defaults to 10000000.

=cut

sub allow_any_sendmail_smtp {
    my($self, $max_message_size) = @_;
    $max_message_size ||= 10000000;
    return _edit($self, '/etc/sendmail.cf',
	[qr/^\#?(O\s+DaemonPortOptions\s*=.*),Addr=127.0.0.1/m,
	    sub {$1},
	    qr/DaemonPortOptions=Port=smtp,(?!Addr=127.0.0.1)/m],
	map {
	    my($option, $value) = split(/=/);
	    [qr/^#?O\s+$option\s*=.*/m, "O $option=$value",
	        qr/^\QO $option=$value\E$/m];
	} 'PrivacyOptions=goaway,restrictmailq,restrictqrun',
	    'SmtpGreetingMessage=$j',
	    "MaxMessageSize=$max_message_size"
        )
        . _exec($self, "chmod 0700 " . _prefix_file('/var/spool/mqueue'));
}

=for html <a name="append_lines"></a>

=head2 append_lines(string file, string owner, string group, int perms, array lines) : string

Adds lines to file, creating if necessary.

=cut

sub append_lines {
    my($self, $file, $owner, $group, $perms, @lines) = @_;
    $perms = oct($perms) if $perms =~ /^0/;
    return _add_file($self, $file, $owner, $group, $perms)
	. _edit($self, $file, map {
	    ['$', "$_\n", qr/^\Q$_\E$/m],
	 } @lines);
}

=for html <a name="create_ssl_crt"></a>

=head2 create_ssl_crt(string iso_country, string state, string city, string organization, string hostname) : string

Creates SSL key, csr, and crt in ssl.* dirs.

=cut

sub create_ssl_crt {
    my($self, $iso_country, $state, $city, $organization, $hostname) = @_;
    my($res) = '';
    my($f) = {};
    foreach my $w (qw(key crt csr)) {
	$f->{$w} = _prefix_file("ssl.$w") . "/$hostname.$w";
	$res .= _mkdir($self, "ssl.$w", 0750);
    }
    return _exec($self, "openssl genrsa -out $f->{key} 1024")
	. _exec($self,
	    "openssl req -new -key $f->{key} -out $f->{csr}", <<"EOF")
$iso_country
$state
$city
$organization

$hostname



EOF
	. _exec($self, "openssl x509 -req -days 10000 -in $f->{csr} "
	    . "-signkey $f->{key} -out $f->{crt}");
}

=for html <a name="disable_iptables_counters"></a>

=head2 disable_iptables_counters() : string

Updates /etc/rc.d/init.d/iptables to not save/restore with counters.

=cut

sub disable_iptables_counters {
    my($self) = @_;
    return _edit($self, '/etc/rc.d/init.d/iptables',
	map {
	    [qr/(iptables-$_)\s+-c\b/m, sub {$1},
		 qr/iptables-$_\s+[&>;]/];
	} qw(save restore));
}

=for html <a name="delete_crontab_line"></a>

=head2 delete_crontab_line(string user, string entry, ...) : string

Delete I<entry>s from this I<user>'s crontab.

=cut

sub delete_crontab_line {
    my($self, $user, @entry) = @_;
    return _delete_lines($self, "/var/spool/cron/$user", \@entry);
}

=for html <a name="delete_sendmail_class_line"></a>

=head2 static delete_sendmail_class_line(string file, string line, ...)

Deletes I<line>s to class file (e.g. trusted-users).


=cut

sub delete_sendmail_class_line {
    my($self, $file, @line) = @_;
    return _delete_lines($self, "/etc/mail/$file", \@line);
}

=for html <a name="disable_service"></a>

=head2 disable_service(string service, ...) : string

Disables services.

=cut

sub disable_service {
    my($self, @service) = @_;
    my($res);
    foreach my $s (@service) {
	# Ignore uninstalled services
	my($chk) = $self->piped_exec("chkconfig --list $s 2>/dev/null", '', 1);
	# Look for a line like: $s 0 or $s on...
	next unless $$chk =~ /^\Q$s\E\s+\w/ && $$chk =~ /^\Q$s\E\s.*\bon\b/;
	# xinetd services don't respond to --del
	$res .= -x "/etc/rc.d/init.d/$s"
	    ? _exec($self, "chkconfig --del $s")
		. _exec($self, "/etc/rc.d/init.d/$s stop", 1)
	    : _exec($self, "chkconfig $s off");
    }
    return $res;
}

=for html <a name="enable_service"></a>

=head2 enable_service(string service, ...) : string

Enables I<service>s and starts them running at 2345 run levels.

=cut

sub enable_service {
    my($self, @service) = @_;
    my($res);
    foreach my $s (@service) {
	# Should blow up if service doesn't exist
	next if ${$self->piped_exec("chkconfig --list $s 2>/dev/null")}
	    =~ /^$s\s.*\bon\b/;
	$res .= _exec($self, "chkconfig --level 2345 $s on");
	$res .= _exec($self, "/etc/rc.d/init.d/$s start")
	    if -x "/etc/rc.d/init.d/$s";
    }
    return $res;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item root_prefix : string []

Prefix root directory.  Used for testing, e.g. /home/nagler/tmp

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

=for html <a name="rename_rpmnew"></a>

=head2 rename_rpmnew(string rpmnew_file, ...) : string

Renames rpmnew files to actual file.

Usage is typically:

    b-linux-config -noexecute rename_rpmnew all

Returns list of actions.  "all" is the following:

    find /etc /var /usr -name \*.rpmnew

=cut

sub rename_rpmnew {
    my($self, @rpmnew_file) = @_;
    @rpmnew_file = `find /etc /var /usr -name '*.rpmnew'`
	if "@rpmnew_file" eq 'all';
    my($res) = '';
    foreach my $n (map {_prefix_file($_)} @rpmnew_file) {
	my($f) = $n;
	$f =~ s/.rpmnew$//;
	next unless -f $n;
	unless ($self->unsafe_get('noexecute')) {
	    my($s) = "$f.rpmsave";
	    unlink($s);
	    $self->piped_exec("cp -af $f $s");
	    $self->piped_exec("cp -af $n $f");
	    unlink($n);
	}
	else {
	    $res .= 'Would have ';
	}
	$res .= "Updated: $f\n";
    }
    return $res;
}

=for html <a name="rhn_up2date_param"></a>

=head2 rhn_up2date_param(string param, string value, ...) : string

Set I<param> to I<value> in up2date config.  Knows how to replace only
those parameters which already exist in the file.

Very prelim.  See test for example in use.

=cut

sub rhn_up2date_param {
    my($self, @args) = @_;
    return _edit($self, '/etc/sysconfig/rhn/up2date', map {
	my($param, $value) = @$_;
	[qr/\n$param\s*=\s*[^;]*;/m, "\n$param=$value;"],
    } @{$self->group_args(2, \@args)});
}

=for html <a name="serial_console"></a>

=head2 serial_console(string speed) : string

Makes a serial console on ttyS0.  Modifies grub.conf, securetty, and
inittab.   May be called repeatedly.  I<speed> defaults to 38400.

=cut

sub serial_console {
    my($self, $speed) = @_;
    $speed ||= '38400';
    return _edit($self, '/etc/securetty', ['$', "ttyS0\n", "ttyS0\n"])
	. _edit($self, '/etc/inittab',
	    ['(?<=getty tty6\n)(S0:[^\n]+\n)?',
		"S0:2345:respawn:/sbin/agetty ttyS0 $speed\n",
		'S0.*agetty',
	    ],
	    ["ttyS0 \\d+\n", "ttyS0 $speed\n"],
	   )
        . _edit($self, '/etc/grub.conf',
	    ['(?<!\#)splashimage', '#splashimage'],
	    ["(?=\n\tinitrd)", " console=ttyS0,$speed",
		'console=ttyS0,'
	    ],
	    ['console=ttyS0,\d+', "console=ttyS0,$speed"],
	    ["\ntimeout=\\d+\n", "\ntimeout=5\n"],
	    ["(?<=\ntimeout=5\n)", "serial --unit=0 --speed=$speed\n",
		"serial --unit=0 --speed=",
	    ],
  	    ['serial --unit=0 --speed=\d+', "serial --unit=0 --speed=$speed"],
  	    ["(?<=serial --unit=0 --speed=$speed\n)",
  		"terminal --timeout=1 serial\n",
  	    ],
        );
}

=for html <a name="sshd_param"></a>

=head2 static sshd_param(string param, string value, ...) : string

Set I<param> to I<value> in sshd_config.  Knows how to replace only
those parameters which already exist in the file.

=cut

sub sshd_param {
    my($self, @args) = @_;
    return _edit($self, '/etc/ssh/sshd_config', map {
	my($param, $value) = @$_;
	["(?<=\n)\\s*#?\\s*$param\[^\n]+", "$param $value"],
    } @{$self->group_args(2, \@args)});
}

#=PRIVATE METHODS

# _add_file(self, string file, string owner, string group, int perms)
#
# Creates the file if it doesn't exist.
#
sub _add_file {
    my($self, $file, $owner, $group, $perms) = @_;
    $file = _prefix_file($file);
    return '' if -e $file;
    return "Would have created: $file\n" if $self->unsafe_get('noexecute');
    Bivio::IO::File->write($file, '');
    Bivio::IO::File->chown_by_name($owner, $group, $file)
	if $> == 0;
    Bivio::IO::File->chmod($perms, $file);
    return "Created: $file\n";
}

# _delete_lines(self, string file, array_ref lines) : string
#
# Removes lines to file.
#TODO: Should it delete the file???
#
sub _delete_lines {
    my($self, $file, $lines) = @_;
    return _edit($self, $file,
	[sub {
	     my($data) = @_;
	     my($got);
	     foreach my $l (@$lines) {
		 $$data =~ s/^\Q$l\E(\n|$)//mg and $got++;
	     }
	     return $got;
	}]);
}

# _edit(self, string file, array_ref op)
#
# Inserts a value into a file.
#
sub _edit {
    my($self, $file, @op) = @_;
    $file = _prefix_file($file);
    my($data) = Bivio::IO::File->read($file);
    my($got);
    foreach my $op (@op) {
	my($where, $value, $search) = @$op;
	if (ref($where) eq 'CODE') {
	    $got++ if &$where($data);
	    next;
	}
	$search = qr/\Q$value/s unless defined($search);
#TODO: Replace when perl bug is fixed.
	my($x) = "$search";
	next if $$data =~ /$x/;
	if ($where eq '$') {
	    # Special case for append_lines
	    Bivio::Die->die("$value: bad value") if ref($value);
	    $$data .= $value;
	}
	else {
	    $where = qr/$where/s unless ref($where);
	    $$data =~ s/$where/ref($value) ? &$value() : $value/eg
	        or Bivio::Die->die($file, ": didn't find /$where/\n");
	}
	$got++;
    }
    return '' unless $got;
    return "Would have updated: $file\n"
	if $self->unsafe_get('noexecute');
    system("cp -a $file $file.bak");
    Bivio::IO::File->write($file, $data);
    return "Updated: $file\n";
}

# _exec(self, string command, string in, boolean ignore_exit_code) : string
#
# Execute obeying noexecute.
#
sub _exec {
    my($self, $cmd, $in, $ignore_exit_code) = @_;
    $in ||= '';
    $cmd .= ' 2>&1';
    return "Would have executed: $cmd\n"
	if $self->unsafe_get('noexecute');
    return "Executed: $cmd\n" . ${$self->piped_exec($cmd, \$in, $ignore_exit_code)};
}

# _mkdir(self, string dir, int perms) : string
#
# Creates dir if it doesn't exist
#
sub _mkdir {
    my($self, $dir, $perms) = @_;
    $dir = _prefix_file($dir);
    return '' if -d $dir;
    return "Would have created: $dir\n" if $self->unsafe_get('noexecute');
    return "Created " . Bivio::IO::File->mkdir_p($dir, $perms) . "\n";
}

# _prefix_file(string file) : string
#
# Adds root_prefix to $file.
#
sub _prefix_file {
    my($file) = @_;
    return $_CFG->{root_prefix} ? "$_CFG->{root_prefix}$file" : $file;
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
