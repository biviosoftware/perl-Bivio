# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Backup;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::IO::Trace;
use IO::File ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
Bivio::IO::Config->register({
    Bivio::IO::Config->NAMED => {
	mirror_dest_host => Bivio::IO::Config->REQUIRED,
	mirror_include_dirs => Bivio::IO::Config->REQUIRED,
	mirror_dest_dir => Bivio::IO::Config->REQUIRED,
	rsync_flags => '-azlSR --delete',
    },
});
my($_D) = __PACKAGE__->use('Type.Date');
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_F) = __PACKAGE__->use('IO.File');

sub USAGE {
    return <<'EOF';
usage: b-backup [options] command [args...]
commands:
    archive_mirror_link root date [min_kb] -- tar "link" to "weekly" or "archive"
    mirror [cfg_name ...] -- mirror configured dirs to mirror_host
    trim_directories dir max -- returns directories to trim
EOF
}

sub archive_mirror_link {
    my($self, $root, $date, $min_kb) = shift->name_args(
	['String', 'Date', '?Integer'],
	\@_,
    );
    $date = $_D->to_file_name($date);
    $root = $_F->absolute_path($root);
    my($link) = "$root/mirror/link/$date";
    $self->usage_error($link, ': does not exist')
	unless -d $link;
    $min_kb ||= 0x40000;
    return
	unless my $archive = _which_archive($self, $root, $date);
    $_F->mkdir_p($archive, 0700);
    $_F->do_in_dir($link, sub {
        foreach my $top (glob('*')) {
	    my($dirs) = [];
	    my($du) = IO::File->new;
	    Bivio::die->die($top, ": du failed: $!")
	        unless $du->open("du -k '$top' | sort -nr |");
	    while (defined(my $line = readline($du))) {
		my($n, $d) = split(/\s+/, $line, 2);
		chomp($d);
		last
		    if @$dirs && $n < $min_kb;
		push(@$dirs, $d);
	    }
	    # Directories with same size may come out in any order
	    $dirs = [sort(@$dirs)];
	    $du->close;
	    while (my $src = shift(@$dirs)) {
		my($dst) = "$archive/$src.tgz";
		$_F->mkdir_parent_only($dst, 0700);
		$self->piped_exec(
		    ['tar', 'czfX', $dst, '-', $src],
		    \(join("\n", @$dirs)),
		);
	    }
	}
	return;
    });
    $self->piped_exec("chmod -R -w $archive");
    return $archive;
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
	my($host, $dir, $flags)
	    = @$cfg{qw(mirror_dest_host mirror_dest_dir rsync_flags)};
	if ($host) {
	    $self->piped_exec_remote($host, "mkdir -p $dir");
	    $dir = "$host:$dir";
	}
	else {
	    $_F->mkdir_p($dir, 0700);
	}
	$res .= ${$self->piped_exec(
	    "rsync -e ssh --timeout 43200"
	    . ($self->unsafe_get('noexecute') ? ' -n' : '')
	    . ($_TRACE ? ' --progress' : '')
	    . " $flags '"
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
    my($self, $root, $num) = shift->name_args(['String', 'Integer'], \@_);
    my($dirs) = [reverse(sort(glob("$root/20" . ('[0-9]' x 6))))];
    return
	if @$dirs <= $num;
    $dirs = [reverse(splice(@$dirs, $num))];
    foreach my $d (@$dirs) {
	system('chmod', '-R', 'ug+w', $d);
	Bivio::IO::Alert->warn($d, ': unable to delete')
            unless system('rm', '-rf', $d) == 0;
    }
    return 'Removed: ' . join(' ', @$dirs);
}

sub _which_archive {
    my($self, $root, $date) = @_;
    my($archive) = "$root/archive/$date";
    (my $glob = $archive) =~ s/\d\d$/??/;
    return $archive
	unless @{[glob($glob)]};
    $archive = "$root/weekly/$date";
    $date = $_D->from_literal_or_die($date);
    my($dow) = $_D->english_day_of_week($date);
    foreach my $d ($_D->english_day_of_week_list) {
	my($x) = "$root/weekly/" . $_D->to_file_name($date);
	return if -e $x;
	last if $d eq $dow;
	$date = $_D->add_days($date, -1);
    }
    return $archive;
}

1;
