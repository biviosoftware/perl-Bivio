# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Util::Release;
use strict;
$Bivio::Util::Release::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::Release::VERSION;

=head1 NAME

Bivio::Util::Release - build and release management

=head1 SYNOPSIS

    b-release [options] command [args...]

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::Release::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::Release> Build and Release Management with b-release

Configuration

  Host configuration is controlled via the bivio.conf

  cvs_rpm_spec_dir - cvs directory with rpm package specifications
  rpm_host         - rpm repository host name/port
  rpm_home_dir     - location of rpms on rpm_host

Build

  In the common form, 'build' will create a new rpm file for the
  package. The package's rpm spec file will be retrieved from cvs and
  the package will be checked out of cvs, and assembled into an rpm
  according to the spec file. By default the 'HEAD' or current version
  will be used checked out from cvs unless the '-version' flag is
  specified. The output from the command details the steps involved
  and the output from the cvs and rpm utilities.

  Example:

    b-release build myproject

  The commands executed would be (summarized):

    cvs checkout -f -r HEAD <cvs_rpm_spec_dir>/myproject.spec
    rpm -bb <cvs_rpm_spec_dir>/myproject.spec-build
    cp -p i386/myproject-HEAD-<date_time>.i386.rpm <rpm_home_dir>
    ln -s myproject-HEAD-<date_time>.i386.rpm myproject-HEAD.rpm

  The myproject.spec-build file is created dynamically by
  b-release.

Installation

  Installs the latest version of the package. The '-force' and
  '-nodeps' can be used to control the rpm installation. The
  '-version' flag determines the package version installed, the
  default is 'HEAD'.

  Example:

    b-release install myproject

  The commands executed would be:

    rpm -Uvh <rpm_host><rpm_home_dir>/myproject-HEAD.rpm

=cut

#=IMPORTS
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Bivio::IO::File;
use HTTP::Request ();
use LWP::UserAgent ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_CVS_RPM_SPEC_DIR);
my($_RPM_HOME_DIR);
my($_RPM_HOST);
my($_RPM_USER);
my($_TMP_DIR);
my($_START_DIR) = Bivio::IO::File->pwd;

Bivio::IO::Config->register({
    cvs_rpm_spec_dir => 'pkgs',
    rpm_home_dir => '/home/dip/rpms',
    rpm_host => 'http://locker.bivio.com:60000/dip/rpms',
    rpm_user => 'httpd',
    tmp_dir => "/var/tmp/build-$$",
});

=head1 METHODS

=cut

=for html <a name="OPTIONS"></a>

=head2 OPTIONS : hash_ref

	build_stage => ['String', 'b'],
	nodeps => ['Boolean', 0],
        version => ['String', 'HEAD'],

=cut

sub OPTIONS {
    return {
	%{__PACKAGE__->SUPER::OPTIONS()},
	build_stage => ['String', 'b'],
	nodeps => ['Boolean', 0],
        version => ['String', 'HEAD'],
    };
}

=for html <a name="OPTIONS_USAGE"></a>

=head2 OPTIONS_USAGE : string

Adds the following to standard options:

    -build_stage - rpm build stage, valid values [p,c,i,b],
                   identical to the rpm(1) -b option
    -nodeps - install without checking dependencies
    -version - the version to be built (default: HEAD)

=cut

sub OPTIONS_USAGE {
    return __PACKAGE__->SUPER::OPTIONS_USAGE()
	    .<<'EOF';
    -build_stage - rpm build stage, valid values [p,c,i,b],
                   identical to the rpm(1) -b option
    -nodeps - install without checking dependencies
    -version - the version to be built (default: HEAD)
EOF
}

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:

usage: b-release [options] command [args...]
commands:
    build rpm-spec-file ... -- compile & build rpms
    install package-name ... -- install rpms from network
                                repository
    list [uri] -- displays packages in network repository

=cut

sub USAGE {
    return <<'EOF';
usage: b-release [options] command [args...]
commands:
    build package ... -- compile & build rpms
    install package ... -- install rpms from network repository
    list [uri] -- displays packages in network repository
EOF
}

=for html <a name="build"></a>

=head2 build(string package, ...) : string

Builds software in stages (prepare, compile, install, package),
using an RPM spec file. build is wrapper around the original
rpm application to help the user access the right source code.

package may be a fully qualified package spec such as

  spec-dir/myproject.spec

or simple name which will default spec in the default cvs directory

  myproject

Returns information about the commands executed.

=cut

