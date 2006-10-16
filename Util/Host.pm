# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Host;
use strict;
$Bivio::Util::Host::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::Host::VERSION;

=head1 NAME

Bivio::Util::Host - control commands on this host

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::Host;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::Host::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::Host>

=cut

=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns usage.

=cut

sub USAGE {
    return <<'EOF';
usage: b-host [options] command [args...]
commands:
    exec_if host command... args -- execs command and arguments only on host
EOF
}

#=IMPORTS
use Socket ();

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="exec_if"></a>

=head2 exec_if(string host, string command, string arg, ...) : string

Does not return if successful.  If B<noexecute> is set, outputs what
it would do.

Enclose command as a single string if you want shell interpretation
(normal Perl exec rules).

Tries to bind to the address to a UDP socket.  You must have privs to open
"any" socket.

=cut

sub exec_if {
    my($self, $host, @cmd) = @_;
    socket(SOCKET, Socket::PF_INET(), Socket::SOCK_DGRAM(),
	getprotobyname('udp'))
	or Bivio::Die->die("Cannot create socket: $!");
    if (bind(SOCKET, Socket::pack_sockaddr_in(0,
	(gethostbyname($host))[4]
	|| Bivio::Die->die("$host: gethostbyname error: $!")))) {
	return "Would have executed: @cmd\n" if $self->unsafe_get('noexecute');
	exec(@cmd) || Bivio::Die->die("Exec failed: @cmd: $!");
	# DOES NOT RETURN
    }
    return $self->unsafe_get('noexecute') ? "Not this host\n" : undef;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
