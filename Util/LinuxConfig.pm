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
   bashrc_d
   sendmail_cf
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
    add_group group[:gid] -- add a group
    add_user user[:uid] [group[:gid] [shell]] -- create a user
    add_users_to_group group user... -- add users to group
    create_ssl_crt iso_country state city organization hostname -- create ssl certificate
    disable_iptables_counters -- disables saving counters in iptables state file
    disable_service service... -- calls chkconfig and stops services
    enable_service service ... -- enables service
    relay_domains host ... -- add hosts to sendmail relay-domains
    rename_rpmnew file.rpmnew ... -- renames rpmnew to orig & orig to rpmsave
    rhn_up2date_param param value ... -- update params in up2date config
    serial_console -- configure grub and init for serial port console
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
	Bivio::Die->die("$gname: expected gid ($gid) but got ($real)")
	    if defined($gid) && $real != $gid;
	return '';
    }
    return _exec($self, 'groupadd '
	    . (defined($gid) ? "-g '$gid' " : '')
	    . "'$gname'")
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
    my($real) = (getpwnam($uname))[3];
    if (defined($real)) {
	Bivio::Die->die("$uname: expected uid ($uid) but got ($real)")
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
    return _insert_text($self, '/etc/group', map {
	my($user) = $_;
	[
	    qr/^($group:.*:)(.*)/m,
	    sub {$1 . (length($2) ? "$2,$user" : '$user')},
	    qr/^$group:.*[:,]$user(,|$)/m,
	];
    } @user);
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
	my($d) = _prefix_file("ssl.$w");
	$f->{$w} = "$d/$hostname.$w";
        next if -d $d;
	$res .= "Created " . Bivio::IO::File->mkdir_p($d) . "\n";
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
    return _insert_text($self, '/etc/rc.d/init.d/iptables',
	map {
	    [qr/(iptables-$_)\s+-c\b/m, sub {$1},
		 qr/iptables-$_\s+[&>;]/];
	} qw(save restore));
}

=for html <a name="disable_service"></a>

=head2 disable_service(string service, ...) : string

Disables services.

=cut

sub disable_service {
    my($self, @service) = @_;
    my($res);
    foreach my $s (@service) {
	next unless
	    ${$self->piped_exec("chkconfig --list $s 2>/dev/null")}
		=~ /^$s\s.*\bon\b/;
	$res .= _exec($self, "chkconfig --del $s")
	    . _exec($self, "/etc/rc.d/init.d/$s stop");
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
	next
	    if ${$self->piped_exec("chkconfig --list $s 2>/dev/null")}
		=~ /^$s\s.*\bon\b/;
	$res .= _exec($self, "chkconfig --level 2345 $s");
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

=for html <a name="relay_domains"></a>

=head2 static relay_domains(string host, ...)

Adds I<host>s to relay-domains file (creating if it doesn't exist).

=cut

sub relay_domains {
    my($self, @host) = @_;
    my($f) = '/etc/mail/relay-domains';
    return _add_file($self, $f, 'root', 'mail', 0640)
	. _insert_text($self, $f, ['^', join("\n", @host) . "\n"]);
}

=for html <a name="rename_rpmnew"></a>

=head2 rename_rpmnew(string rpmnew_file, ...) : string

Renames rpmnew files to actual file.

Usage is typically:

    b-linux-config -noexecute rename_rpmnew $(find /etc /var /usr -name \*.rpmnew)

Returns list of actions.

=cut

sub rename_rpmnew {
    my($self, @rpmnew_file) = @_;
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
    return _insert_text($self, '/etc/sysconfig/rhn/up2date', map {
	my($param, $value) = @$_;
	[qr/\n$param\s*=\s*[^;]+;/m, "\n$param=$value;"],
    } @{$self->group_args(2, \@args)});
}

=for html <a name="serial_console"></a>

=head2 serial_console() : string

Makes a serial console on ttyS0.  Modifies grub.conf, securetty, and
inittab.   May be called repeatedly.

=cut

sub serial_console {
    my($self) = @_;
    return _insert_text($self, '/etc/securetty', ['^', "/dev/ttyS0\n"])
	. _insert_text($self, '/etc/inittab', ['(?<=getty tty6\n)',
	    "S0:2345:respawn:/sbin/agetty ttyS0 38400\n"])
        . _insert_text($self, '/etc/grub.conf',
	    ['(?<!\#)splashimage', '#splashimage'],
	    ["(?=\n\tinitrd)", ' console=ttyS0,38400'],
	    ["\ntimeout=10\n", <<'EOF']);

timeout=5
serial --unit=0 --speed=38400
terminal --timeout=1 serial
EOF
}

=for html <a name="sshd_param"></a>

=head2 static sshd_param(string param, string value, ...) : string

Set I<param> to I<value> in sshd_config.  Knows how to replace only
those parameters which already exist in the file.

=cut

sub sshd_param {
    my($self, @args) = @_;
    return _insert_text($self, '/etc/ssh/sshd_config', map {
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

# _exec(self, string command, string $in) : string
#
# Execute obeying noexecute.
#
sub _exec {
    my($self, $cmd, $in) = @_;
    $in ||= '';
    $cmd .= ' 2>&1';
    return "Would have executed: $cmd\n"
	if $self->unsafe_get('noexecute');
    return "Executed: $cmd\n" . ${$self->piped_exec($cmd, \$in)};
}

# _insert_text(self, string file, array_ref op)
#
# Inserts a value into a file.
#
sub _insert_text {
    my($self, $file, @op) = @_;
    $file = _prefix_file($file);
    my($data) = Bivio::IO::File->read($file);
    my($got);
    foreach my $op (@op) {
	my($where, $value, $search) = @$op;
	$search = qr/\Q$value/s unless defined($search);
	next if $$data =~ /$search/;
	$where = qr/$where/s unless ref($where);
	$$data =~ s/$where/ref($value) ? &$value() : $value/eg
	    or Bivio::Die->die($file, ": didn't find /$where/\n");
	$got++;
    }
    return '' unless $got;
    return "Would have updated: $file\n"
	if $self->unsafe_get('noexecute');
    system("cp -a $file $file.bak");
    Bivio::IO::File->write($file, $data);
    return "Updated: $file\n";
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
