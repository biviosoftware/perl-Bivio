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
});

sub CONTROL_DIR_FIND_PREDICATE {
    return q{'(' -name CVS -o -name .git ')'};
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
    my($version) = @_ > 1 ? shift(@_) : undef;
    my($module) = @_;
    if (($ENV{BIVIO_UTIL_VC_ROOT} || '') =~ m{^/} && -d $ENV{BIVIO_UTIL_VC_ROOT}) {
	return _checkout_rsync($self, $module, $version, "$ENV{BIVIO_UTIL_VC_ROOT}/$module");
    }
    my($git_dir) = $module;
    #TODO: Share with Dev
    $git_dir =~ s{/}{-}g;
    foreach my $r (@{$_CFG->{git_root_list} || []}) {
	my($res) = "$r/$git_dir";
	if (!Bivio_Die()->catch_quietly(
	    sub {$self->piped_exec("git ls-remote $res 2>&1")},
	)) {
	    return _checkout_git($self, $module, $version, $res, $git_dir);
	}
    }
    return _checkout_cvs($self, $module, $version);
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
    my($self, $module, $version, $repo, $git_dir) = @_;
    return _update_or_fresh(
	$self,
	$module,
	$version,
	sub {
	    IO_File()->do_in_dir(
		$module,
		sub {$self->piped_exec(['git pull'])},
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
}

sub _checkout_rsync {
    my($self, $module, $version, $repo) = @_;
    IO_Config()->assert_dev;
    b_info("copying files from $repo, not checking out");
    my($md) = IO_File()->absolute_path($module);
    if (-d $md) {
	system('chmod', '-R', 'u+w', $md);
	IO_File()->rm_rf($md);
    }
    my($p) = IO_File()->mkdir_parent_only($md);
    system('rsync', '-a', '--exclude=.git', '-filter=:- .gitignore', $repo, $p);
    IO_File()->rename("$p/" . File::Basename::basename($repo), $md);
    system('chmod', '-R', 'u+w', $md);
    return;
}

sub _repo {
    my($self, $module) = @_;
    if (($ENV{BIVIO_UTIL_VC_ROOT} || '') =~ m{^/} && -d $ENV{BIVIO_UTIL_VC_ROOT}) {
	return "$ENV{BIVIO_UTIL_VC_ROOT}/$module";
    }
    my($git_dir) = $module;
    $git_dir =~ s{/}{-}g;
    foreach my $r (@{$_CFG->{git_root_list} || []}) {
	my($res) = "$r/$git_dir";
	if (!Bivio_Die()->catch_quietly(
	    sub {$self->piped_exec("git ls-remote $res 2>&1")},
	)) {
	    return ($res, $git_dir);
	}
    }
    return $module;
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
