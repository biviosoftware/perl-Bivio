# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Util::Release;
use strict;
$Bivio::Util::Release::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::Release::VERSION;

=head1 NAME

Bivio::Util::Release - build and release management

=head1 SYNOPSIS

    use Bivio::Util::Release;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::Release::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::Release> build and release management

=cut

#=IMPORTS
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Bivio::IO::File;
use HTTP::Request ();
use LWP::UserAgent ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_RPM_HOST);
my($_RPM_HOST_DIR);
my($_TMP_DIR);
my($_RPM_HOME_DIR);
my($_CVS_RPM_SPEC_DIR);
my($_RPM_USER);

Bivio::IO::Config->register({
    # used by 'install'
    rpm_host => 'http://locker.bivio.com:60000',
    rpm_host_dir => '/dip/rpms/',

    # used for building rpms
    cvs_rpm_spec_dir => 'pkgs',
    rpm_home_dir => '/home/dip/rpms',
    tmp_dir => "/var/tmp/bap-$$",
    rpm_user => 'httpd',
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Util::Release

Creates a new Release utility.

=cut

sub new {
    my($self) = Bivio::ShellUtil::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="OPTIONS"></a>

=head2 OPTIONS : hash_ref

    {
	build_stage => ['String', 'b'],
	nodeps => ['Boolean', 0],
	package_suffix => ['String', 'HEAD'],
        version => ['String', undef],
    }

=cut

sub OPTIONS {
    return {
	%{__PACKAGE__->SUPER::OPTIONS()},
	build_stage => ['String', 'b'],
	nodeps => ['Boolean', 0],
	package_suffix => ['String', 'HEAD'],
        version => ['String', undef],
    };

}

=for html <a name="OPTIONS_USAGE"></a>

=head2 OPTIONS_USAGE : string

Adds the following to standard options:

    -build_stage - rpm build stage, valid values [p,c,i,b], identical to the rpm(1) -b option
    -nodeps - install without checking dependencies
    -package_suffix - suffix for rpm file (default: HEAD)
    -version - the version to be built

=cut

sub OPTIONS_USAGE {
    return __PACKAGE__->SUPER::OPTIONS_USAGE()
	    .<<'EOF';
    -build_stage - rpm build stage, valid values [p,c,i,b], identical to the rpm(1) -b option
    -nodeps - install without checking dependencies
    -package_suffix - suffix for rpm file (default: HEAD)
    -version - the version to be built
EOF
}

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:

usage: b-release [options] command [args...]
commands:
    build rpm-spec-file ... -- compile & build rpms
    install package-name ... -- install rpms
    list -- displays packages created by 'build'

=cut

sub USAGE {
    return <<'EOF';
usage: b-release [options] command [args...]
commands:
    build rpm-spec-file ... -- compiles & builds an rpm
    install package-name ... -- installs rpms
    list -- displays packages created by 'build'
EOF
}

=for html <a name="build"></a>

=head2 build(string rpm_spec_file, ...) : string

Builds software in stages (prepare, compile, install, package),
using an RPM spec file. bap is only a small wrapper around the original
rpm application to help the user getting the right source code.

Returns information about the commands executed.

=cut

sub build {
    my($self, @rpm_spec_files) = @_;
    $self->usage_error("Missing spec file") unless @rpm_spec_files;
    $self->usage_error("Must be run as root") unless $> == 0;
    my($rpm_stage) = $self->get('build_stage');
    $self->usage_error("Invalid build_stage ", $rpm_stage)
	    unless $rpm_stage =~ /^[pcib]$/;

    # validation configuration
    Bivio::Die->die("rpm_home_dir dir, ", $_RPM_HOME_DIR, ' not found')
		unless -d $_RPM_HOME_DIR;

    my($output) = '';
    _system("rm -rf $_TMP_DIR", \$output);
    _system("mkdir $_TMP_DIR", \$output);
    $output .= "Changing to $_TMP_DIR\n";
    Bivio::IO::File->chdir($_TMP_DIR);

    my($arch) = _get_rpm_option($self, '_arch') || 'i386';
    _system("ln -s . $arch", \$output) unless -e $arch;

    for my $specin (@rpm_spec_files) {
	unless ($specin =~ /\.spec$/) {
	    $specin = $_CVS_RPM_SPEC_DIR.'/'.$specin.'.spec';
	}
	my($specout, $base, $fullname) = _create_rpm_spec($self, $specin,
	       \$output);

	if ($self->get('noexecute')) {
            $output .= "Would run: rpm -b$rpm_stage $specout\n"
		    ."           in directory $_TMP_DIR\n";
	    next;
	}

	_system("rpm -b$rpm_stage $specout", \$output);
	_save_rpm_file("$arch/$fullname.$arch.rpm", \$output);
	_link_rpm_base("$fullname.$arch.rpm", "$base.rpm", \$output);
    }

    _system("rm -rf $_TMP_DIR\n", \$output) unless $self->get('noexecute');
    return $output;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item rpm_host : string ['http://locker.bivio.com:60000']

=item rpm_host_dir : string ['/dip/rpms/']

=item cvs_rpm_spec_dir : string ['pkgs'],

=item rpm_home_dir : string ['/home/dip/rpms'],

=item tmp_dir : string ["/var/tmp/bap-$$"]

=item rpm_user : string ['httpd'],

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;

    $_RPM_HOST = $cfg->{rpm_host};
    $_RPM_HOST_DIR = $cfg->{rpm_host_dir};
    $_CVS_RPM_SPEC_DIR = $cfg->{cvs_rpm_spec_dir};
    $_RPM_HOME_DIR = $cfg->{rpm_home_dir};
    $_TMP_DIR = $cfg->{tmp_dir};
    $_RPM_USER = $cfg->{rpm_user};
    return;
}

=for html <a name="install"></a>

=head2 install(string package_name, ...) : string

Manages packages for a host. It will install/upgrade/remove packages.
Uses the enviornment settings for http_proxy if present.

Returns a list of commands executed.

=cut

sub install {
    my($self, @package_names) = @_;
    $self->usage_error("No packages to install?") unless @package_names;
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
    for my $package (@package_names) {
	$package .= '-'.$self->get('package_suffix').'.rpm'
		unless $package =~ /\.rpm$/;
        my($uri) = _create_URI($package);
	_system("rpm -Uvh $rpm_opt $uri\n", \$output);
    }
    return $output;
}

=for html <a name="list"></a>

=head2 list() : string

Displays packages created by I<build>.

=cut

sub list {
    my($self) = @_;
    my($output) = '';

    my($uri) = _create_URI('');
    my($ua) = LWP::UserAgent->new();
    $ua->env_proxy();
    my($reply) = $ua->request(HTTP::Request->new('GET', $uri));

    if ($reply->is_success) {
        my(@lines) = split("\n", $reply->content);
        for my $line (@lines) {
	    if ($line =~ /.+\">\s(\S+\.rpm)<\/A>/) {
		$output .= "$1\n";
	    }
        }
    } else {
	Bivio::IO::Alert->warn($uri, ": ", $reply->status_line);
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
    if ($name =~ /^http/) {
        return $name;
    } elsif ($name =~ m:^/:) {
        return $_RPM_HOST.$name;
    } else {
        return $_RPM_HOST.$_RPM_HOST_DIR.$name;
    }
}

# _create_rpm_spec(string specin, string_ref output) : string
#
# Creates an rpm spec using the generic spec file specified.
# Appends build info to the output buffer.
#
sub _create_rpm_spec {
    my($self, $specin, $output) = @_;
    my($cvstag) = $self->get('package_suffix');

    _system("cvs checkout -f -r $cvstag $specin", $output);
    open(SPECIN, "<$specin") || Bivio::Die->die("$specin: $!");
    my(@specin) = <SPECIN>;
    close(SPECIN);

    my($specout) = "$specin-bap";
    open(SPECOUT, ">$specout") || Bivio::Die->die("$specout: $!");

    # After rpm 3.0.2, relative filenames fail!
    print(SPECOUT <<"EOF");
%define _sourcedir .
%define _topdir .
%define _srcrpmdir .
%define _rpmdir $_TMP_DIR
%define _builddir .
EOF

    print(SPECOUT "%define cvs cvs checkout -f -r $cvstag \n");
    my($n, $r, $v);
    grep(/^Name: (.+)/ && ($n = $1), @specin)
	    || Bivio::Die->die("$specin: Missing Name: tag!\n");
    if (!grep(/^Release: (.+)/ && ($r = $1), @specin)) {
	$r = _get_date_format();
	print(SPECOUT "Release: $r\n");
    }
    if (!grep(/^Version: (.+)/ && ($v = $1), @specin)) {
	my($version) = $self->get_or_default('version', $cvstag);
	print(SPECOUT "Version: $version\n");
	$v = $version;
    }
    grep(/^Copyright:/, @specin) || print(SPECOUT "Copyright: Bivio\n");
    my($l, $build_root, $source);
    for $l (@specin) {
	if($l =~ /^buildroot: (.+)$/i) {
	    $build_root = $1;
	    unless ($build_root =~ m,^/,) {
		$build_root = Bivio::IO::File->pwd.'/'.$build_root;
	    }
	    print(SPECOUT "BuildRoot: ", $build_root, "\n");
	    print(SPECOUT "%define allfiles cd $build_root; find . -name CVS -prune -o -type l -print -o -type f -print | sed -e 's/^\.//'\n");
	    print(SPECOUT "%define allcfgs cd $build_root; find . -name CVS -prune -o -type l -print -o -type f -print | sed -e 's/^\./%config /'\n");
	    next;
	}
	print(SPECOUT $l);
    }
    close(SPECOUT);

    return ($specout, "$n-$v", "$n-$v-$r");
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

# _get_rpm_option(string option) : string
#
# Returns the value of the named rpm option.
#
sub _get_rpm_option {
    my($self, $option) = @_;
    my($fields) = $self->{$_PACKAGE};

    # used cached options, or reparse for first call
    unless (defined($fields->{rpmrc})) {
	$fields->{rpmrc} = {};

	open(RPM, "rpm --showrc|") || Bivio::Die->die("$!");
	foreach my $line (<RPM>) {
	    if ($line =~ /^\-\d+: (\S+)\s+(\S+)/) {
		$fields->{rpmrc}->{$1} = $2;
	    }
	}
	close(RPM);
    }
    return $fields->{rpmrc}->{$option};
}

# _link_rpm_base(string rpm_file, string_ref output)
#
# Create link with base name to this RPM.
#
sub _link_rpm_base {
    my($rpm_file, $rpm_base, $output) = @_;

    unlink("$_RPM_HOME_DIR/$rpm_base");
    $$output .= "LINKING AS $_RPM_HOME_DIR/$rpm_base\n";
    _system("ln -s $rpm_file $_RPM_HOME_DIR/$rpm_base", $output);
    return;
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
    _system("cp -p $rpm_file $_RPM_HOME_DIR", \$output);
    return;
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
