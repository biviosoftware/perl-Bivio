# Copyright (c) 2002-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::LinuxConfig;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.Trace');

my($_D) = b_use('Bivio.Die');
our($_TRACE);
b_use('IO.Config')->register(my $_CFG = {
    root_prefix => '',
    networks => {},
}); 

sub USAGE {
    return <<'EOF';
usage: b-linux-config [options] command [args...]
commands:
    add_aliases alias:value ... -- add entries to aliases
    add_crontab_line user entry... -- add entries to crontab
    add_group group[:gid] -- add a group
    add_sendmail_class_line filename line ... -- add values trusted-users, relay-domains, etc
    add_user user[:uid] [group[:gid] [shell]] -- create a user
    add_users_to_group group user... -- add users to group
    append_lines file owner group perms line ... -- appends lines to a file if they don't already exist
    delete_aliases user entry... -- delete entries from crontab
    delete_file file -- deletes file
    disable_service service... -- calls chkconfig and stops services
    enable_service service ... -- enables service
    rename_rpmnew all | file.rpmnew... -- renames rpmnew to orig and rpmsaves orig
    replace_file file owner group perms content -- replaces file with content
    serial_console [speed] -- configure grub and securetty for serial port console
    sh_param file param value ... -- updates an sh-style config file
    split_file file -- splits a file into an array, ignoring # comments
    sshd_param param value ... -- add or delete a parameter from sshd config
EOF
}
sub add_aliases {
    # Adds aliases: 'foo: bar'.  Ensures a \t is between : and destination.
    return _add_aliases('/etc/aliases', ':', @_);
}

