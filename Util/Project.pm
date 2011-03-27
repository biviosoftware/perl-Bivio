# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Project;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use File::Find ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
    my($default_prefix) = $default->get('local_file_prefix');
    b_die($default_prefix, ': local_file_prefix not found')
	unless -d $default_prefix;
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
		$file =~ s,^$default_prefix,,;
		foreach my $prefix (@$prefixes) {
		    my($destination) = $prefix . $file;
		    next
			if -e $destination;
		    if (-d $File::Find::name) {
			Bivio::IO::File->mkdir_p($destination);
			next;
		    }
		    my($up) = $File::Find::dir;
		    $up =~ s,[^/]+,..,g;
		    b_die($!)
			unless symlink("$up/$File::Find::name", $destination);
		}
		return;
	    },
	},
	$default_prefix,
    );
    return;
}

1;
