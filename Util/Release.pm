# Copyright (c) 2001-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Util::Release;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::Ext::LWPUserAgent;
use Bivio::IO::File;
use Bivio::IO::Trace;
use Bivio::Type::FileName;
use Bivio::Type::FileName;
use Config ();
use File::Find ();
use Sys::Hostname ();
use URI::Heuristic ();

# C<Bivio::Util::Release> Build and Release Management with b-release
#
# Host configuration is controlled via the C</etc/bivio.bconf>:
#
#   cvs_rpm_spec_dir - cvs directory with rpm package specifications
#   rpm_http_root    - rpm repository host name/port or absolute file
#   rpm_home_dir     - location of rpms on build host
#
#
# In the common form, 'build' will create a new rpm file for the
# package. The package's rpm spec file will be retrieved from cvs and
# the package will be checked out of cvs, and assembled into an rpm
# according to the spec file. By default the 'HEAD' or current version
# will be used checked out from cvs unless the '-version' flag is
# specified. The output from the command details the steps involved
# and the output from the cvs and rpm utilities.
#
# Example:
#
#     b-release build myproject
#
# The commands executed would be (summarized):
#
#     cvs checkout -f -r HEAD <cvs_rpm_spec_dir>/myproject.spec
#     rpmbuild -bb <cvs_rpm_spec_dir>/myproject.spec-build
#     cp -p i386/myproject-HEAD-<date_time>.i386.rpm <rpm_home_dir>
#     ln -s myproject-HEAD-<date_time>.i386.rpm myproject-HEAD.rpm
#
# The myproject.spec-build file is created dynamically by
# b-release.
#
#
# Installs the latest version of the package. The '-force' and
# '-nodeps' can be used to control the rpm installation. The
# '-version' flag determines the package version installed, the
# default is 'HEAD'.
#
# Example:
#
#     b-release install myproject
#
# The commands executed would be:
#
#     rpm -Uvh <rpm_http_root>/<rpm_home_dir>/myproject-HEAD.rpm

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_CVS_CHECKOUT) = 'cvs -Q checkout -f -r';
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_FACADES_DIR) = 'facades';
my($_FILES_LIST) = '%{build_root}/../b_release_files.list';
my($_EXCLUDE_LIST) = '%{build_root}/../b_release_files.exclude';
my($_R) = b_use('IO.Ref');
Bivio::IO::Config->register(my $_CFG = {
    cvs_rpm_spec_dir => 'pkgs',
    cvs_perl_dir => 'perl',
    rpm_home_dir => Bivio::IO::Config->REQUIRED,
    rpm_http_root => undef,
    rpm_user => Bivio::IO::Config->REQUIRED,
    rpm_group => undef,
    rpm_arch => 'i386',
    http_realm => undef,
    http_user => undef,
    http_password => undef,
    install_umask => 022,
    facades_dir => '/var/www/facades',
    facades_user => undef,
    facades_group => undef,
    facades_umask => 027,
    tmp_dir => "/var/tmp/build-$$",
    https_ca_file => undef,
    projects => [
	[Bivio => b => 'bivio Software, Inc.'],
    ],
});

sub OPTIONS {
    # build_stage : string [b]
    #
    # Value of C<-b> argument to C<rpm>.
    #
    # nodeps : boolean [0]
    #
    # Pass C<--nodeps> to C<rpm>
    #
    # version : string [HEAD]
    #
    # The suffix to the C<rpm> to install.  If you want a particular version,
    # you would use this parameter.  Otherwise, you probably would use
    # the default (C<HEAD>).
    return {
	%{__PACKAGE__->SUPER::OPTIONS()},
	build_stage => ['String', 'b'],
	nodeps => ['Boolean', 0],
        version => ['String', 'HEAD'],
    };
}

sub OPTIONS_USAGE {
    # Adds the following to standard options:
    #
    #     -build_stage - rpm build stage, valid values [p,c,i,b],
    #                    identical to the rpm(1) -b option
    #     -nodeps - install without checking dependencies
    #     -version - the version to be built (default: HEAD)
    return __PACKAGE__->SUPER::OPTIONS_USAGE()
	    .<<'EOF';
    -build_stage - rpm build stage, valid values [p,c,i,b],
                   identical to the rpm(1) -b option
    -nodeps - install without checking dependencies
    -version - the version to be built (default: HEAD)
EOF
}