sub add_bashrc_d {
    my($self) = @_;
    # Updates /etc/bashrc to search /etc/bashrc.d.
    return _mkdir($self, '/etc/bashrc.d', 0755)
        . _edit($self, '/etc/bashrc', ['$', <<'EOF', qr{/etc/bashrc.d/}]);

# Load local bashrcs
for i in /etc/bashrc.d/*.sh ; do
    if [ -r $i ]; then
        . $i
    fi
done

unset i
EOF
}

sub add_crontab_line {
    my($self, $user, @entry) = @_;
    # Add I<entry>s to this I<user>'s crontab.
    return $self->append_lines(
        -d '/var/spool/cron/tabs' ? "/var/spool/cron/tabs/$user"
            : "/var/spool/cron/$user",
        'root',
        $user,
        0600,
        @entry,
    );
}

sub add_group {
    my($self, $group) = @_;
    # If you want a specific gid, append it with a colon, e.g.
    #
    #    add_group support:498
    #
    # Returns string if it created the group.  Does nothing if group exists.
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

sub add_sendmail_class_line {
    my($self, $file, @value) = @_;
    # Adds I<value>s to class file (e.g. trusted-users),
    # creating if it doesn't exist.
    return $self->append_lines("/etc/mail/$file", 'root', 'mail', 0640,
        @value);
}

sub add_user {
    my($self, $user, $group, $shell) = @_;
    # Adds I<user> with optional I<group> and I<shell>.  Set I<group> is '', if you
    # want to set I<shell>.  User isn't added if it exists.
    #
    # If you want a specific uid or gid, append it with a colon, e.g.
    #
    #    add_user support:498 support:498
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

sub add_users_to_group {
    my($self, $group, @user) = @_;
    # Adds users to /etc/group.
    my($res) = _edit($self, '/etc/group', map {
        my($user) = $_;
        [
            qr{^($group:.*:)(.*)}m,
            sub {$1 . (length($2) ? "$2,$user" : "$user")},
            qr{^$group:.*[:,]$user(,|$)}m,
        ];
    } @user);
    $res .= _exec($self, 'grpconv')
        if -f '/etc/gshadow' && $res && $> == 0;
    return $res;
}

sub append_lines {
    my($self, $file, $owner, $group, $perms, @lines) = @_;
    # Adds lines to file, creating if necessary.
    $perms = oct($perms) if $perms =~ /^0/;
    return _add_file($self, $file, $owner, $group, $perms)
        . _edit($self, $file, _gen_append_cmds(@lines));
}

sub delete_aliases {
    my($self) = shift;
    return _delete_lines($self, '/etc/aliases', [map(qr{^$_\:[^\n]+$}m, @_)]);
}

sub delete_file {
    my($self, $file) = @_;
    # Deletes I<file> if it exists.  Otherwise, does nothing.  If it can't delete,
    # dies.
    $file = _prefix_file($file);
    return ''
        unless -e $file;
    return ($self->unsafe_get('noexecute')
        ? 'Would have '
        : (unlink($file) || b_die("unlink($file): $!"))
    ) . "Deleted: $file\n";
}

sub disable_service {
    my($self, @service) = @_;
    # Disables services.
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

sub enable_service {
    my($self, @service) = @_;
    # Enables I<service>s and starts them running at 2345 run levels.
    my($res);
    foreach my $s (@service) {
        # Should blow up if service doesn't exist
        next if ${$self->piped_exec("chkconfig --list $s 2>/dev/null", '', 1)}
            =~ /^$s\s.*\bon\b/;
        $res .= _exec($self, "chkconfig --level 2345 $s on");
        $res .= _exec($self, "/etc/rc.d/init.d/$s start")
            if -x "/etc/rc.d/init.d/$s";
    }
    return $res;
}

sub generate {
    my($self) = @_;
    foreach my $op (@{$_D->eval_or_die(${$self->read_input})}) {
        my($method) = shift(@$op);
        $self->$method(@$op);
    }
    return;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub postgres_base {
    my($self) = @_;
    return _replace_param(
        $self, '/var/lib/pgsql/data/postgresql.conf',
        ['#*\s*(timezone\s*=\s*)', 'UTC'],
    ) . _replace_param($self, '/var/lib/pgsql/data/pg_hba.conf',
        ['(local.*)ident(?:\s+sameuser)?', 'trust'],
        ['(host.*127.0.*)ident(?:\s+sameuser)?', 'password'],
        ['(host.*1/128.*)ident(?:\s+sameuser)?', 'password'],
    ) . _optional(
        $self, '/etc/rc.d/init.d/postgresql',
        \&_replace_param,
        ['(#\s*chkconfig:\s*)', '345 84 16'],
    );
}

# sub postgresql_param {
#     my($self) = @_;
#     return _replace_param(
#         $self, '/var/lib/pgsql/data/postgresql.conf',
#         ['#*\s*(timezone\s*=\s*)', 'UTC'],
#     return;
# }

sub rename_rpmnew {
    my($self, @rpmnew_file) = @_;
    # Renames rpmnew files to actual file.
    #
    # Usage is typically:
    #
    #     b-linux-config rename_rpmnew all
    #
    # Returns list of actions.  "all" is the following:
    #
    #     find /etc /var /usr -name \*.rpmnew
    #
    # You can also say:
    #
    #     b-linux-config rename_rpmnew /etc
    @rpmnew_file = ('/etc', '/var', '/usr')
        if "@rpmnew_file" eq 'all';
    chomp(@rpmnew_file = `find @rpmnew_file -name '*.rpmnew'`)
        unless grep(/\.rpmnew$/, @rpmnew_file);
    my($res) = '';
    foreach my $n (map {_prefix_file($_)} @rpmnew_file) {
        my($f) = $n;
        $f =~ s/.rpmnew$//;
        next unless -f $n;
        unless ($self->unsafe_get('noexecute')) {
            my($s) = "$f.rpmsave";
            unlink($s);
            $self->piped_exec("cp -pRf $f $s");
            $self->piped_exec("cp -pRf $n $f");
            unlink($n);
        }
        else {
            $res .= 'Would have ';
        }
        $res .= "Updated: $f\n";
    }
    return $res;
}

sub replace_file {
    my($self) = shift;
    # Add content to file; deleting old one if it exists.
    return $self->delete_file($_[0]) . _add_file($self, @_);
}

sub serial_console {
    my($self, $speed) = @_;
    $speed ||= '57600';
    return _edit($self, '/etc/securetty', ['$', "ttyS0\n", "ttyS0\n"])
        . _edit($self, '/boot/grub/menu.lst',
            ['(?<!\#)splashimage', '#splashimage'],
            ['(?<!\#)hiddenmenu', '#hiddenmenu'],
            ["(?=\n\tinitrd)", " console=ttyS0,$speed",
                'console=ttyS0,'
            ],
            ['console=ttyS0,\d+', "console=ttyS0,$speed",
                 "console=ttyS0,$speed"],
            ["\ntimeout=\\d+\n", "\ntimeout=5\n"],
            ["(?<=\ntimeout=5\n)", "serial --unit=0 --speed=$speed\n",
                "serial --unit=0 --speed=",
            ],
            ['serial --unit=0 --speed=\d+', "serial --unit=0 --speed=$speed"],
            ["(?<=serial --unit=0 --speed=$speed\n)",
                "terminal --timeout=1 serial\n",
            ],
            ['? rhgb ', ' '],
            ['? quiet ', ' '],
        );
}

sub sh_param {
    my($self, $file, @args) = @_;
    return _edit($self, $file, map {
        my($param, $value) = @$_;
        ["(?<=\n)\\s*#?\\s*$param\[^\n]+", "$param='$value'"],
    } @{$self->group_args(2, \@args)});
}

sub split_file {
    my(undef, $file) = @_;
    return [grep(
        length($_) && $_ !~ /^\s*#/,
        split(/\n+/, ${Bivio::IO::File->read($file)}),
    )];
}

sub sshd_param {
    my($self, @args) = @_;
    # Set I<param> to I<value> in sshd_config.  Knows how to replace only
    # those parameters which already exist in the file.
    return _edit($self, '/etc/ssh/sshd_config', map {
        my($param, $value) = @$_;
        ["(?<=\n)\\s*#?\\s*$param\[^\n]+", "$param $value"],
    } @{$self->group_args(2, \@args)});
}

sub _add_aliases {
    my($file, $sep, $self) = splice(@_, 0, 3);
    return $self->append_lines(
        $file,  qw(root root 0640),
        map({
            (my $x = $_) =~ s/;/,/g;
            join("$sep\t", split(/:\s*/, $x, 2));
        } @_),
    );
}