sub build {
    my($self, @packages) = @_;
    $self->usage_error("Missing spec file\n") unless @packages;
    $self->usage_error("Must be run as root\n") unless $> == 0;
    my($rpm_stage) = $self->get('build_stage');
    $self->usage_error("Invalid build_stage ", $rpm_stage, "\n")
	    unless $rpm_stage =~ /^[pcib]$/;

    # validate configuration
    Bivio::Die->die('rpm_home_dir dir, ', $_RPM_HOME_DIR, ' not found')
		unless -d $_RPM_HOME_DIR;

    my($output) = '';
    _system("rm -rf $_TMP_DIR", \$output);
    _system("mkdir $_TMP_DIR", \$output);
    $output .= "Changing to $_TMP_DIR\n";
    Bivio::IO::File->chdir($_TMP_DIR);

    my($arch) = _get_rpm_arch();
    _system("ln -s . $arch", \$output) unless -e $arch;

    for my $specin (@packages) {
	my($specout, $base, $fullname) = _create_rpm_spec($self, $specin,
	       \$output);

	my($rpm_command) = "rpm -b$rpm_stage $specout";
	if ($self->get('noexecute')) {
            $output .= "Would run: $rpm_command\n"
		    ."           in directory $_TMP_DIR\n";
	    next;
	}
	_system($rpm_command, \$output);
	_save_rpm_file("$arch/$fullname.$arch.rpm", \$output);
	_link_rpm_base("$fullname.$arch.rpm", "$base.rpm", \$output);
    }

    _system("rm -rf $_TMP_DIR\n", \$output) unless $self->get('noexecute');
    return $output;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item cvs_rpm_spec_dir : string ['pkgs'],

=item rpm_home_dir : string ['/home/dip/rpms'],

=item rpm_host : string ['http://locker.bivio.com:60000']

=item rpm_user : string ['httpd'],

=item tmp_dir : string ["/var/tmp/build-$$"]

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;

    $_CVS_RPM_SPEC_DIR = $cfg->{cvs_rpm_spec_dir};
    $_RPM_HOME_DIR = $cfg->{rpm_home_dir};
    $_RPM_HOST = $cfg->{rpm_host};
    $_RPM_USER = $cfg->{rpm_user};
    $_TMP_DIR = $cfg->{tmp_dir};
    return;
}

=for html <a name="install"></a>

=head2 install(string package, ...) : string

Manages packages for a host. It will install/upgrade/remove packages.
Uses the environment settings for http_proxy if present.

package may be a fully qualified name such as

  myproject-1.5.2-2.i386.rpm

or simple name which will default the current version

  myproject

Returns a list of commands executed.

=cut

sub install {
    my($self, @packages) = @_;
    $self->usage_error("No packages to install?") unless @packages;
    my($output) = '';

    # process optional args
    my($rpm_opt) = '';
    $rpm_opt .= '--force ' if $self->get('force');
    $rpm_opt .= '--nodeps ' if $self->get('nodeps');

    # use proxy settings if present in environment (also used by LWP)
    if(defined($ENV{'http_proxy'})
            && $ENV{'http_proxy'} =~ m!^http://([^:]+):(\d+)!) {
        $rpm_opt .= "--httpproxy $1 --httpport $2 ";
	$output .= "Fetching via http proxy $1:$2\n";
    }

    # install all the packages
    for my $package (@packages) {
	$package .= '-'.$self->get('version').'.rpm'
		unless $package =~ /\.rpm$/;
        my($uri) = _create_URI($package);
	my($command) = "rpm -Uvh $rpm_opt $uri";
	if ($self->get('noexecute')) {
	    $output .= "Would run: $command\n";
	    next;
	}
	_system($command, \$output);
    }
    $output =~ s/warning: (\S+) saved as (\S+)\s*/_err_parser($1, $2)/esg;
    return $output;
}

=for html <a name="list"></a>

=head2 list() : string

Displays packages in default network repository.

=head2 list(string uri) : string

Displays the packages at the specified repository. The uri may be of the
complete form:

 http://host:port/dir

or directory form which will use the default host:

 dir

=cut

sub list {
    my($self, $uri) = @_;
    my($output) = '';

    $uri = _create_URI($uri || '');
    my($ua) = LWP::UserAgent->new();
    $ua->env_proxy();
    my($reply) = $ua->request(HTTP::Request->new('GET', $uri));
    Bivio::Die->die($uri, ": ", $reply->status_line)
		unless $reply->is_success;
    for my $line (split("\n", $reply->content)) {
	if ($line =~ /.+\">\s(\S+\.rpm)<\/A>/) {
	    $output .= "$1\n";
	}
    }
    return $output;
}

#=PRIVATE METHODS

# _create_URI(string name) : string
#
# Returns a full URI for the specified file name. Prepends host and/or
# directory if not already specified.
#
sub _create_URI {
    my($name) = @_;
    return $name if $name =~ /^http/;
    return "$_RPM_HOST/$name";
}

