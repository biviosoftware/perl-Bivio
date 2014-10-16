# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::VC;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
b_use('IO.Config')->register(my $_CFG = {
    module_map => {
	'perl/Cal54' => 'https://github.com/biviosoftware/perl-Cal54.git',
    },
});

sub CONTROL_DIR_GLOB {
    return '{CVS,.git}';
}

sub CONTROL_DIR_RE {
    return qr{(?:^|/)(?:CVS|.git)(?:/|$)};
}

sub USAGE {
    return <<'EOF';
usage: bivio vc [options] command [args..]
commands
  checkout [version] module -- get copy from repo [version=HEAD]
EOF
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub u_checkout {
   my($self) = shift;
   # 'perl-IEEE' where
   my($version) = @_ > 1 ? shift(@_) : undef;
   my($module) = @_;
   my($repo) = $_CFG->{module_map}->{$module} || $module;
   my($git_dir) = $repo =~ m{([^/]+)\.git$};
   # 'git clone -b 2.4 --single-branch https://github.com/Itseez/opencv.git opencv-2.4'
   if (-d $module) {
       if ($version) {
	   $self->usage_error($module,': module exists and version supplied');
       }
       if ($git_dir) {
	   IO_File()->do_in_dir(
	       $module,
	       sub {$self->piped_exec(['git pull'])},
	   );
       }
       else {
	   $self->piped_exec([qw(cvs -Q update -d), $repo]);
       }
   }
   $version ||= 'HEAD';
   if ($git_dir) {
       $self->piped_exec([qw(git clone), $version eq 'HEAD' ? () : (-b => $version), $repo]);
       IO_File->mkdir_parent_only($module);
       IO_File->rename($git_dir, $module);
       return;
   }
   $self->piped_exec([qw(cvs -Q checkout -f -r), $version, $repo]);
   return;
}

1;
