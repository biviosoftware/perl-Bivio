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

C<Bivio::Util::LinuxConfig>

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
    relay_domains host ... -- add hosts to sendmail relay-domains
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
    my(undef, @host) = @_;
    my($f) = '/etc/mail/relay-domains';
    return _add_file($f, 'root', 'mail', 0640)
	. _insert_text($f, ['^', join("\n", @host) . "\n"]);
}

=for html <a name="serial_console"></a>

=head2 serial_console() : string

Makes a serial console on ttyS0.  Modifies grub.conf, securetty, and
inittab.   May be called repeatedly.

=cut

sub serial_console {
    my($self) = @_;
    return _insert_text('/etc/securetty', ['^', "/dev/ttyS0\n"])
	. _insert_text('/etc/inittab', ['(?<=getty tty6\n)',
	    "S0:2345:respawn:/sbin/agetty ttyS0 38400\n"])
        . _insert_text('/etc/grub.conf',
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
    return _insert_text('/etc/ssh/sshd_config', map {
	my($param, $value) = @$_;
	["(?<=\n)\\s*#?\\s*$param\[^\n+]", "$param $value"],
    } @{$self->group_args(2, \@args)});
}

#=PRIVATE METHODS

# _add_file(string file, string owner, string group, int perms)
#
# Creates the file if it doesn't exist.
#
sub _add_file {
    my($file, $owner, $group, $perms) = @_;
    $file = _prefix_file($file);
    return '' if -e $file;
    Bivio::IO::File->write($file, '');
    Bivio::IO::File->chown_by_name($owner, $group, $file)
	if $> == 0;
    Bivio::IO::File->chmod($perms, $file);
    return "$file: created\n";
}

# _insert_text(string file, array_ref op)
#
# Inserts a value into a file.
#
sub _insert_text {
    my($file, @op) = @_;
    $file = _prefix_file($file);
    my($data) = Bivio::IO::File->read($file);
    my($got);
    foreach my $op (@op) {
	my($where, $value) = @$op;
	next if $$data =~ /\Q$value/s;
	$$data =~ s/$where/$value/sg
	    || Bivio::Die->die($file, ": didn't find /", $where, "/\n");
	$got++;
    }
    return '' unless $got;
    system("cp -a $file $file.bak");
    Bivio::IO::File->write($file, $data);
    return "$file: updated\n";
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
