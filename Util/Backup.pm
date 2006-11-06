# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Backup;
use strict;
$Bivio::Util::Backup::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::Backup::VERSION;

=head1 NAME

Bivio::Util::Backup - mirroring utilities

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::Backup;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::Backup::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::Backup> is a mirroring utility.

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:

 usage: b-backup [options] command [args...]
 commands:
    mirror [cfg_name ...] -- mirror configured dirs to mirror_host

=cut

sub USAGE {
    return <<'EOF';
usage: b-backup [options] command [args...]
commands:
    mirror [cfg_name ...] -- mirror configured dirs to mirror_host
EOF
}

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::IO::File;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
Bivio::IO::Config->register({
    Bivio::IO::Config->NAMED => {
	mirror_dest_host => Bivio::IO::Config->REQUIRED,
	mirror_include_dirs => Bivio::IO::Config->REQUIRED,
	mirror_dest_dir => Bivio::IO::Config->REQUIRED,
    },
});

=head1 METHODS

=cut

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

All configuration may be named.

=over 4

=item mirror_dest_dir : string (required)

Directory on I<mirror_dest_dir> to copy files.

=item mirror_dest_host : string (required)

Host to mirror to.

=item mirror_include_dirs : array_ref (required)

List of directories to mirror.  Must be absolute.

=back

=cut

sub handle_config {
    return;
}


=for html <a name="mirror"></a>

=head2 mirror(string cfg_name, ...) : string_ref

Mirror files to I<cfg_name>'d host and directory.  I<cfg_name> may be
C<undef> iwc defaults are used.

Uses the command: rsync -e ssh -azlSR --delete --timeout 3600

=cut

sub mirror {
    my($self, @cfg_name) = @_;
    my($res) = '';
    foreach my $cfg_name (@cfg_name ? @cfg_name : ('')) {
	my($cfg) = Bivio::IO::Config->get($cfg_name);
	my($host, $dir) = @$cfg{qw(mirror_dest_host mirror_dest_dir)};
	if ($host) {
	    $self->piped_exec_remote($host, "mkdir -p $dir");
	    $dir = "$host:$dir";
	}
	else {
	    Bivio::IO::File->mkdir_p($dir, 0700);
	}
	$res .= ${$self->piped_exec(
	    "rsync -e ssh -azlSR --delete --timeout 3600"
	    . ($self->unsafe_get('noexecute') ? ' -n' : '')
	    . ($_TRACE ? ' --progress' : '')
	    . " '"
	    . join("' '", map {
		 Bivio::Die->die($_, ': mirror_include_dirs must be absolute')
		     unless $_ =~ m!^/!;
		 $_;
	      } @{$cfg->{mirror_include_dirs}})
	    . "' $dir 2>&1",
	)};
    }
    return \$res;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
