# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Backup;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::IO::Trace;

# C<Bivio::Util::Backup> is a mirroring utility.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
Bivio::IO::Config->register({
    Bivio::IO::Config->NAMED => {
	mirror_dest_host => Bivio::IO::Config->REQUIRED,
	mirror_include_dirs => Bivio::IO::Config->REQUIRED,
	mirror_dest_dir => Bivio::IO::Config->REQUIRED,
    },
});
my($_D) = __PACKAGE__->use('Type.Date');

sub USAGE {
    # Returns:
    #
    #  usage: b-backup [options] command [args...]
    #  commands:
    #     mirror [cfg_name ...] -- mirror configured dirs to mirror_host
    return <<'EOF';
usage: b-backup [options] command [args...]
commands:
    mirror [cfg_name ...] -- mirror configured dirs to mirror_host
    trim_directories dirs-with-dates -- returns directories to trim
EOF
}

sub handle_config {
    # All configuration may be named.
    #
    #
    # mirror_dest_dir : string (required)
    #
    # Directory on I<mirror_dest_dir> to copy files.
    #
    # mirror_dest_host : string (required)
    #
    # Host to mirror to.
    #
    # mirror_include_dirs : array_ref (required)
    #
    # List of directories to mirror.  Must be absolute.
    return;
}

sub mirror {
    my($self, @cfg_name) = @_;
    # Mirror files to I<cfg_name>'d host and directory.  I<cfg_name> may be
    # C<undef> iwc defaults are used.
    #
    # Uses the command: rsync -e ssh -azlSR --delete --timeout 43200
    my($res) = '';
    foreach my $cfg_name (@cfg_name ? @cfg_name : ('')) {
	my($cfg) = Bivio::IO::Config->get($cfg_name);
	my($host, $dir) = @$cfg{qw(mirror_dest_host mirror_dest_dir)};
	if ($host) {
	    $self->piped_exec_remote($host, "mkdir -p $dir");
	    $dir = "$host:$dir";
	}
	else {
	    $self->use('IO.File')->mkdir_p($dir, 0700);
	}
	$res .= ${$self->piped_exec(
	    "rsync -e ssh -azlSR --delete --timeout 43200"
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

sub trim_directories {
    my($self, @files) = shift->arg_list(\@_, [['String']]);
    my($files) = {map(
	(($_ =~ /(\d{8})/)[0] || $self->usage_error($_, ': no date value'),
	 $_),
	@files,
    )};
    $self->usage_error('duplicate date in date list')
	unless @files == keys(%$files);
    my($prev_month) = $_D->get_previous_month(
	$_D->date_from_parts(1, $_D->get_parts(
	    $_D->local_today, 'month', 'year')));
    my($trim) = {};
    foreach my $date (
	sort(
	    grep($_D->compare($_D->from_literal_or_die($_), $prev_month) < 0,
		 keys(%$files))),
    ) {
	push(
	    @{$trim->{($date =~ /^(\d{6})/)[0] || die} ||= []},
	    $date,
	);
    }
    return join(' ', map(
	$files->{$_},
	map(splice(@{$trim->{$_}}, 1), sort(keys(%$trim))),
    ));
}

1;
