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

=for html <a name="make_serial_console"></a>

=head2 make_serial_console()

Makes a serial console on ttyS0.  Modifies grub.conf, securetty, and
inittab.   May be called repeatedly.

=cut

sub make_serial_console {
    my($self) = @_;
    _insert('/etc/securetty', ['^', "/dev/ttyS0\n"]);
    _insert('/etc/inittab', ['(?<=getty tty6\n)',
	"S0:2345:respawn:/sbin/agetty ttyS0 38400\n"]);
    _insert('/etc/grub.conf', ['(?<!\#)splashimage', '#splashimage'],
	["(?=\n\tinitrd)", ' console=ttyS0,38400'],
	["\ntimeout=10\n", <<'EOF']);

timeout=5
serial --unit=0 --speed=38400
terminal --timeout=1 serial
EOF
    return;
}

#=PRIVATE METHODS

# _insert(string file, array_ref op)
#
# Inserts a value into a file.
#
sub _insert {
    my($file, @op) = @_;
    $file = "$_CFG->{root_prefix}$file" if $_CFG->{root_prefix};
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

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
