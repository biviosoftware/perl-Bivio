# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Util::Release;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use Config ();
use File::Find ();
use URI::Heuristic ();
b_use('IO.ClassLoaderAUTOLOAD');

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

our($_TRACE);
our($_MACROS);
my($_VC_CHECKOUT) = 'bivio vc checkout';
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_FILES_LIST_BASE) = 'b_release_files.list';
my($_FILES_LIST) = '%{_builddir}/' . $_FILES_LIST_BASE;
my($_EXCLUDE_LIST) = '%{_builddir}/b_release_files.exclude';
my($_NEED_BUILD_ROOT) = `rpmbuild --version` =~ /version 4\.[0-4]\./ ? 1 : 0;
my($_R) = b_use('IO.Ref');
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    cvs_rpm_spec_dir => ['pkgs'],
    rpm_home_dir => $_C->REQUIRED,
    rpm_http_root => undef,
    rpm_user => $_C->REQUIRED,
    rpm_group => undef,
    http_realm => undef,
    http_user => undef,
    http_password => undef,
    install_umask => 022,
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
    create_stream pkg... -- generate a stream from a list of pkg names
    run_sh script -- runs script.sh from repository
    get_projects -- returns a hash_ref of projects
    install package ... -- install rpms from network repository
    install_host_stream -- executes "-force install_stream $(hostname)"
    install_stream stream_name -- installs all rpms in a stream
    list [uri] -- displays packages in network repository
    list_installed match -- lists packages which match pattern
    list_projects -- get project list as an array_ref
    list_projects_el -- get project list for Lisp setq
    list_updates stream_name -- list packages that need to updated
    update stream_name -- retrieve and apply updates
    yum_update -- bracket with magic to make yum update work
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
    $self->assert_not_root;
    $self->usage_error("Missing spec file\n") unless @packages;
    my($rpm_stage) = $self->get('build_stage');
    $self->usage_error("Invalid build_stage ", $rpm_stage, "\n")
	unless $rpm_stage =~ /^[pcib]$/;
    return _do_in_tmp($self, 1, sub {
	my($tmp, $output, $pwd) = @_;
	for my $specin (@packages) {
	    my($specout, $base) = _create_rpm_spec(
		$self, $specin, $output, $pwd);
	    my($rpm_command) = "rpmbuild -b$rpm_stage $specout";
	    if ($self->get('noexecute')) {
		_would_run("cd $tmp; $rpm_command", $output);
		next;
	    }
	    _system($rpm_command, $output);
	    my($rpm_file) = $$output =~ /.*Wrote:\s+(\S+\.rpm)\n/is;
	    _save_rpm_file($rpm_file, $output);
	    _link_base_version(Type_FilePath()->get_tail($rpm_file), "$base.rpm", $output);
	}
	return;
    });
}

sub create_stream {
    my($self, @pkg) = shift->name_args([['Line']], \@_);
    return `rpm -q @pkg --queryformat '%{NAME} %{VERSION}-%{RELEASE} %{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}.rpm\n' | sort`;
}

sub download_file {
    sub DOWNLOAD_FILE {[
	[qw(file_name Text)],
    ]}
    my($self, $bp) = shift->parameters(\@_);
    my($uri) = $bp->{file_name};
    IO_File()->write($bp->{file_name}, _http_get(\$uri));
    return;
}

sub get_projects {
    # Returns a map of root packages names and long names.
    #     {
    # 	pet => 'bivio Software, Inc.',
    #     }
    return {map({lc @$_[0], @$_[2]} @{$_CFG->{projects}})};
}

