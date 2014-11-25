# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::VC;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.ClassLoaderAUTOLOAD');

b_use('IO.Config')->register(my $_CFG = {
    git_root_list => [
	'https://github.com/biviosoftware',
    ],
    svn_root_list => [],

});

sub CONTROL_DIR_FIND_PREDICATE {
    return q{'(' -name CVS -o -name .git -o -name .svn ')'};
}

sub CONTROL_DIR_RE {
    return qr{(?:^|/)(?:CVS|\.git|\.svn)(?:/|$)};
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
    my($version) = @_ > 1 ? shift(@_) : undef;
    my($module) = @_;
    _checkout_rsync($self, $module, $version)
	|| _checkout_svn($self, $module, $version)
	|| _checkout_git($self, $module, $version)
	|| _checkout_cvs($self, $module, $version);
    return;
}

sub _checkout_cvs {
    my($self, $module, $version) = @_;
    return _update_or_fresh(
	$self,
	$module,
	$version,
	sub {
	    $self->piped_exec([qw(cvs -Q update -d), $module]);
	    return;
	},
	sub {
	    my($v) = @_;
	    $self->piped_exec([qw(cvs -Q checkout -f -r), $v, $module]);
	    return;
	},
    );
}

sub _checkout_git {
    my($self, $module, $version) = @_;
    my($git_dir) = $module;
    #TODO: Share with Dev
    $git_dir =~ s{/}{-}g;
    my($repo);
    foreach my $r (@{$_CFG->{git_root_list} || []}) {
	my($res) = "$r/$git_dir";
	if (!Bivio_Die()->catch_quietly(
	    sub {$self->piped_exec("git ls-remote $res 2>&1")},
	)) {
	    $repo = $res;
	    last;
	}
    }
    return 0
	unless $repo;
    _update_or_fresh(
	$self,
	$module,
	$version,
	sub {
	    IO_File()->do_in_dir(
		$module,
		sub {$self->piped_exec([qw(git pull)])},
	    );
	    return;
	},
	sub {
	    my($v) = @_;
	    $self->piped_exec([qw(git clone), $v eq 'HEAD' ? () : (-b => $v), $repo]);
	    if ($git_dir ne $module) {
		IO_File()->mkdir_parent_only($module);
		IO_File()->rename($git_dir, $module);
	    }
	    return;
	},
    );
    return 1;
}

sub _checkout_rsync {
    my($self, $module, $version) = @_;
    return 0
	unless ($ENV{BIVIO_UTIL_VC_ROOT} || '') =~ m{^/} && -d $ENV{BIVIO_UTIL_VC_ROOT};
    my($repo) = "$ENV{BIVIO_UTIL_VC_ROOT}/$module";
    IO_Config()->assert_dev;
    b_info("copying files from $repo, not checking out");
    my($md) = IO_File()->absolute_path($module);
    if (-d $md) {
	system('chmod', '-R', 'u+w', $md);
	IO_File()->rm_rf($md);
    }
    my($p) = IO_File()->mkdir_parent_only($md);
    system('rsync', '-aq', '--exclude=.git', '-filter=:- .gitignore', $repo, $p);
    IO_File()->rename("$p/" . File::Basename::basename($repo), $md);
    system('chmod', '-R', 'u+w', $md);
    return 1;
}

sub _checkout_svn {
    my($self, $module, $version) = @_;
    my($repo);
    foreach my $r (@{$_CFG->{svn_root_list} || []}) {
	my($res) = "$r/$module";
	if (!Bivio_Die()->catch_quietly(
	    sub {$self->piped_exec("svn log '$res' 2>&1")},
	)) {
	    $repo = $res;
	    last;
	}
    }
    return 0
	unless $repo;
    _update_or_fresh(
	$self,
	$module,
	$version,
	sub {
	    IO_File()->do_in_dir(
		$module,
		sub {$self->piped_exec([qw(svn update), $repo])},
	    );
	    return;
	},
	sub {
	    my($v) = @_;
	    IO_File()->do_in_dir(
		IO_File()->mkdir_parent_only($module),
		sub {$self->piped_exec([qw(svn checkout -r), $v, $repo])},
	    );
	    return;
	},
    );
    return 1;
}

sub _update_or_fresh {
    my($self, $module, $version, $update, $fresh) = @_;
    if (-d $module) {
	if ($version) {
	    $self->usage_error($module,': module exists and version supplied');
	}
	$update->();
	return;
    }
    $fresh->($version || 'HEAD');
    return;
}

1;
