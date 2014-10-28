# Copyright (c) 2002-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Backup;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use File::Find ();
use IO::File ();
b_use('IO.ClassLoaderAUTOLOAD');

our($_TRACE);
b_use('IO.Trace');
my($_C) = b_use('IO.Config');
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('IO.File');
my($_LINK) = 'link';
my($_DATE_RE) = qr{(.+)/(\d{8}(?:\d{6})?)};
$_C->register(my $_CFG = {
    $_C->NAMED => {
	mirror_dest_host => $_C->REQUIRED,
	mirror_include_dirs => $_C->REQUIRED,
	mirror_dest_dir => $_C->REQUIRED,
	rsync_flags => '-azlSR --delete',
    },
    min_kb => 0x40000,}
);

sub USAGE {
    return <<'EOF';
usage: b-backup [options] command [args...]
commands:
    archive_logs mirror_dir archive_dir -- copy gz files in /var/log
    archive_mirror_link root date -- tar "link" to "weekly" or "archive"
    archive_weekly snapshot weekly -- tar "snapshot" to "weekly"
    compress_log_dirs root [max_days] -- tars and gzips log dirs
    mirror [cfg_name ...] -- mirror configured dirs to mirror_host
    trim_directories dir max -- returns directories to trim
    zfs_snapshot file_system snapshot_date num_keep ... -- take a snapshot
    zfs_snapshot_trim file_system num_keep -- trims snapshots with this root
EOF
}

sub archive_logs {
    my($self, $mirror_dir, $archive_dir) = shift->name_args(
	[[qw(mirror_dir String)], [qw(archive_dir String)]],
	\@_,
    );
    #PERLBUG: $_DATE_RE is not visible in the second sub {}.
    #         Precompiling the regexp in a local variable fixes
    #         the problem, and it's a loop invariant anyway.
    my($date_gz) = qr{$_DATE_RE.*gz$};
    return $self->lock_action(sub {
        my($res) = [];
	File::Find::find({
	    no_chdir => 1,
	    follow => 0,
	    wanted => sub {
		return
		    unless $_ =~ $date_gz && -f $_;
		my($year) = $2 =~ /^(\d{4})/;
		(my $tgt = $_) =~ s{^\Q$mirror_dir\E}{$archive_dir/$year};
		return
		    if -f $tgt;
		$_F->mkdir_parent_only($tgt);
		$self->piped_exec("cp -p '$_' '$tgt'");
		$_F->chmod(0400, $tgt);
		push(@$res, $tgt);
		return;
	    },
	}, glob("$mirror_dir/*.*/var/log"));
	return @$res ? [sort(@$res)] : ();
    });
}

sub archive_mirror_link {
    my($self, $root, $date) = shift->name_args(
	['String', 'Date'],
	\@_,
    );
    return $self->archive_weekly(
	"$root/mirror/$_LINK/" . $_D->to_file_name($date),
	"$root/weekly",
    );
}

sub archive_weekly {
   sub ARCHIVE_WEEKLY {[
	[qw(snapshot String)],
	[qw(weekly String)],
   ]}
   my($self, $bp) = shift->parameters(\@_);
   return $self->lock_action(sub {
	$self->usage_error($bp->{snapshot}, ': does not exist')
	    unless -d $bp->{snapshot};
	return ''
	    unless my $archive
	    = _archive_if_none_this_week(
		$self,
		Type_FilePath()->add_trailing_slash(
		    $_F->absolute_path($bp->{weekly})),
		$_D->from_literal_or_die($bp->{snapshot} =~ /(\d+)$/),
	    );
	$_F->do_in_dir(
	    $bp->{snapshot},
	    sub {_archive_create($self, $archive)},
	);
	return $archive;
   });
}