sub USAGE {
    # Returns:
    #
    # usage: b-release [options] command [args...]
    # commands:
    return <<'EOF';
usage: b-release [options] command [args...]
commands:
    build package ... -- compile & build rpms
    build_tar project ... -- build perl tar distribution
    create_stream pkg... -- generate a stream from a list of pkg names
    get_projects -- returns a hash_ref of projects
    install package ... -- install rpms from network repository
    install_facades facades_dir -- install facade files into local_file_root
    install_host_stream -- executes "-force install_stream $(hostname)"
    install_stream stream_name -- installs all rpms in a stream
    install_tar project ... -- install perl tars from network repository
    list [uri] -- displays packages in network repository
    list_installed match -- lists packages which match pattern
    list_projects -- get project list as an array_ref
    list_projects_el -- get project list for Lisp setq
    list_updates stream_name -- list packages that need to updated
    update stream_name -- retrieve and apply updates
EOF
}

sub build {
    my($self, @packages) = @_;
    # Builds software in stages (prepare, compile, install, package),
    # using an RPM spec file. build is wrapper around the original
    # rpm application to help the user access the right source code.
    #
    # package may be a fully qualified package spec such as
    #
    #   spec-dir/myproject.spec
    #
    # or simple name which will default spec in the default cvs directory
    #
    #   myproject
    #
    # Returns information about the commands executed.
    $self->usage_error("Missing spec file\n") unless @packages;
    my($rpm_stage) = $self->get('build_stage');
    $self->usage_error("Invalid build_stage ", $rpm_stage, "\n")
	unless $rpm_stage =~ /^[pcib]$/;
    return _do_in_tmp($self, 1, sub {
	my($tmp, $output, $pwd) = @_;
	my($arch) = $_CFG->{rpm_arch};
	_system("ln -s . $arch", $output)
	    unless -d $arch;
	for my $specin (@packages) {
	    my($specout, $base, $fullname) = _create_rpm_spec(
		$self, $specin, $output, $pwd);
	    my($rpm_command) = "rpmbuild -b$rpm_stage $specout";
	    if ($self->get('noexecute')) {
		_would_run("cd $tmp; $rpm_command", $output);
		next;
	    }
	    _system($rpm_command, $output);
	    _save_rpm_file("$arch/$fullname.$arch.rpm", $output);
	    _link_base_version("$fullname.$arch.rpm", "$base.rpm", $output);
	}
	return;
    });
}

sub build_tar {
    my($self, @projects) = _project_args(1, @_);
    # Builds a perl tar file suitable for use by L<install_tar|"install_tar">.
    return _do_in_tmp($self, 1, sub {
        my($tmp, $output) = @_;
	_umask('install_umask', $output);
	my($cvs_version) = $self->get('version');
	(my $file_version = _get_date_format()) =~ s/_/./;
	for my $project (@projects) {
	    my($cvs) = "$_CFG->{cvs_perl_dir}/$project->[0]";
	    my($b) = "$project->[0]-$cvs_version";
	    my($bv) = "$b-$file_version";
	    my($tgt) = File::Spec->rel2abs(Bivio::IO::File->mkdir_p($bv));
	    _system(join(' ', $_CVS_CHECKOUT, $cvs_version, $cvs), $output);
	    _build_tar_copy($_CFG->{cvs_perl_dir}, $project, $tgt);
	    _build_tar_makefile($self, $project, $file_version, $tgt);
	    _system("cd $tgt/.. && tar czf"
		. " '$_CFG->{rpm_home_dir}/$bv.tar.gz' '$bv'", $output);
	    _link_base_version("$bv.tar.gz", "$b.tar.gz", $output);
	}
	return;
    });
}

sub create_stream {
    my($self, @pkg) = shift->name_args([['Line']], \@_);
    return `rpm -q @pkg --queryformat '%{NAME} %{VERSION}-%{RELEASE} %{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}.rpm\n' | sort`;
}

sub get_projects {
    # Returns a map of root packages names and long names.
    #     {
    # 	ieeesa => 'IEEESA, Inc.',
    #     }
    return {map({lc @$_[0], @$_[2]} @{$_CFG->{projects}})};
}

