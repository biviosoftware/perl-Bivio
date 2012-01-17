# Copyright (c) 2011-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Project;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use File::Find ();

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

sub link_facade_files {
    my($self) = @_;
    $self->initialize_fully;
    my($default) = b_use('UI.Facade')->get_instance;
    $_F->do_in_dir(
	$default->get_local_file_root,
	sub {
	    my($default_prefix) = $default->get('local_file_prefix');
	    b_die($default_prefix, ': local_file_prefix not found')
		unless -d $default_prefix;
	    if ($_C->is_dev) {
		my($common) = "$ENV{HOME}/src/perl/Bivio/files";
		my($common_b) = $default->get_local_file_name(
		    'PLAIN',
		    $default->get_local_file_plain_common_uri,
		);
		unless (-l $common_b) {
		    b_die("symlink($common_b): $!")
			unless symlink($common, $common_b);
		}
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
				Bivio::IO::File->mkdir_p($destination);
				next;
			    }
			    my($up) = $File::Find::dir;
			    $up =~ s,[^/]+,..,g;
			    next if $File::Find::name =~ /\.cvsignore/;
			    b_die($!)
				unless symlink("$up/$File::Find::name", $destination);
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

1;