sub handle_config {
    my(undef, $cfg) = @_;
    # cvs_rpm_spec_dir : array [pkgs]
    #
    # The cvs directories which hold your package specifications.
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
    # Umask for builds and installs of binaries and libraries.
    #
    # projects : array_ref [[[Bivio => b => 'bivio Software, Inc.']]]
    #
    # Array_ref of array_refs of the form:
    #
    #     [
    #        [ProjectRootPkg => shell-util-prefix => 'Copyright Owner, Inc.'],
    #     ]
    #
    # This list is used by L<list_projects_el|"list_projects_el">.
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
    b_die($cfg->{projects}, ': projects must be an array_ref')
        unless ref($cfg->{projects}) eq 'ARRAY';
    $_CFG = {%$cfg};
    $_CFG->{rpm_http_root} = $_CFG->{rpm_home_dir}
	unless defined($_CFG->{rpm_http_root});
    $_CFG->{rpm_group} ||= $_CFG->{rpm_user};
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
    $self->usage_error("No packages to install?")
	unless @packages;

    my($command) = ['rpm', '-Uvh'];
    push(@$command, '--force') if $self->unsafe_get('force');
    push(@$command, '--nodeps') if $self->unsafe_get('nodeps');
    push(@$command, '--test') if $self->unsafe_get('noexecute');
#BUG: rpm 4.0.4 has a bug with proxy: after downloading correctly, it
#     installs the first package N times.  NOTE: check below $ENV{http_proxy}.
#    push(@$command, _get_proxy($self))
#	unless $_CFG->{http_realm};

    # install all the packages
    my($prev) = [];
    foreach my $package (@packages) {
	push(@$prev,
	     `rpm -q --queryformat '\%{NAME}-\%{VERSION}-\%{RELEASE}.\%{ARCH}.rpm' $package 2>/dev/null`,
	);
	$package .= '.rpm'
	    if $package =~ /\.\d+$/;
	$package .= '-'.$self->get('version').'.rpm'
	    unless $package =~ /\.rpm$/;
	push(@$command, _create_uri($package));
    }

#TODO: download srcrpm and build/install
    _umask();
    my($run) = sub {
	my($op) = @_;
	my($err) = $?
	    if $op->() != 0;
	$self->print(
	    "To rollback:\n",
	    "rpm -Uvh --force --nodeps @$prev\n",
	);
	if ($err) {
	    $self->print("ERROR: exit status = $err\n");
	    CORE::exit(1);
	}
	return;
    };
    return _do_in_tmp($self, 0, sub {
	my($tmp, $output) = @_;
	my($i) = 0;
	foreach my $arg (@$command) {
	    next
		unless $arg =~ /^http/;
	    my($file) = $arg =~ m{([^/]+)$};
	    b_use('IO.File')->write($file, _http_get(\$arg, $output));
	    substr($prev->[$i++], 0, 0) = ($arg =~ m{(.*/)})[0];
	    substr($arg, 0) = $file;
	}
	_output($output, "@$command\n");

	# For some reason, system and `` doesn't work right with rpm and
	# a redirect (see _system, but `@$command 2>&1` doesn't work either).
	# There seems to be a "wait" problem.
	$self->print($$output);
	$$output = '';
	$run->(sub {system(@$command)});
	return;
    }) if $_CFG->{http_realm} || $ENV{http_proxy};
    $self->print(join(' ', @$command, "\n"));
    $run->(sub {system(@$command)});
    return;
}

sub install_host_stream {
    return shift->put(force => 1)->install_stream(_host_name());
}