sub handle_config {
    my(undef, $cfg) = @_;
    # cvs_rpm_spec_dir : string [pkgs]
    #
    # The cvs directory which holds your package specifications
    #
    # cvs_perl_dir : string [perl]
    #
    # Path from cvs repository root to perl project directories.
    #
    # facades_dir : string [/var/www/facades]
    #
    # Directory where I<Project/files> directory will be installed.
    #
    # facades_group : string [rpm_group]
    #
    # Group to install facades files as.
    #
    # facades_umask : int [027]
    #
    # Umask for creation of files and directories in I<facades_dir>.  There may be
    # cached user data in this directory so it's best for it not to be publicy
    # writable.
    #
    # facades_user : string [rpm_user]
    #
    # User to install facades files as.
    #
    # http_password : string [undef]
    #
    # Password used if I<http_realm> set.
    #
    # http_realm : string [undef]
    #
    # Use basic authentication to retrieve files.  It is recommended that
    # files are accessed via https to avoid passwords being sent in the clear.
    #
    # http_user : string [undef]
    #
    # User to use if I<http_realm> set.
    #
    # install_umask : int [022]
    #
    # Umask for builds and installs of binaries and libraries.  See also
    # I<facades_umask>.
    #
    # projects : array_ref [[[Bivio => b => 'bivio Software, Inc.']]]
    #
    # Array_ref of array_refs of the form:
    #
    #     [
    #        [ProjectRootPkg => shell-util-prefix => 'Copyright Owner, Inc.'],
    #     ]
    #
    # This list is used by L<list_projects_el|"list_projects_el"> and
    # L<build_tar|"build_tar">.
    #
    # rpm_home_dir : string (required)
    #
    # The directory on the build server, where the rpms and tars reside, e.g.
    #
    #     /home/b-release
    #
    # rpm_http_root : string [rpm_http_root]
    #
    # Where the packages reside in the http hierarchy, e.g.
    #
    #     http://build-server/b-release
    #
    # It may also be a simple file.
    #
    # rpm_group : string [rpm_user]
    #
    # The group which owns the releases.  This is probably the same group which
    # your http server is running as.
    #
    # rpm_user : string (required)
    #
    # The user which owns the releases.  Typically, you want this to be root.
    #
    # tmp_dir : string ["/var/tmp/build-$$"]
    #
    # Where the builds and installs take place.
    Bivio::Die->die($cfg->{projects}, ': projects must be an array_ref')
        unless ref($cfg->{projects}) eq 'ARRAY';
    $_CFG = {%$cfg};
    $_CFG->{rpm_http_root} = $_CFG->{rpm_home_dir}
	unless defined($_CFG->{rpm_http_root});
    $_CFG->{rpm_group} ||= $_CFG->{rpm_user};
    $_CFG->{facades_user} ||= $_CFG->{rpm_user};
    $_CFG->{facades_group} ||= $_CFG->{facades_user};
    return;
}

sub install {
    my($self, @packages) = @_;
    # Manages packages for a host. It will install/upgrade/remove packages.
    # Uses the environment settings for http_proxy if present.
    #
    # package may be a fully qualified name such as
    #
    #   myproject-1.5.2-2.i386.rpm
    #
    # or simple name which will default the current version
    #
    #   myproject
    #
    # Returns a list of commands executed.
    $self->usage_error("No packages to install?") unless @packages;

    my($command) = ['rpm', '-Uvh'];
    push(@$command, '--force') if $self->unsafe_get('force');
    push(@$command, '--nodeps') if $self->unsafe_get('nodeps');
    push(@$command, '--test') if $self->unsafe_get('noexecute');
#BUG: rpm 4.0.4 has a bug with proxy: after downloading correctly, it
#     installs the first package N times.  NOTE: check below $ENV{http_proxy}.
#    push(@$command, _get_proxy($self))
#	unless $_CFG->{http_realm};

    # install all the packages
    for my $package (@packages) {
	$package .= '.rpm'
	    if $package =~ /\.\d+$/;
	$package .= '-'.$self->get('version').'.rpm'
	    unless $package =~ /\.rpm$/;
	push(@$command, _create_uri($package));
    }

#TODO: download srcrpm and build/install
    _umask('install_umask');
    return _do_in_tmp($self, 0, sub {
	my($tmp, $output) = @_;
	foreach my $arg (@$command) {
	    next unless $arg =~ /^http/;
	    my($file) = $arg =~ m{([^/]+)$};
	    Bivio::IO::File->write($file, _http_get($arg, $output));
	    substr($arg, 0) = $file;
	}
	_output($output, "@$command\n");

	# For some reason, system and `` doesn't work right with rpm and
	# a redirect (see _system, but `@$command 2>&1` doesn't work either).
	# There seems to be a "wait" problem.
	$self->print($$output);
	$$output = '';
	system(@$command) == 0
	    || Bivio::Die->die('ERROR exit status: ', $?);
	return;
    }) if $_CFG->{http_realm} || $ENV{http_proxy};

    $self->print(join(' ', @$command, "\n"));

    exec(@$command);
    die("command failed: $!\n");
    # DOES NOT RETURN
}

