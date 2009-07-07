# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Backup;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::IO::Trace;
use IO::File ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
use File::Find ();
my($_D) = b_use('Type.Date');
my($_DT) = b_use('Type.DateTime');
my($_F) = b_use('IO.File');
Bivio::IO::Config->register(my $_CFG = {
    Bivio::IO::Config->NAMED => {
	mirror_dest_host => Bivio::IO::Config->REQUIRED,
	mirror_include_dirs => Bivio::IO::Config->REQUIRED,
	mirror_dest_dir => Bivio::IO::Config->REQUIRED,
	rsync_flags => '-azlSR --delete',
    },
    min_kb => 0x40000,
});

sub USAGE {
    return <<'EOF';
usage: b-backup [options] command [args...]
commands:
    archive_logs mirror_dir archive_dir -- copy non-existent
    archive_mirror_link root date -- tar "link" to "weekly" or "archive"
    compress_log_dirs root [max_days] -- tars and gzips log dirs
    mirror [cfg_name ...] -- mirror configured dirs to mirror_host
    remote_archive root date host dev -- copies dirs to remote system
    trim_directories dir max -- returns directories to trim
EOF
}

sub archive_logs {
    my($self, $root, $date) = shift->name_args(
	[[qw(mirror_dir String)], [qw(archive_dir String)]],
	\@_,
    );
    my($res) = [];
    return @$res ? $res : ();
}

sub archive_mirror_link {
    my($self, $root, $date) = shift->name_args(
	['String', 'Date'],
	\@_,
    );
    $date = $_D->to_file_name($date);
    $root = $_F->absolute_path($root);
    my($link) = "$root/mirror/link/$date";
    $self->usage_error($link, ': does not exist')
	unless -d $link;
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
		    if @$dirs && $n < $_CFG->{min_kb};
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

sub compress_and_trim_log_dirs {
    my($self, $root_dir, $num_keep) = shift->name_args(
	['String', [qw(num_keep Integer 30)]],
	\@_,
    );
    $self->req;
    my($dirs) = {};
    File::Find::find({
	no_chdir => 1,
	follow => 1,
	wanted => sub {
	    return
		unless -d $_
		&& $_ =~ m{(.+)/(\d{8}(?:\d{6})?)$};
	    push(@{$dirs->{$1} ||= []}, $2);
            $File::Find::prune = 1;
	    return;
	},
    }, $root_dir);
    my($res) = 'Compressed:';
    foreach my $dir (sort(keys(%$dirs))) {
	my($sort) = [sort(@{$dirs->{$dir}})];
	pop(@$sort);
	foreach my $d (map("$dir/$_", @$sort)) {
	    $self->piped_exec("tar czf '$d.tgz' '$d' 2>&1 && chmod -w '$d.tgz'");
	    $res .= " $d";
	    Bivio::IO::File->rm_rf($d);
	}
    }
    $res .= "\n";
    $dirs = {};
    File::Find::find({
	no_chdir => 1,
	follow => 1,
	wanted => sub {
	    return
		unless -f $_
		&& $_ =~ m{(.+)/(\d{8}(?:\d{6})?\.tgz)$};
	    push(@{$dirs->{$1} ||= []}, $2);
            $File::Find::prune = 1;
	    return;
	},
    }, $root_dir);
    $res .= 'Deleted:';
    foreach my $dir (sort(keys(%$dirs))) {
	my($sort) = [sort(@{$dirs->{$dir}})];
	splice(@$sort, -$num_keep);
	foreach my $d (map("$dir/$_", @$sort)) {
	    $res .= " $d";
	    unlink($d) || b_die("unlink($d): $!");
	}
    }
    $res .= "\n";
    return $res;
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

sub remote_archive {
    my($self, $root, $date, $host, $dev) = shift->name_args(
	['String', 'Date', 'String', 'String'],
	\@_,
    );
    $date = $_D->to_file_name($date);
    $root = $_F->absolute_path($root);
    my($link) = "$root/mirror/link/$date";
    $self->usage_error($link, ': does not exist')
	unless -d $link;
    my($mount) = "$root/remote_archive";
    my($archive) = "$mount/$date";
    $self->piped_exec_remote($host, "umount $dev", undef, 1);
    $self->piped_exec_remote($host, "umount $mount", undef, 1);
    $self->piped_exec_remote($host, "mke2fs -b 4096 -m 0 -N 4194304 -O dir_index -O sparse_super $dev", "y\n");
    $self->piped_exec_remote($host, "mkdir -p $mount");
    $self->piped_exec_remote($host, "mount $dev $mount");
    foreach my $other ("$root/weekly", "$root/archive") {
	next
	    unless -d (my $src = "$other/$date");
	$self->piped_exec("rsync -a -e ssh --timeout 43200 $src $host:$mount");
	$mount = undef;
	last;
    }
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
		    if @$dirs && $n < $_CFG->{min_kb};
		push(@$dirs, $d);
	    }
	    # Directories with same size may come out in any order
	    $dirs = [sort(@$dirs)];
	    $du->close;
	    while (my $src = shift(@$dirs)) {
		my($dst) = "$archive/$src.tgz";
		# remote shell requires this to be practical
		$dst =~ s/[\'\"\s]+/_/g;
		$self->piped_exec_remote(
		    $host,
		    "mkdir -p '" .  File::Basename::dirname($dst) . "'",
		);
		$self->piped_exec(
		    "tar czfX - - '$src' | "
		    . "ssh $host dd of='$dst' bs=1000",
		    \(join("\n", @$dirs)),
		);
	    }
	}
	return;
    }) if $mount;
    $self->piped_exec_remote($host, "chmod -R -w $archive; umount $dev");
    return $archive;
}

sub trim_directories {
    my($self, $root, $num_keep) = shift->name_args([
	[qw(root String)],
	[qw(num_keep Integer)],
    ], \@_);
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