sub _add_file {
    my($self, $file, $owner, $group, $perms, $content) = @_;
    # Creates the file if it doesn't exist.  Always creates if $content.
    $file = _prefix_file($file);
    return '' if -e $file && !defined($content);
    return "Would have created: $file\n" if $self->unsafe_get('noexecute');
    Bivio::IO::File->write($file, defined($content) ? $content : '');
    Bivio::IO::File->chown_by_name($owner, $group, $file)
        if $> == 0;
    Bivio::IO::File->chmod($perms, $file);
    return "Created: $file\n";
}

sub _assert_dns_configured_for {
    my($self, $domain) = @_;
    my($ip) = _dig($domain);
    my($cfg) = _network_config_for($ip);
    Bivio::DieCode->CONFIG_ERROR->throw_die(
        "config missing DNS for subnet containing '$ip ($domain)'")
            unless exists($cfg->{dns}) && ref($cfg->{dns}) eq 'ARRAY';
    return $cfg->{dns};
}

sub _assert_interface_and_domain {
    my($self, $interface_and_domain) = @_;
    b_die('must specify interface and domain -- remember to use quotes')
            unless defined($interface_and_domain)
                && $interface_and_domain =~ / /;
    my($device, $domain) = split(" ", $interface_and_domain, 2);
    b_die('failed to parse interface and domain.  Did you use quotes?  (e.g. "eth0 some.example.com")')
            unless defined($device) && defined($domain) && $domain !~ / /;
    return $device, $domain;
}

sub _assert_netmask_and_gateway_for {
    my($self, $domain) = @_;
    my($ip) = _dig($domain);
    my($cfg) = _network_config_for($ip);
    Bivio::DieCode->CONFIG_ERROR->throw_die(
        "subnet containing '$ip ($domain)' missing netmask")
            unless $cfg->{mask};
    _trace($ip, ' ', $cfg) if $_TRACE;
    return (_bits2netmask($self, $cfg->{mask}),
            $cfg->{gateway} && _dig($cfg->{gateway}));
}

sub _assert_network_configured_for {
    my($self, $domain) = @_;
    my($ip) = _dig($domain);
    my($cfg) = _network_config_for($ip);
    Bivio::DieCode->CONFIG_ERROR->throw_die(
        "no subnet configured containing address '$ip ($domain)'")
            unless defined($cfg);
    return $cfg;
}

sub _base_domain {
    my($domain) = @_;
    ($domain) = $domain =~ /(\w+\.\w+)$/;
    return $domain;
}

sub _bits2netmask {
    my($self, $bits) = @_;
    b_die("$bits is not between 8 and 30")
        unless defined($bits) && $bits >= 8 && $bits <= 30;
    return join(
        '.',
        unpack(
            'C4',
            pack('N', $bits == 32 ? 0 : 0xffffffff << (32 - $bits)),
        ),
    );
}