sub compress_and_trim_log_dirs {
    my($self, $root_dir, $num_keep) = shift->name_args(
	['String', [qw(num_keep Integer 30)]],
	\@_,
    );
    return $self->lock_action(sub {
	$self->req;
	my($deleted) = '';
	my($compressed) = '';
        my($dirs) = {};
	File::Find::find({
	    no_chdir => 1,
	    follow => 0,
	    wanted => sub {
		return
		    unless -d $_
		    && $_ =~ qr{$_DATE_RE$}o;
		push(@{$dirs->{$1} ||= []}, $2);
		$File::Find::prune = 1;
		return;
	    },
	}, $root_dir);
	foreach my $dir (sort(keys(%$dirs))) {
	    my($sort) = [sort(@{$dirs->{$dir}})];
	    pop(@$sort);
	    foreach my $d (map("$dir/$_", @$sort)) {
		$self->piped_exec("tar czf '$d.tgz' '$d' 2>&1");
		$self->piped_exec("chmod -w '$d.tgz'");
		b_die('backup is writable: ', "$d.tgz")
		    if -w "$d.tgz";
		$compressed .= " $d";
		Bivio::IO::File->rm_rf($d);
	    }
	}
	$dirs = {};
	File::Find::find({
	    no_chdir => 1,
	    follow => 0,
	    wanted => sub {
		return
		    unless -f $_
		    && $_ =~ m{(.+)/(\d{8}(?:\d{6})?\.tgz)$};
		push(@{$dirs->{$1} ||= []}, $2);
		$File::Find::prune = 1;
		return;
	    },
	}, $root_dir);
	foreach my $dir (sort(keys(%$dirs))) {
	    my($sort) = [sort(@{$dirs->{$dir}})];
	    next
		unless @$sort > $num_keep;
	    splice(@$sort, -$num_keep);
	    foreach my $d (map("$dir/$_", @$sort)) {
		$deleted .= " $d";
		unlink($d) || b_die("unlink($d): $!");
	    }
	}
	return ($compressed && "Compressed:$compressed\n")
	    . ($deleted && "Deleted:$deleted\n");
    });
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
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
	my($cfg) = $_C->($cfg_name);
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
    my($self, $root, $num_keep) = shift->name_args([
	[qw(root String)],
	[qw(num_keep Integer)],
    ], \@_);
    return $self->lock_action(sub {
	my($dirs) = [reverse(sort(glob("$root/20" . ('[0-9]' x 6))))];
	return
	    if @$dirs <= $num_keep;
	$dirs = [reverse(splice(@$dirs, $num_keep))];
	foreach my $d (@$dirs) {
	    system('chmod', '-R', 'ug+w', $d);
	    Bivio::IO::Alert->warn($d, ': unable to delete')
		unless system('rm', '-rf', $d) == 0;
	}
	return 'Removed: ' . join(' ', @$dirs);
    });
}

sub zfs_snapshot {
    sub ZFS_SNAPSHOT {[
	[qw(file_system String)],
	[qw(snapshot_date Date)],
	[qw(snapshot_keep PositiveInteger)],
    ]}
    my($self, $bp) = shift->parameters(\@_);
    my($date) = $_D->to_file_name($bp->{snapshot_date});
    my($fs) = _zfs_file_system($self, $bp);
    return $self->lock_action(sub {
	my($snapshot) = $fs . '@' . $date;
	_do_backticks($self, [qw(zfs snapshot), $snapshot]);
	return "Created: $snapshot\n"
	    . $self->zfs_snapshot_trim($fs, $bp->{snapshot_keep});
    });
}

sub zfs_snapshot_trim {
    sub ZFS_SNAPSHOT_TRIM {[
	[qw(file_system String)],
	[qw(num_keep PositiveInteger)],
    ]}
    my($self, $bp) = shift->parameters(\@_);
    my($fs) = _zfs_file_system($self, $bp);
    return $self->lock_action(sub {
	my($snapshots) = [reverse(
	    sort(map(
		$_ =~ qr{^(\Q$fs\E\@[0-9]{8})\b}s ? $1 : (),
		_do_backticks($self, [qw(zfs list -t snapshot)]),
	    )),
	)];
	return ''
 	    if @$snapshots <= $bp->{num_keep};
	return 'Removed: '
	    . _zfs_destroy_snapshots(
		$self,
		[reverse(splice(@$snapshots, $bp->{num_keep}))],
	    )
	    . "\n";
    });
}