sub install_facades {
    my($self, $facades_dir) = @_;
    # Usually called from Makefile/.PL created by L<build_tar|"build_tar">.
    # Looks for a subdirectory "facades" in current directory and copies
    # all files in that directory to I<facades_dir> using
    # I<facades_user>, I<facades_group>, and I<facades_umask>.
    _do_output(sub {
	my($output) = @_;
	my($r) = Bivio::IO::ClassLoader->simple_require('Bivio::UI::Facade')
	    ->get_local_file_root;
	_umask('facades_umask');
	_chdir($facades_dir, $output);
	_system("chown -h -R '$_CFG->{facades_user}' .", $output);
	_system("chgrp -h -R '$_CFG->{facades_group}' .", $output);
	_system("tar cf - . | (cd '$r' && tar xpf -)", $output);
	return;
    });
}

sub install_host_stream {
    # Forces install of all host packages in stream.
    return shift->put(force => 1)->install_stream(Sys::Hostname::hostname());
}

sub install_stream {
    my($self) = @_;
    # Installs the entire stream.
    return $self->install(@{_get_update_list(1, @_)});
}

sub install_tar {
    my($self, @projects) = _project_args(0, @_);
    # Installs I<version> (HEAD) of I<project>.  I<project> may be an explicit
    # tar.gz file, a shell_util_prefix abbreviation (e.g, b), or a simple
    # name (no tar.gz) suffix.  If not found in I<projects> config, will be
    # looked up explictly.
    return _do_in_tmp($self, 0, sub {
        my($tmp, $output) = @_;
	_umask('install_umask');
	my($cvs_version) = $self->get('version');
	for my $project (map(ref($_) ? $_->[0] : $_, @projects)) {
	    my($tgz) = $project =~ /(?:\.tar\.gz|\.tgz)$/ ? $project
		: "$project-$cvs_version.tar.gz";
	    Bivio::IO::File->write($tgz, _http_get($tgz, $output));
	    _system("tar xpzf '$tgz'", $output);
	    chomp(my $dir = `ls -t | grep -v '$tgz' | head -1`);
	    Bivio::Die->die($dir, ': not a directory, expecting it to be one')
	       unless -d $dir;
	    my($cmd) = "cd '$dir' && perl Makefile.PL < /dev/null "
		. " && make POD2MAN=true install";
	    if ($self->get('noexecute')) {
		_would_run("cd $tmp && $cmd", $output);
		next;
	    }
	    _system($cmd, $output);
	}
	return;
    });
}