sub _delete_lines {
    my($self, $file, $lines) = @_;
    # Removes lines to file.
    #TODO: Should it delete the file???
    return _edit($self, $file,
        [sub {
             my($data) = @_;
             my($got);
             foreach my $l (@$lines) {
                 my($x) = ref($l) ? $l : qr{^\Q$l\E(\n|$)}m;
                 $$data =~ s/$x//mg and $got++;
             }
             return $got;
        }]);
}

sub _device {
    my($num) = @_;
    return 'eth0' . ($num ? ":$num" : '');
}

sub _dig {
    my($hostname) = @_;
    b_die('missing hostname')
         unless defined($hostname);
    # TODO: this is a HACK. caching in the config is bad form, but this is run
    # from the command line and won't be hanging around in memory for very
    # long.  As an added bonus, it also serves to spoof dns from the unit test.
    my($cache) = $_CFG->{_dig_cache} ||= {};
    unless (exists($cache->{$hostname})) {
        my($ip) = $hostname =~ /^\d+\.\d+\.\d+\.\d+$/ ? $hostname
            : `dig +short $hostname`;
        _trace('dig ', $hostname, ': ', $ip)
            if $_TRACE;
        Bivio::DieCode->NOT_FOUND->throw_die(
            "failed to resolve ip address for '$hostname': $!")
                unless defined($ip);
        chomp($ip);
        $cache->{$hostname} = $ip;
    }
    return $cache->{$hostname};
}

sub _edit {
    my($self, $file, @op) = @_;
    # Inserts a value into a file.
    $file = _prefix_file($file);
    my($data) = Bivio::IO::File->read($file);
    my($orig_data) = $$data;
    my($got);
    foreach my $op (@op) {
        my($where, $value, $search) = @$op;
        if (ref($where) eq 'CODE') {
            $got++ if $where->($data);
            next;
        }
        $search = $value =~ /\n/ ? qr{\Q$value}s : qr{^\s*\Q$value}m
            unless defined($search);
#TODO: Replace when perl bug is fixed.
        my($x) = "$search";
        next if $$data =~ /$x/;
        if ($where eq '$') {
            # Special case for append_lines
            b_die("$value: bad value")
                if ref($value);
            $$data .= $value;
        }
        else {
            my($optional);
            unless (ref($where)) {
                $optional = $where =~ s/^\?//s;
                $where = qr{$where}s;
            }
            b_die($file, ": didn't find /$where/\n")
                unless $$data =~ s/$where/ref($value) ? $value->() : $value/eg
                || $optional;
        }
        $got++;
    }
    return ''
        unless $got && $$data ne $orig_data;
    return "Would have updated: $file\n"
        if $self->unsafe_get('noexecute');
    # Delete the backup file.  This has side effects for add_crontab_line
    # which needs to modify /var/spool/cron for cron to "wakeup" and reread
    # all crontabs.
    unlink("$file.rpmsave");
    system("cp -pR $file $file.rpmsave");
    Bivio::IO::File->write($file, $data);
    return "Updated: $file\n";
}

sub _exec {
    my($self, $cmd, $in, $ignore_exit_code) = @_;
    # Execute obeying noexecute.
    $in ||= '';
    $cmd .= ' 2>&1';
    return "Would have executed: $cmd\n"
        if $self->unsafe_get('noexecute');
    return "Executed: $cmd\n" . ${$self->piped_exec($cmd, \$in, $ignore_exit_code)};
}

sub _file_hosts {
    my($self, $hostname, @others) = @_;
    _trace(join(' ', $hostname, @others))
        if $_TRACE;
    my($result) = _prepend_auto_generated_header(<<"EOF")
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1                localhost.localdomain localhost
EOF
        . join('', map(sprintf("%s\t%s\n", _dig($_), $_),
                       $hostname, @others
                   ));
    return 'etc/hosts', \$result;
}

sub _file_ifcfg {
    my($self, $device, $domain, $gateways_seen) = @_;
    my($ip) = _dig($domain);
    my($netmask) = _bits2netmask($self, _mask_for($ip));
    my($gateway) = _network_config_for($ip)->{gateway} || '';
    $gateway = _dig($gateway)
        if $gateway;
    my($gw_line) = '';
    if ($gateway && $gateway ne $ip && !exists($gateways_seen->{$gateway})) {
        $gateways_seen->{$gateway} = 1;
        $gw_line = 'GATEWAY=' . $gateway;
    }
    return 'etc/sysconfig/network-scripts/ifcfg-' . $device,
        \(_prepend_auto_generated_header(<<"EOF"));
DEVICE=$device
ONBOOT=yes
BOOTPROTO=none
IPADDR=$ip
NETMASK=$netmask
$gw_line
EOF
}

