# Copyright (c) 2011-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Project;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use File::Find ();
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = b_use('IO.File');
my($_C) = b_use('IO.Config');

sub USAGE {
    return <<'EOF';
usage: bivio Project [options] command [args..]
commands
  link_facade_files
EOF
}

sub generate_bootstrap_css {
    my($self, $facade) = @_;
    $self->initialize_fully;
    my($f) = UI_Facade()->get_instance($facade);
    IO_File()->do_in_dir(
	_join_with_plain($f, $f->get_local_file_plain_app_uri()),
	sub {
	    my($out) = _join_with_plain(
		$f, $f->get_local_file_plain_app_uri('/css/bootstrap.min.css'));
	    $self->are_you_sure("overwrite $out?")
		if -f $out;
	    my($b) = '';
	    _add_import_line('bootstrap.less', \$b);
	    foreach my $l (glob('less/*.less')) {
		_add_import_line($l, \$b);
	    }
	    _add_import_line('utilities.less', \$b);
	    my($include) = _join_with_plain(
		$f, $f->get_local_file_plain_common_uri('/bootstrap/less'));
	    my($tmp) = IO_File()->tmp_path($self->req);
	    IO_File()->write($tmp, \$b);
	    $self->piped_exec("lessc -x --include-path=$include $tmp $out");
	    $self->print_line("generation successful");
	},
    );
    return;
}

sub link_facade_files {
    my($self) = @_;
    $self->initialize_fully;
    my($default) = b_use('UI.Facade')->get_instance;
    $_F->do_in_dir(
	$default->get_local_file_root,
	sub {
	    my($default_prefix) = $default->get('local_file_prefix');
	    unless (-d $default_prefix) {
	        b_die($default_prefix, ': local_file_prefix not found')
		    unless -d 'ddl';
		(my $d = $default_prefix) =~ s{/}{}g;
		$_F->symlink('.', $d);
	    }
	    if ($_C->is_dev) {
		my($src) = $ENV{PERLLIB} =~ /src/ ? "$ENV{PERLLIB}/.."
		    : "$ENV{HOME}/src";
		my($common) = "$src/perl/Bivio/files";
		$_F->mkdir_p($common);
		foreach my $j (grep(
		    $_ !~ /CVS$/ && -d $_,
		    glob("$src/javascript/*"),
		    "$src/external/bootstrap",
		)) {
		    my($dest) = "$common/" . ($j =~ m{([^/]+)$})[0];
		    $_F->do_in_dir(
			$j,
			sub {
			    b_info("$j: make");
			    $self->piped_exec('make');
			    return;
			},
		    ) if -f "$j/Makefile";
		    $_F->symlink($j, $dest)
			unless -d $dest;
		}
		my($common_b) = $default->get_local_file_name(
		    'PLAIN',
		    $default->get_local_file_plain_common_uri,
		);
		$_F->symlink($common, $common_b)
		    unless -d $common_b;
	    }
	    my($prefixes) = [
		grep(
		    $_ ne $default_prefix,
		    map(
			$default->get_instance($_)->get('local_file_prefix'),
			@{$default->get_all_classes},
		    ),
		),
	    ];
	    File::Find::find(
		{
		    no_chdir => 1,
		    follow => 0,
		    wanted => sub {
			my($file) = $File::Find::name;
			return
			    if $file =~ m{/CVS(?:/|$)} || $file =~ /\~$/;
			return
			    unless $file =~ s,^$default_prefix,,;
			foreach my $prefix (@$prefixes) {
			    my($destination) = $prefix . $file;
			    next
				if -e $destination;
			    if (-d $File::Find::name && ! -l $File::Find::name) {
				$_F->mkdir_p($destination);
				next;
			    }
			    my($up) = $File::Find::dir;
			    $up =~ s,[^/]+,..,g;
			    next if $File::Find::name =~ /\.cvsignore/;
			    $_F->symlink("$up/$File::Find::name", $destination)
				unless -f $destination;
			}
			return;
		    },
		},
		$default_prefix,
	    );
	    return;
        },
    );
    return;
}

sub _add_import_line {
    my($file, $buffer) = @_;
    $$buffer .= '@import "' . $file . "\";\n";
    return;
}

sub _join_with_plain {
    my($facade, $path) = @_;
    return Type_FilePath()->join($facade->get_local_file_name('PLAIN'), $path);
}

1;