sub list {
    my($self, $uri) = @_;
    # Displays packages in default network repository.
    #
    #
    # Displays the packages at the specified repository. The uri may be of the
    # complete form:
    #
    #  http://host:port/dir
    #
    # or directory.
    return join('',
	map("$_\n", ${_http_get($uri || '')} =~ /.+\">\s*(\S+\.rpm)<\/A>/g));
}

sub list_installed {
    my($self, $match) = @_;
    # Lists installed packages with Group and BuildHost for easy parsing.
    # I<match> is a regexp which can be used to limit packages listed.
    # Case is ignored on the match.
    $match = '.' unless defined($match);
    return join('', grep(/$match/i, split(/(?<=\n)/,
	`rpm -qa --queryformat '\%{NAME}-\%{VERSION}-\%{RELEASE} \%{GROUP} %{BUILDHOST}\\n'`
       )));
}

sub list_projects {
    return $_R->nested_copy($_CFG->{projects});
}

sub list_projects_el {
    # Returns the list of configured projects in the following order:
    #
    #     RootPackage short-name Copyright Owner, Inc.
    return "(setq b-perl-projects\n     '("
	. join("\n       ",
	    map(sprintf('("%s" "%s" "%s")', @$_),
		@{$_CFG->{projects}}))
	. "))\n";
}

sub list_updates {
    # Lists packages in I<stream> that have updates.
    return join('', map("$_\n", @{_get_update_list(0, @_)}));
}

sub update {
    my($self) = @_;
    # Download and apply package updates for the current stream.  Does not install
    # packages if they aren't already on the current host.
    my($x) = _get_update_list(0, @_);
    return @$x ? $self->install(@$x) : "All packages up to date\n";
}

sub _b_release_files {
    my($instructions) = @_;
    # Evaluates line oriented instructions.
    my($prefix) = '';
    my($res) = "cd \$RPM_BUILD_ROOT\n";
    foreach my $line (split(/\n/, $instructions)) {
	$line =~ s/^\s+|\s+$//g;
	next unless length($line);
	if ($line =~ /^\%defattr/) {
	    $res .= "echo '$line'";
	}
	elsif ($line eq '%files') {
	    $res .= <<"EOF";
test -s '$_FILES_LIST' || {
    echo 'ERROR: Empty files list'
    exit 1
}

\%files -f $_FILES_LIST
EOF
            next;
        }
	elsif ($line eq '%') {
	    # clear prefix
	    $prefix = '',
	    next;
	}
	elsif ($line =~ /^%/) {
	    $prefix = $line . ' ';
	    next;
	}
	elsif ($line eq '+') {
	    $res .= <<"EOF";
{
    test -f $_FILES_LIST && perl -p -e 's#^[^/]+##' $_FILES_LIST
    echo 'so file is not empty'
} > $_EXCLUDE_LIST
(
    # Protect against error exit
    %{allfiles} | fgrep -x -v -f $_EXCLUDE_LIST
EOF
            $res .= ') ';
            if ($prefix) {
		my($p) = $prefix;
		$p =~ s/(\W)/\\$1/g;
		$res .= "| perl -p -e 's#^#\Q$prefix\E#'";
	    }
	}
	elsif ($line =~ m#^/#) {
	    if ($line =~ /[\?\*\[\]]/) {
		$line =~ s{^/}{};
		$res .= qq{for file in $line; do test "\$file" = '$line' || echo '$prefix' "/\$file"; done};
	    }
	    else {
		$res .= "echo '$prefix$line'";
	    }
	}
	else {
	    die($line, ": unknown _b_release_files instruction");
	}
	$res .= ">> $_FILES_LIST\n";
    }
    # Don't need last \n
    chop($res);
    return $res;
}

sub _b_release_include {
    my($to_include, $spec_dir, $version, $output) = @_;
    # Returns contents of $to_include
    _system("cd $_CFG->{tmp_dir} && cvs checkout -f -r $version"
	. " $_CFG->{cvs_rpm_spec_dir}/$to_include", $output)
	if $version;
    return ${Bivio::IO::File->read("$spec_dir$to_include")};
}

sub _build_root {
    my($build_root) = @_;
    $build_root ||= 'install';
    $build_root = Bivio::IO::File->pwd.'/'.$build_root
	unless $build_root =~ m,^/,;
    return <<"EOF"
BuildRoot: $build_root
\%define build_root $build_root
\%define files_list $_FILES_LIST
EOF
        . <<'EOF';
%define allfiles cd %{build_root}; find . -name CVS -prune -o -type l -print -o -type f -print | sed -e 's/^\\.//'
%define allcfgs cd %{build_root}; find . -name CVS -prune -o -type l -print -o -type f -print | sed -e 's/^\\./%config /'
EOF
}

sub _build_tar_copy {
    my($cvs_dir, $project, $tgt) = @_;
    # Copy files from cvs_dir to tgt for $project.
#     my($uri) = grep
# 	Bivio::IO::File->read("$cvs_dir/$project->[0]/Facades/$project->[0].pm");
    File::Find::find(sub {

	# The alg fails with '.'
	return if $_ eq '.';
	my($dst);
	my($file) = $File::Find::name;
        if ($file =~ m#(?:^|/)(?:CVS|.*\.old|old)/#) {
	    $File::Find::prune = 1;
	    return;
	}
	$file =~ s{^\Q$cvs_dir/}{};
	if ($file =~ m#^$project->[0]/files(?:/|$)(.*)#) {
	    # If there's no local_file_root, we have to insert one
	    ($dst = $1) =~ s{^(?=@{[
                join('|',
	            map($_->get_path,
	                Bivio::IO::ClassLoader->simple_require(
                            'Bivio::UI::LocalFileType'
                        )->get_list,
                    ),
                ),
            ]}/)}{@{[
                lc($project->[0])
            ]}/}x;
	    $dst = "$tgt/$_FACADES_DIR/$dst";
	}
	elsif ($file =~ m#/t(?:/|$)#) {
	    $dst = "$tgt/tests/$file";
	}
	elsif ($file =~ m#(?:^|/)($project->[1]-[-\w]+)$#) {
	    $dst = "$tgt/bin/$1";
	}
	elsif ($file =~ /\.pm$/) {
	    $dst = "$tgt/lib/$file";
	}
	if (-d $_) {
	    # Always ignore directories, but may want to prune
	    $File::Find::prune = 1
		unless $_ =~ /^[A-Z]/ || $dst;
	    return;
	}
	unless ($dst) {
	    _trace($file, ': ignoring') if $_TRACE;
	    return;
	}
	Bivio::IO::File->mkdir_parent_only($dst);
	Bivio::IO::File->write($dst, Bivio::IO::File->read($_));
	return;
    }, "$cvs_dir/$project->[0]");
    return;
}

sub _build_tar_makefile {
    my($self, $project, $file_version, $tgt) = @_;
    # Creates Makefile.PL
    Bivio::IO::File->write("$tgt/Makefile.PL", <<"EOF");
# Copyright (c) @{[$_DT->now_as_year]} $project->[2].  All Rights Reserved.
use strict;
use ExtUtils::MakeMaker ();
ExtUtils::MakeMaker::WriteMakefile(
    NAME => '$project->[0]',
    EXE_FILES => [<bin/$project->[1]-*>],
    AUTHOR => q{$project->[2]},
    dist => {COMPRESS => 'gzip -f', SUFFIX => 'gz'},
    ABSTRACT => q{$project->[0] Application},
    VERSION => $file_version,
    PREREQ_PM => {},
    PMLIBDIRS => ['lib'],
);
sub MY::postamble {
    return <<'END';
install::
	@{[$self->get_or_default('program', 'b-release')]} install_facades $_FACADES_DIR
END
}
EOF
    return;
}

sub _chdir {
    my($dir, $output) = @_;
    # Change to dir, and write to output.
    Bivio::IO::File->chdir($dir);
    _output($output, "cd $dir\n");
    return $dir;
}

sub _create_rpm_spec {
    my($self, $specin, $output, $pwd) = @_;
    # Creates an rpm spec using the generic spec file specified.
    # Appends build info to the output buffer.
    # Returns (output spec file name, base name, full name).
    my($version) = $self->get('version');

    my($cvs) = 0;
    if ($specin =~ /\.spec$/) {
	$specin = $pwd.'/'.$specin
	    unless $specin =~ m!^/!;
    }
    else {
        $specin = "$_CFG->{cvs_rpm_spec_dir}/$specin.spec";
        _system("cvs checkout -f -r $version $specin", $output);
	$specin = Bivio::IO::File->pwd.'/'.$specin
	    unless $specin =~ m!^/!;
	$cvs = 1;
    }
    my($spec_dir) = $specin;
    $spec_dir =~ s#[^/]+$##;
    my($base_spec) =  _read_all($specin);
    my($release) = _search('release', $base_spec) || _get_date_format();
    my($name) = _search('name', $base_spec)
	|| (Bivio::Type::FileName->get_tail($specin) =~ /(.*)\.spec$/);
    my($provides) = _search('provides', $base_spec) || $name;
    my($buf) = <<"EOF" . _perl_make();
%define suse_check echo not calling /usr/sbin/Check
%define _sourcedir .
%define _topdir .
%define _srcrpmdir .
%define _rpmdir $_CFG->{tmp_dir}
%define _builddir .
%define cvs $_CVS_CHECKOUT $version
Release: $release
Name: $name
Provides: $provides
EOF
    $buf .= "Version: $version\n"
	unless _search('version', $base_spec);
    $buf .= "License: N/A\n"
	unless _search('license', $base_spec);
    $buf .= _build_root(_search('buildroot', $base_spec));
    for my $line (@$base_spec) {
        0 while $line =~ s{^\s*_b_release_include\(([^;]+)\);}
	    {"_b_release_include($1, \$spec_dir, \$cvs ? \$version : 0, \$output)"}xeemg;
	$buf .= $line
	    unless $line =~ /^(buildroot|release|name|provides): /i;
    }
    $buf =~ s/\b(_b_release_files\([^;]+\));/$1/eeg;

    $version = $1 if $buf =~ /\nVersion:\s*(\S+)/i;
    my($specout) = "$specin-build";
    Bivio::IO::File->write($specout, \$buf);
    return ($specout, "$name-$version", "$name-$version-$release");
}

sub _create_uri {
    my($name) = @_;
    # Returns a full URI for the specified file name. Prepends host and/or
    # directory if not already specified.
    return $name =~ /^http/ ? $name : "$_CFG->{rpm_http_root}/$name";
}

sub _do_in_tmp {
    my($self, $assert_root, $op) = @_;
    # Returns output of operations.
    $self->usage_error($_CFG->{rpm_home_dir}, ': rpm_home_dir not found')
        unless !$assert_root || -d $_CFG->{rpm_home_dir};
    Bivio::IO::File->rm_rf($_CFG->{tmp_dir});
    Bivio::IO::File->mkdir_p($_CFG->{tmp_dir});
    return _do_output(sub {
        my($output) = @_;
	my($prev_dir) = Bivio::IO::File->pwd;
	$op->(_chdir($_CFG->{tmp_dir}, $output), $output, $prev_dir);
	_chdir($prev_dir);
	Bivio::IO::File->rm_rf($_CFG->{tmp_dir})
	    unless $self->get('noexecute');
	return;
    });
}

sub _do_output {
    my($op) = @_;
    # Catch die and print output along with die.
    my($output) = '';
    my($die) = Bivio::Die->catch(sub {
        return $op->(\$output);
    });
    return $output
	unless $die;
    Bivio::IO::Alert->print_literally($output);
    $die->throw;
    # DOES NOT RETURN
}

sub _err_parser {
    my($orig, $final) = @_;
    # Gets rid of 'warning: x saved as y' if the files are the same
    return ("warning: $orig saved as $final\n")
	    unless ${Bivio::IO::File->read($orig)}
		    eq ${Bivio::IO::File->read($final)};
    return '';
}

sub _get_date_format {
    my(@n) = localtime;
    # Returns a date format for the current local time.
    return sprintf("%4d%02d%02d_%02d%02d%02d", 1900+$n[5], 1+$n[4],
	    $n[3], $n[2], $n[1], $n[0]);
}

sub _get_proxy {
    my($self) = @_;
    # Returns the http proxy arguments if present, parsed from the
    # environment variable http_proxy.
    my($proxy) = $ENV{http_proxy};
    return () unless $proxy;
    $proxy =~ m,/([\w\.]+):(\d+),
        || Bivio::Die->die('couldn\'t parse proxy: ', $proxy);
    return (
        '--httpproxy', $1,
        '--httpport', $2,
       );
}

sub _get_update_list {
    my($install, $self, $stream) = @_;
    # Returns a list of packages that exist on this machine and need updating.
    $self->usage_error("no stream specified.")
	unless $stream;
    my($local_rpms) = {
	map({
	    ($_ => 1, ($_ =~ /^(\S+)/)[0] => 1);
	} split(
	    /\n/,
	    `rpm -qa --queryformat '%{NAME} %{VERSION}-%{RELEASE}\n' | sort`,
	)),
    };
    return [
	map({
	    my($base, $version, $rpm) = split(/\s+/, $_);
	    !$local_rpms->{"$base $version"}
	        && ($install || $local_rpms->{$base})
	        ? $rpm : ();
	} split(/\n/, ${_http_get("$stream-rpms.txt")})),
    ];
}

sub _http_get {
    my($uri, $output) = @_;
    # Returns content pointed to by $uri.  Handles local files as well
    # as remote files.
    ($uri = _create_uri($uri)) =~ /^\w+:/
	or $uri = URI::Heuristic::uf_uri($uri)->as_string;
    _output($output, "GET $uri\n");
    local($ENV{HTTPS_CA_FILE}) = $_CFG->{https_ca_file}
	if $_CFG->{https_ca_file};
    my($ua) = Bivio::Ext::LWPUserAgent->new(1);
    $ua->credentials(
	URI->new($uri)->host_port,
	@$_CFG{qw(http_realm http_user http_password)},
    ) if $_CFG->{http_realm};
    my($reply) = $ua->request(
	HTTP::Request->new('GET', $uri));
    Bivio::Die->die($uri, ": GET failed: ", $reply->status_line)
	unless $reply->is_success;
    return \($reply->content);
}

sub _link_base_version {
    my($version, $base, $output) = @_;
    # Create link from $base to $version in rpm_home_dir.
    $base = "$_CFG->{rpm_home_dir}/$base";
    unlink($base);
    _output($output, "LINKING $version AS $base\n");
    _system("ln -s '$version' '$base'", $output);
    return;
}

sub _output {
    my($output) = shift;
    # Appends output with arg(s).
    _trace(@_) if $_TRACE;
    $$output .= join('', @_)
	if $output;
    return;
}

sub _perl_make {
    # Define the %define values for perl_make, perl_make_install and now
    # perl_build_install for Module::Build compatibility.
    return
	'%define perl_make umask '
	. _umask_string()
	. " && perl Makefile.PL < /dev/null && make POD2MAN=true\n"
	. '%define perl_make_install umask '
	. _umask_string()
	. '; make '
	. join(' ', map {
	     uc($_) . '=$RPM_BUILD_ROOT' . $Config::Config{$_};
	} grep($_ =~ /^install(?!style)/
	    && $Config::Config{$_} && $Config::Config{$_} =~ m!^/!,
	    sort(keys(%Config::Config))))
	.  ' POD2MAN=true pure_install && '
        . ' find $RPM_BUILD_ROOT%{_libdir}/perl? -name "*.bs" '
	. " -o -name .packlist -o -name perllocal.pod | xargs rm -f\n";
}

sub _project_args {
    my($want_die, $self, @projects) = @_;
    # Returns project config: ($self, $project)
    $self->usage_error('project not supplied')
	unless @projects;
    return (
	$self,
	map({
	    my($p) = $_;
	    (grep(lc($_->[0]) eq lc($p) || lc($_->[1]) eq lc($p),
		@{$_CFG->{projects}}
	    ))[0] or
	       $want_die ? $self->usage_error($_, ': project not found')
	       : $p;
	} @projects),
    );
}

sub _read_all {
    my($file) = @_;
    # Returns the entire contents of the named file.
    open(IN, $file) || Bivio::Die->die("$file: $!");
    my(@data) = <IN>;
    close(IN);
    return \@data;
}

sub _rpm_uri_to_filename {
    my($uri) = @_;
    # Creates file name from $uri.  Ensures directory exists.
    return Bivio::IO::File->mkdir_p('/var/spool/up2date')
	. '/'. Bivio::Type::FileName->get_tail($uri);
}

sub _save_rpm_file {
    my($rpm_file, $output) = @_;
    # Saves the named rpm file into _RPM_HOME_DIR.
    Bivio::Die->die("Missing rpm file $rpm_file") unless -f $rpm_file;

    $$output .= "SAVING RPM $rpm_file in $_CFG->{rpm_home_dir}\n";
    _system("chown $_CFG->{rpm_user}.$_CFG->{rpm_group} $rpm_file", $output);
    _system("cp -p $rpm_file $_CFG->{rpm_home_dir}", $output);
    return;
}

sub _search {
    my($tag, $source) = @_;
    # Searches for the specified tag in the source array. Returns the
    # value or undef if not found.

    grep(/^$tag: (.+)/i && (return $1), @$source);
    return undef;
}

sub _system {
    my($command, $output) = @_;
    # Executes the specified command, appending any results to the output.
    # Dies if the system call fails.
    my($die) = Bivio::Die->catch(sub {
	$command =~ s/'/"/g;
	_output($output, "$command\n");
	_output($output, ${__PACKAGE__->piped_exec("sh -ec '$command' 2>&1")});
	return;
    });
    return unless $die;
    _output($output, ${$die->get('attrs')->{output}});
    $die->throw;
    # DOES NOT RETURN
}

sub _umask {
    my($umask_name, $output) = @_;
    # Sets umask and indicates in output
    umask($_CFG->{$umask_name});
    _output($output, 'umask ' . _umask_string($umask_name) . "\n");
    return;
}

sub _umask_string {
    # Returns string version of install_umask
    return sprintf('0%o', $_CFG->{shift || 'install_umask'});
}

sub _would_run {
    my($cmd, $output) = @_;
    # Returns command as "Would run: $cmd"
    _output($output, "Would run: $cmd\n");
    return;
}

1;