sub _file_network {
    my($self, $hostname) = @_;
    return 'etc/sysconfig/network', \(_prepend_auto_generated_header(<<"EOF"));
NETWORKING=yes
NETWORKING_IPV6=yes
HOSTNAME=$hostname
EOF
}

sub _file_resolv_conf {
    my($self, $domain) = @_;
    my($base_domain) = _base_domain($domain);
    my($ns1, $ns2) =
        map(_dig($_), @{_assert_dns_configured_for($self, $domain)});
    return 'etc/resolv.conf', \(_prepend_auto_generated_header(<<"EOF"));
search $base_domain
domain $base_domain
nameserver $ns1
nameserver $ns2
EOF
}

sub _file_static_routes {
    my($self) = shift();
    my($buf) = '';
    my($seen_network) = {};
    foreach my $x (@_) {
        my($device, $domain) = _assert_interface_and_domain($self, $x);
        _trace($device, ' ', $domain)
            if $_TRACE;
        my($ip) = _dig($domain);
        my($routes) = _static_routes_for($ip);
        next unless defined($routes);
        _trace($routes)
            if $_TRACE;
        foreach my $network (keys %$routes) {
            my($mask) = _mask_for($network);
            unless (exists($seen_network->{$network.'/'.$mask})) {
                $buf .= sprintf("%s net %s netmask %s gw %s\n",
                                $device, $network,
                                _bits2netmask($self, $mask),
                                _dig($routes->{$network}));
            }
            $seen_network->{$network.'/'.$mask}++;
        }
    }
    return $buf eq '' ? () : ('etc/sysconfig/static-routes',
                              \(_prepend_auto_generated_header($buf)));
}

sub _gateway_for {
    return _dig(_network_config_for(shift)->{gateway});
}

sub _gen_append_cmds {
    return map(['$', "$_\n", qr{^\Q$_\E$}m], @_);
}

sub _get_networks_config {
    return $_CFG->{networks};
}

sub _mask_for {
    return _network_config_for(shift)->{mask};
}

sub _maybe_write {
    my($filename, $data) = @_;
    return unless defined($filename) && defined($data);
    return _write($filename, $data);
}

sub _mkdir {
    my($self, $dir, $perms) = @_;
    # Creates dir if it doesn't exist
    $dir = _prefix_file($dir);
    return '' if -d $dir;
    return "Would have created: $dir\n" if $self->unsafe_get('noexecute');
    return "Created " . Bivio::IO::File->mkdir_p($dir, $perms) . "\n";
}

sub _network_config_for {
    return $_CFG->{networks}->{shift()};
}

sub _network_for {
    return _network_config_for(shift)->{network};
}

sub _optional {
    my($self, $file, $op, @args) = @_;
    return -f _prefix_file($file) ? $op->($self, $file, @args) : '';
}

sub _prefix_file {
    my($file) = @_;
    # Adds root_prefix to $file.
    return $_CFG->{root_prefix} ? "$_CFG->{root_prefix}$file" : $file;
}

sub _prepend_auto_generated_header {
    my($data) = @_;
    return <<'EOF' . $data;
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: Bivio::Util::LinuxConfig
################################################################
EOF
}

sub _replace_param {
    my($self, $file, @op) = @_;
    return _edit(
        $self,
        $file,
        [Bivio::Die->eval_or_die(q(sub {
            my($data) = @_;
            my($got) = 0;
        ) . join("\n", map(
            "\$got += \$\$data =~ s{^$_->[0].*}{\${1}$_->[1]}m;",
            @op,
        )) . q(
            return $got;
        }))],
    );
}

sub _static_routes_for {
    return _network_config_for(shift)->{static_routes};
}

sub _write {
    my($filename, $data) = @_;
    #TODO: figure out the permissions and use _add_file() instead
    $filename = _prefix_file($filename);
    _trace($filename)
        if $_TRACE;
    Bivio::IO::File->mkdir_parent_only($filename);
    Bivio::IO::File->write($filename, $data);
    return;
}

1;