sub _archive_create {
    my($self, $archive) = @_;
    $_F->mkdir_p($archive, 0700);
    foreach my $top (glob('*')) {
	my($dirs) = [];
	my($du) = IO::File->new;
	b_die($top, ": du failed: $!")
	    unless $du->open("du -k --apparent-size @{[_quote($top)]} | sort -nr |");
	while (defined(my $line = readline($du))) {
	    my($n, $d) = split(/\s+/, $line, 2);
	    chomp($d);
	    last
		if @$dirs && $n < $_CFG->{min_kb};
	    push(@$dirs, $d);
	}
	$du->close;
	# Directories with same size may come out in any order
	$dirs = [sort(@$dirs)];
	while (my $src = shift(@$dirs)) {
	    my($dst) = _safe_path("$archive/$src.tgz");
	    $_F->mkdir_parent_only($dst, 0700);
	    $self->piped_exec(
		['tar', 'czfX', $dst, '-', $src],
		\(join("\n", @$dirs)),
	    );
	}
    }
    $self->piped_exec("chmod -R -w $archive");
    return;
}

sub _archive_if_none_this_week {
    my($self, $weekly, $date) = @_;
    my($archive) = $weekly . $_D->to_file_name($date);
    foreach my $count (1 .. 7) {
	return undef
	    if -e ($weekly . $_D->to_file_name($date));
	return $archive
	    if $_D->english_day_of_week($date) =~ /sun/i;
  	$date = $_D->add_days($date, -1);
    }
    b_die($archive, ': unable to find Sunday');
    # DOES NOT RETURN
}

sub _do_backticks {
    my($self, $cmd, $ignore_exit_code) = @_;
    return $self->do_backticks($cmd, $ignore_exit_code)
	unless $self->unsafe_get_request
        and my $data = $self->ureq('backup_bunit');
    $cmd = "@$cmd"
	if ref($cmd);
    my($res) = shift(@{$data->{_do_backticks}->{$cmd}});
    unless (defined($res)) {
	if (defined(my $re = $data->{_do_backticks}->{ignore})) {
	    return
		if $cmd =~ $re;
	}
	b_die($cmd, ': no backup_bunit data');
    }
    return wantarray ? split(/(?<=\n)/, $res) : $res;
}

sub _quote {
    my($path) = @_;
    $path =~ s/'/'"'"'/g;
    return "'$path'";
}

sub _safe_path {
    my($path) = @_;
    $path =~ s{[^-\w\./=,]+}{_}g;
    return $path;
}

sub _zfs_destroy {
    my($self, $fs) = @_;
    my($cmd) = [qw(zfs destroy), $fs];
    my($out);
    foreach my $try (1 .. 3) {
	$out = [_do_backticks($self, $cmd)];
	return $fs
	    unless @$out;
	last
	    unless grep($_ =~ /dataset is busy/, @$out);
	sleep(1);
    }
    b_die($cmd, ': failed: ', $out);
    # DOES NOT RETURN
}

sub _zfs_destroy_snapshots {
    my($self, $snapshots) = @_;
    return join(
	' ',
	map(
	    _zfs_destroy($self, $_),
	    @$snapshots,
	),
    );
}

sub _zfs_file_system {
    my($self, $bp) = @_;
    my($fs) = $bp->{file_system};
    if ($fs =~ m{^/}) {
	return $1
	    if _do_backticks($self, 'mount -t zfs') =~ m{^(\S+)\s+on\s+\Q$fs\E\s}m;
	$self->usage_error($fs, ': not a zfs file system');
    }
    return $fs
	if _do_backticks($self, "zfs list $fs") =~ m{^$fs\s+\d+}m;
    # Probably won't get here, because zfs list will fail and produce an error message
    $self->usage_error($fs, ': not a zfs dataset');
    # DOES NOT RETURN
}

1;