sub install_stream {
    my($self) = @_;
    # Installs the entire stream.
    return $self->install(@{_get_update_list(1, @_)});
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
	map("$_\n", ${_http_get(\($uri ||= ''))} =~ /.+\">\s*(\S+\.rpm)<\/A>/g));
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

sub map_projects {
    my($proto, $op) = @_;
    return [map(
	$op->(@$_),
	@{$proto->list_projects},
    )];
}

sub update {
    my($self) = @_;
    # Download and apply package updates for the current stream.  Does not install
    # packages if they aren't already on the current host.
    my($x) = _get_update_list(0, @_);
    return @$x ? $self->install(@$x) : "All packages up to date\n";
}

sub _b_release_define {
    my($name, $string) = @_;
    $_MACROS->{$name} = $string;
    $string = ${b_use('IO.Ref')->to_string($string, undef, 0)}
	if ref($string);
    $string =~ s/\n/ /g;
    return '%define ' . $name . ' ' . $string;
}

sub _b_release_files {
    my($instructions) = @_;
    $instructions ||= <<'EOF';
+
%files
EOF
    $instructions .= "\%files\n"
	unless $instructions =~ /\%files\b/;
    my($prefix) = '';
    my($res) = "cd \%{buildroot}\n";
    $instructions = [split(/\n/, $instructions)];
    while (defined(my $line = shift(@$instructions))) {
	$line =~ s/^\s+|\s+$//g;
	next
	    unless length($line);
	if ($line =~ s/^\$\{(\w+)\}(.*)/"\$_MACROS->{$1}$2 || ''"/ee) {
	    unshift(@$instructions, split(/\n/, $line));
	    next;
	}
	if ($line =~ /^\%defattr/) {
	    $res .= "echo '$line'";
	}
	elsif ($line eq '%files') {
	    $res .= <<"EOF";
test -s '$_FILES_LIST' || {
    echo 'ERROR: Empty files list'
    exit 1
}

\%files -f $_FILES_LIST_BASE
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
    %{allfiles} | fgrep -x -v -f $_EXCLUDE_LIST || true
EOF
            $res .= ') ';
            if ($prefix) {
		my($p) = $prefix;
		$p =~ s/(\W)/\\$1/g;
		$res .= "| perl -p -e 's{^}{\Q$prefix\E}'";
	    }
	    $res .= q{| perl -p -e 'm{/man\d[a-z]?/.*\.\d+} && s{$}{*}m'};
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
#    _system("cd $_CFG->{tmp_dir} && bivio vc checkout $version"
#	. " $_CFG->{cvs_rpm_spec_dir}/$to_include", $output)
#	if $version;
    return ${b_use('IO.File')->read("$spec_dir$to_include")};
}

sub _build_macros {
    my($build_root) = @_;
    my($vc_find) = b_use('Util.VC')->CONTROL_DIR_FIND_PREDICATE;
    return ($_NEED_BUILD_ROOT ? "BuildRoot: $build_root\n" : '')
	. '%define build_root %{buildroot}'
	. "\n"
        . <<"EOF";
\%define allfiles cd \%{buildroot}; find . $vc_find -prune -o -type l -print -o -type f -print | sed -e 's/^\\.//'
\%define allcfgs cd \%{buildroot}; find . -name $vc_find -prune -o -type l -print -o -type f -print | sed -e 's/^\\./%config /'
EOF
}

sub run_sh {
    my($self, $script) = @_;
    return $self->piped_exec('sh -x', _http_get(\("$script.sh")));
}

sub yum_update {
    my($self, @command) = @_;
    my($restore) = [];
    my($conflicts) = _parse_stream(
        _host_name(),
        sub {
            my($base, $version, $rpm) = @_;
            # Can't use $version if HEAD, because that's
            # a symlink and not the actual version which yum knows
            return $version eq 'HEAD' ? $base : $rpm;
        }
    );
    foreach my $rpm (@$conflicts) {
        system(qw(rpm --erase --justdb --nodeps), $rpm)
    }
    system(
        'yum',
        $self->unsafe_get('force') ? '-y' : (),
        @command ? @command : 'update',
    );
    $self->install_host_stream;
    return;
}

sub _chdir {
    my($dir, $output) = @_;
    b_use('IO.File')->chdir($dir);
    _output($output, "cd $dir\n");
    return $dir;
}

sub _create_rpm_spec {
    my($self, $specin, $output, $pwd) = @_;
    my($build_root) = _mkdir_rpmbuild($self);
    my($version) = $self->get('version');
    my($cvs) = 0;
    if ($specin =~ /\.spec$/) {
	$specin = $pwd.'/'.$specin
	    unless $specin =~ m!^/!;
    }
    else {
	my($spec_dir) = $_CFG->{cvs_rpm_spec_dir};
	my($first);
	foreach my $sd (ref($spec_dir) ? @$spec_dir : $spec_dir) {
	    _system("bivio vc checkout '$version' '$sd'", $output);
	    if ($first) {
		_system("cp -a '$sd'/*.* '$first'");
	    }
	    else {
		$first = $sd;
	    }
	}
        $specin = "$first/$specin.spec";
	$specin = b_use('IO.File')->pwd.'/'.$specin
	    unless $specin =~ m!^/!;
	$cvs = 1;
    }
    my($spec_dir) = $specin;
    $spec_dir =~ s#[^/]+$##;
    my($base_spec) =  _read_all($specin);
    my($release) = _search('release', $base_spec) || _get_date_format();
    my($name) = _search('name', $base_spec)
	|| (b_use('Type.FileName')->get_tail($specin) =~ /(.*)\.spec$/);
    my($provides) = _search('provides', $base_spec) || $name;
    my($vc_find) = $self->new_other('VC')->CONTROL_DIR_FIND_PREDICATE;
    my($buf) = <<"EOF" . _perl_macros();
\%define suse_check echo not calling /usr/sbin/Check
\%define cvs $_VC_CHECKOUT $version
\%define rm_cvs_dirs (cd \%{_builddir} && find '\%{cvs_dir}' -type d $vc_find -exec \%{safe_rm} '{}' ';' -prune) || exit 1
Release: $release
Name: $name
Provides: $provides
EOF
    # This is a different version
    $buf .= "Version: $version\n"
	unless _search('version', $base_spec);
    $buf .= "License: N/A\n"
	unless _search('license', $base_spec);
    $buf .= _build_macros($build_root);
    for my $line (@$base_spec) {
        0 while $line =~ s{^\s*_b_release_include\((.+?)\);}
	    {"_b_release_include($1, \$spec_dir, \$cvs ? \$version : 0, \$output)"}xeemg;
	$buf .= $line
	    unless $line =~ /^(release|name|provides): /i;
    }
    local($_MACROS) = {};
    $buf =~ s/\b(_b_release_(?:files|define)\(.*?\));/$1/eegs;
    my($safe_rm) = "b-release-safe_rm-$$-" . Biz_Random()->string;
    b_die('%prep', ': missing from spec file')
	unless $buf =~ s{(\n\%prep\s*?)\n}{$1
cd /tmp
@{[_safe_rm($safe_rm)]}
./$safe_rm \%{_builddir} \%{buildroot}
mkdir -p \%{_builddir} %{buildroot}
mv $safe_rm \%{_builddir}
cd \%{_builddir}
\%define safe_rm \%{_builddir}/$safe_rm
}s;
    $version = $1
	if $buf =~ /\nVersion:\s*(\S+)/i;
    my($specout) = "$specin-build";
    b_use('IO.File')->write($specout, \$buf);
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
    b_use('IO.File')->rm_rf($_CFG->{tmp_dir});
    b_use('IO.File')->mkdir_p($_CFG->{tmp_dir});
    return _do_output(sub {
        my($output) = @_;
	my($prev_dir) = b_use('IO.File')->pwd;
	$op->(_chdir($_CFG->{tmp_dir}, $output), $output, $prev_dir);
	_chdir($prev_dir);
	b_use('IO.File')->rm_rf($_CFG->{tmp_dir})
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
	    unless ${b_use('IO.File')->read($orig)}
		    eq ${b_use('IO.File')->read($final)};
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
        || b_die('couldn\'t parse proxy: ', $proxy);
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
    my($uri);
    return _parse_stream(
        $stream,
        sub {
	    my($base, $version, $rpm) = @_;
	    return !$local_rpms->{"$base $version"}
	        && ($install || $local_rpms->{$base})
	        ? $rpm : ();
        },
    )
}

sub _host_name {
    return Sys::Hostname::hostname();
}

sub _http_get {
    my($uri, $output) = @_;
    # Returns content pointed to by $uri.  Handles local files as well
    # as remote files.
    ($$uri = _create_uri($$uri)) =~ /^\w+:/
	or $$uri = URI::Heuristic::uf_uri($$uri)->as_string;
    _output($output, "GET $$uri\n");
    local($ENV{HTTPS_CA_FILE}) = $_CFG->{https_ca_file}
	if $_CFG->{https_ca_file};
    my($ua) = b_use('Ext.LWPUserAgent')
	->new
	->bivio_ssl_no_check_certificate
	->bivio_redirect_automatically;
    $ua->credentials(
	URI->new($$uri)->host_port,
	@$_CFG{qw(http_realm http_user http_password)},
    ) if $_CFG->{http_realm};
    my($reply) = $ua->request(
	HTTP::Request->new('GET', $$uri));
    b_die($$uri, ": GET failed: ", $reply->status_line)
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
    return
	if $base =~ /-HEAD\./;
    unlink($base);
    _output($output, "LINKING $version AS $base\n");
    _system("ln -s '$version' '$base'", $output);
    return;
}

sub _mkdir_rpmbuild {
    my($self) = @_;
    my($map) = {${$self->piped_exec('rpmbuild --showrc')} =~ /:\s+(_[a-z]+)\s+(\S+)/g};
    my($lookup) = sub {
	my($name) = @_;
	b_die($name, ': not found in `rpmbuild --showrc`')
	    unless my $d = $map->{$name};
	$map->{$name} = $d
	    if $d =~ s{^\%\{getenv:(\w+)\}}{$ENV{$1}};
	return $d
	    if $name eq '_topdir';
	b_die($d, ": $name does not begin with _topdir")
	    unless $d =~ /^\%{_topdir}(.+)/;
	return $map->{_topdir} . $1;
    };
    my($top) = $lookup->('_topdir');
    foreach my $dir (qw(
	_builddir
	_rpmdir
	_sourcedir
	_specdir
	_srcrpmdir
    )) {
	IO_File()->mkdir_p($top . $lookup->($dir));
    }
    return $lookup->('_builddir') . '/install';
}

sub _output {
    my($output) = shift;
    # Appends output with arg(s).
    _trace(@_) if $_TRACE;
    $$output .= join('', @_)
	if $output;
    return;
}

sub _parse_stream {
    my($stream, $op) = @_;
    my($uri) = _stream_file($stream);
    return [
	map({
	    my($base, $version, $rpm) = split(/\s+/, $_);
	    $version ||= 'HEAD';
	    $rpm ||= "$base-$version.rpm";
            $op->($base, $version, $rpm);
	} split(/\n/, ${_http_get(\$uri)})),
    ];
}

sub _perl_macros {
    return join(
	'',
	map(
	    '%define ' . $_ . " \%{nil}\n",
	    '__perl_provides',
	    '__perl_requires',
	),
	map(
	    _perl_macros_one(@$_),
	    [
		'perl_build',
		'Build.PL --destdir %{buildroot} --installdirs vendor',
		'./Build code',
		'./Build',
	    ],
	    [
		'perl_make',
		'Makefile.PL DESTDIR=%{buildroot} INSTALLDIRS=vendor',
		'make POD2MAN=true',
		'make POD2MAN=true',
	    ],
	),
    );
}

sub _perl_macros_one {
    my($name, $make_make, $make, $install) = @_;
    my($def) = sub {
	return (
	    '%define ',
	    $name,
	    shift(@_),
	    ' ',
	    _umask_string(),
	    ' && ',
	    @_,
	    "\n",
	);
    };
    return (
	$def->(
	    '',
	    'perl ',
	    $make_make,
	    ' < /dev/null',
	    ' && ',
	    $make
	),
	$def->(
	    '_install',
	    $install,
	    ' pure_install',
	    ' && %{safe_rm} %{buildroot}/usr/share/man %{buildroot}/usr/man',
	    q{ && find %{buildroot} -name '*.bs' -o -name .packlist -o -name perllocal.pod | xargs rm -f},
	),
    );
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
    open(IN, $file) || b_die("$file: $!");
    my(@data) = <IN>;
    close(IN);
    return \@data;
}

sub _rpm_uri_to_filename {
    my($uri) = @_;
    # Creates file name from $uri.  Ensures directory exists.
    return b_use('IO.File')->mkdir_p('/var/spool/up2date')
	. '/'. b_use('Type.FileName')->get_tail($uri);
}

sub _safe_rm {
    my($name) = @_;
    return <<"END1" . <<'END2';
cat > $name <<'EOF' && chmod +x $name
END1
#!/usr/bin/perl -w
use strict;
foreach my $f (@ARGV) {
    next
        unless -r $f;
    if (-f $f || -l $f && ! -d $f) {
        unlink($f);
    }
    elsif (`cd '$f' && pwd` =~ m{^(/[^/]+){3,}}s) {
        system(qw(rm -rf), $f);
    }
    else {
        die("$f: not deleting\n");
    }
}
EOF
END2
}

sub _save_rpm_file {
    my($rpm_file, $output) = @_;
    b_die($rpm_file, ': missing rpm file')
	unless -f $rpm_file;
    $$output .= "SAVING RPM $rpm_file in $_CFG->{rpm_home_dir}\n";
    _system("chown $_CFG->{rpm_user}.$_CFG->{rpm_group} $rpm_file", $output);
    _system("mv -f $rpm_file $_CFG->{rpm_home_dir}", $output);
    return;
}

sub _search {
    my($tag, $source) = @_;
    my($res) = [map(/^$tag: (.+)/i ? $1 : (), @$source)];
    return @$res ? join(', ', @$res) : undef;
}

sub _stream_file {
    my($stream) = @_;
    return "$stream-rpms.txt"
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
    return
	unless $die;
    _output($output, ${$die->get('attrs')->{output}});
    $die->throw;
    # DOES NOT RETURN
}

sub _umask {
    my($output) = @_;
    umask($_CFG->{install_umask});
    _output($output, _umask_string() . "\n");
    return;
}

sub _umask_string {
    return sprintf('umask 0%o', $_CFG->{install_umask});
}

sub _would_run {
    my($cmd, $output) = @_;
    _output($output, "Would run: $cmd\n");
    return;
}

1;