# _create_rpm_spec(string specin, string_ref output) : (string, string, string)
#
# Creates an rpm spec using the generic spec file specified.
# Appends build info to the output buffer.
# Returns (output spec file name, base name, full name).
#
sub _create_rpm_spec {
    my($self, $specin, $output) = @_;
    my($version) = $self->get('version');

    if ($specin =~ /\.spec$/) {
        $specin = $_START_DIR.'/'.$specin unless $specin =~ m!^/!;
    } else {
        $specin = "$_CVS_RPM_SPEC_DIR/$specin.spec";
        _system("cvs checkout -f -r $version $specin", $output);
    }
    my($base_spec) = _read_all($specin);
    my($release) = _search('release', $base_spec) || _get_date_format();

    my($specout) = "$specin-build";
    open(SPECOUT, ">$specout") || Bivio::Die->die("$specout: $!");

    print(SPECOUT <<"EOF");
%define _sourcedir .
%define _topdir .
%define _srcrpmdir .
%define _rpmdir $_TMP_DIR
%define _builddir .
%define cvs cvs checkout -f -r $version
Release: $release
EOF
    print(SPECOUT "Version: $version\n")
	    unless _search('version', $base_spec);
    print(SPECOUT "Copyright: Bivio\n")
	    unless _search('copyright', $base_spec);

    for my $line (@$base_spec) {
	if ($line =~ /^buildroot: (.+)$/i) {
	    my($build_root) = $1;
	    unless ($build_root =~ m,^/,) {
		$build_root = Bivio::IO::File->pwd.'/'.$build_root;
	    }
	    print(SPECOUT <<"EOF");
BuildRoot: $build_root
%define allfiles cd $build_root; find . -name CVS -prune -o -type l -print -o -type f -print | sed -e 's/^\.//'
%define allcfgs cd $build_root; find . -name CVS -prune -o -type l -print -o -type f -print | sed -e 's/^\./%config /'
EOF
	    next;
	}
	print(SPECOUT $line) unless $line =~ /^release: /i;
    }
    close(SPECOUT);

    $version = _search('version', $base_spec) || $version;
    my($name) = _search('name', $base_spec)
	    || Bivio::Die->die("$specin: Missing Name: tag!\n");
    return ($specout, "$name-$version", "$name-$version-$release");
}

# _err_parser() : string
#
# Gets rid of 'warning: x saved as y' if the files are the same
#
sub _err_parser {
    my($orig, $final) = @_;
    return ("warning: $orig saved as $final\n")
	    unless ${Bivio::IO::File->read($orig)}
		    eq ${Bivio::IO::File->read($final)};
    return '';
}

# _get_date_format() : string
#
# Returns a date format for the current local time.
#
sub _get_date_format {
    my(@n) = localtime;
    return sprintf("%4d%02d%02d_%02d%02d%02d", 1900+$n[5], 1+$n[4],
	    $n[3], $n[2], $n[1], $n[0]);
}

# _get_rpm_arch() : string
#
# Returns the _arch value from the rpm resource definition.
# Defaults to 'i386' if not found.
#
sub _get_rpm_arch {
    my($rc) = _read_all("rpm --showrc|");
    grep(/^\-\d+: _arch\s+(\S+)/ && (return $1), @$rc);
    return 'i386';
}

# _link_rpm_base(string rpm_file, string_ref output)
#
# Create link with base name to this RPM.
#
sub _link_rpm_base {
    my($rpm_file, $rpm_base, $output) = @_;

    my($base_file) = "$_RPM_HOME_DIR/$rpm_base";
    unlink($base_file);
    $$output .= "LINKING AS $base_file\n";
    _system("ln -s $rpm_file $base_file", $output);
    return;
}

# _read_all(string file) : array_ref
#
# Returns the entire contents of the named file.
#
sub _read_all {
    my($file) = @_;
    open(IN, $file) || Bivio::Die->die("$file: $!");
    my(@data) = <IN>;
    close(IN);
    return \@data;
}

# _save_rpm_file(string filename, string_ref output)
#
# Saves the named rpm file into _RPM_HOME_DIR.
#
sub _save_rpm_file {
    my($rpm_file, $output) = @_;
    Bivio::Die->die("Missing rpm file $rpm_file") unless -f $rpm_file;

    $$output .= "SAVING RPM $rpm_file in $_RPM_HOME_DIR\n";
    _system("chown $_RPM_USER.$_RPM_USER $rpm_file", $output);
    _system("cp -p $rpm_file $_RPM_HOME_DIR", $output);
    return;
}

# _search(string tag, array_ref source) : string
#
# Searches for the specified tag in the source array. Returns the
# value or undef if not found.
#
sub _search {
    my($tag, $source) = @_;

    grep(/^$tag: (.+)/i && (return $1), @$source);
    return undef;
}

# _system(string command, string_ref output)
#
# Executes the specified command, appending any results to the output.
# Dies if the system call fails.
#
sub _system {
    my($command, $output) = @_;
    $$output .= "** $command\n";
    $$output .= join('', `$command 2>&1`);

    if ($?) {
	# print out current output and die with the status code
	print($$output);
	Bivio::Die->die("$command failed, exit status ",$?);
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

__PACKAGE__->main(@main::ARGV) if $0 eq __FILE__;
1;
