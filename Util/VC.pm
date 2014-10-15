# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::VC;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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

sub u_checkout {
   my($self) = shift;
   # 'perl-IEEE' where
   my($version) = @_ > 1 ? shift(@_) : undef;
   my($module) = @_;
   if (-d $module) {
       if ($version) {
	   $self->usage_error($module,': module exists and version supplied');
       }
       $self->piped_exec([qw(cvs -Q update -d), $module]);
   }
   $self->piped_exec([qw(cvs -Q checkout -f -r), $version || 'HEAD', $module]);
#git clone -n git://path/to/the_repo.git --depth 1
#    Then check out just the file you want like so:
#    cd the_repo
#	git checkout HEAD name_of_file
   return;
}

1;
