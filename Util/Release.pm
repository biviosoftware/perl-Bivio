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
use Bivio::IO::Config;
use Bivio::IO::Alert;
use Cwd ();
use HTTP::Request ();
use LWP::UserAgent ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_REPO_HOST);
my($_REPO_DIR);
my($_TMP_DIR);
my($_RPM_REPO);

Bivio::IO::Config->register({
    repo_host => 'http://locker.bivio.com:60000',
    repo_dir => '/dip/rpms/',
    tmp_dir => "/var/tmp/bap-$$",
    rpm_repo => '/home/dip/rpms',
});

=head1 METHODS

=cut

=for html <a name="OPTIONS"></a>

=head2 OPTIONS : hash_ref

    {
	build_stage => ['String', 'b'],
#TODO: used in build(), needs a better name
	l_mystery => ['Boolean', 0],
	nodeps => ['Boolean', 0],
	package_suffix => ['String', "HEAD"],
        version => ['String', undef],
    }

=cut

sub OPTIONS {
    return {
	%{__PACKAGE__->SUPER::OPTIONS()},
	build_stage => ['String', 'b'],
#TODO: used in build(), needs a better name
	l_mystery => ['Boolean', 0],
	nodeps => ['Boolean', 0],
	package_suffix => ['String', "HEAD"],
        version => ['String', undef],
    };

}

=for html <a name="OPTIONS_USAGE"></a>

=head2 OPTIONS_USAGE : string

Adds the following to standard options:

    -build_stage - rpm build stage, valid values [p,c,i,b], identical to the rpm(1) -b option
#TODO: used in build(), needs a better name
    -l_mystery - a mystery argument
    -nodeps - install without checking dependencies
    -package_suffix - suffix for rpm file (default: HEAD)
    -version - the version to be built

=cut

sub OPTIONS_USAGE {
    return __PACKAGE__->SUPER::OPTIONS_USAGE()
	    .<<'EOF';
    -build_stage - rpm build stage, valid values [p,c,i,b], identical to the rpm(1) -b option
#TODO: used in build(), needs a better name
    -l_mystery - a mystery argument
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

    my($result) = '';
    my($rpm_stage) = $self->get('build_stage');
    $self->usage_error("Invalid build_stage ", $rpm_stage)
	    unless $rpm_stage =~ /^[pcib]$/;

    my($cvstag) = $self->get('package_suffix');
    my($version) = $self->get_or_default('version', $cvstag);

#TODO: need better name for the mystery argument
    if ($self->unsafe_get('l_mystery')) {
	my($user) = (getpwuid($<))[0];
	$version = $user;
	$cvstag = '';
    }

    my $run_dir = Cwd::cwd;
    if($cvstag) {
        system("rm -rf $_TMP_DIR; mkdir $_TMP_DIR");
        chdir($_TMP_DIR) || die("chdir($_TMP_DIR): $!\n");
	$result .= "Changing directory to $_TMP_DIR\n";
    }
    my(%rpmrc);
    open(RPM, "rpm --showrc|") || die("$!");
    while (<RPM>) {
        /^\-\d+: (\S+)\s+(\S+)/ && ($rpmrc{$1} = $2);
    }
    close(RPM);
    defined($rpmrc{'_arch'}) || ($rpmrc{'_arch'} = 'i386');
    -e $rpmrc{'_arch'} || system("ln -s . $rpmrc{'_arch'}");

    my(@specin, $specout, @rpm_built);
    for my $specin (@rpm_spec_files) {
        $specin =~ /\.spec$/ || ($specin = 'pkgs/' . $specin . '.spec');
        if($cvstag) {
            system("cvs checkout -f -r $cvstag $specin");
        } else {
            -r $specin || system("cvs checkout $specin");
            $specin =~ m,^/, || ($specin = Cwd::cwd . '/'. $specin);
        }
        open(SPECIN, "<$specin") || (warn("$specin: $!"), next);
        @specin = <SPECIN>;
        close(SPECIN);

        $specout = "$specin-bap";
        open(SPECOUT, ">$specout") || (warn("$specout: $!"), next);
        # After rpm 3.0.2, relative filenames fail!
        print SPECOUT <<"EOF";
%define _sourcedir .
%define _topdir .
%define _srcrpmdir .
%define _rpmdir $_TMP_DIR
%define _builddir .
EOF
        if ($cvstag) {
            print SPECOUT "%define cvs cvs checkout -f -r $cvstag \n";
        } else {
            print SPECOUT "%define cvs ls -lR\n";
        }
        my($n, $r, $v);
        grep(/^Name: (.+)/ && ($n = $1), @specin)
                || (warn("$specin: Missing Name: tag!\n"), next);
        if(!grep(/^Release: (.+)/ && ($r = $1), @specin)) {
            $r = _get_date_format();
            print SPECOUT "Release: $r\n";
        }
        if(!grep(/^Version: (.+)/ && ($v = $1), @specin)) {
            print SPECOUT "Version: $version\n";
            $v = $version;
        }
        grep(/^Copyright:/, @specin) || print SPECOUT "Copyright: Bivio\n";
        my($l, $build_root, $source);
        for $l (@specin) {
            if($l =~ /^buildroot: (.+)$/i) {
                $build_root = $1;
                $build_root =~ m,^/,
			|| ($build_root = Cwd::cwd . '/'. $build_root);
                print SPECOUT "BuildRoot: ", $build_root, "\n";
                print SPECOUT "%define allfiles cd $build_root; find . -name CVS -prune -o -type l -print -o -type f -print | sed -e 's/^\.//'\n";
                print SPECOUT "%define allcfgs cd $build_root; find . -name CVS -prune -o -type l -print -o -type f -print | sed -e 's/^\./%config /'\n";
                next;
            } elsif($l =~ /^source: (.+)$/i) {
                $source = $1;
                $source =~ m,^/, || ($source = $run_dir . '/'. $source);
                system("ln -s $source");
#            } elsif($l =~ /^%files -f ([^\/].+)$/i) {
#                # After rpm 3.0.2, relative filenames fail!
#                print SPECOUT "%files -f " . $_TMP_DIR . '/' . $1 . "\n";
#                next;
            }
            print SPECOUT $l;
        }
        close(SPECOUT);

	if ($self->get('noexecute')) {
            $result .= "Would run: rpm -b$rpm_stage $specout\n"
		    ."           in directory $_TMP_DIR\n";
        } else {
            system("exec rpm -b$rpm_stage $specout");
            my $rpm_file = "$rpmrc{'_arch'}/$n-$v-$r.$rpmrc{'_arch'}.rpm";
            if(-f $rpm_file && $cvstag) {
                if(-d $_RPM_REPO) {
                    $result .= "INSTALLING RPM $rpm_file in $_RPM_REPO\n";
                    system("chown httpd.httpd $rpm_file");
                    system("cp -p $rpm_file $_RPM_REPO");
                    # Create link with base name to this RPM
                    $rpm_file = "$n-$v-$r.$rpmrc{'_arch'}.rpm";
                    my $rpm_base = "$n-$v.rpm";
                    unlink("$_RPM_REPO/$rpm_base");
                    system("ln -s $rpm_file $_RPM_REPO/$rpm_base");
                    $result .= "LINKING AS $_RPM_REPO/$rpm_base\n";
                } else {
                    $result .= "COPYING RPM $rpm_file to $run_dir\n";
                    system("cp -p $rpm_file $run_dir");
                }
            }
            unlink("$specout");
        }
    }

    if ($cvstag) {
	my($command) = "rm -rf $_TMP_DIR\n";
	$result .= $command;
	system($command) unless $self->get('noexecute');
    }
    return $result;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item repo_host : string ['http://locker.bivio.com:60000']

=item repo_dir : string ['/dip/rpms/']

=item tmp_dir : string ["/var/tmp/bap-$$"]

=item rpm_repo : string ['/home/dip/rpms'],

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;

    $_REPO_HOST = $cfg->{repo_host};
    $_REPO_DIR = $cfg->{repo_dir};
    $_TMP_DIR = $cfg->{tmp_dir};
    $_RPM_REPO = $cfg->{rpm_repo};
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
    my($result) = '';

    # process optional args
    my($rpm_opt) = '';
    $rpm_opt .= '--force ' if $self->get('force');
    $rpm_opt .= '--nodeps ' if $self->get('nodeps');

    # use proxy settings if present in environment (also used by LWP)
    if(defined($ENV{'http_proxy'})
            && $ENV{'http_proxy'} =~ m!^http://([^:]+):(\d+)!) {
        $rpm_opt .= "--httpproxy $1 --httpport $2 ";
	$result .= "Fetching via http proxy $1:$2\n";
    }

    # install all the packages
    for my $package (@package_names) {
	$package .= '-'.$self->get('package_suffix').'.rpm'
		unless $package =~ /\.rpm$/;
        my($uri) = _create_URI($package);
	my($command) = "rpm -Uvh $rpm_opt $uri\n";
	$result .= $command;
        system($command) unless $self->get('noexecute');
    }
    return $result;
}

=for html <a name="list"></a>

=head2 list() : string

Displays packages created by I<build>.

=cut

sub list {
    my($self) = @_;
    my($result) = '';

    my($uri) = _create_URI('');
    my($ua) = LWP::UserAgent->new();
    $ua->env_proxy();
    my($reply) = $ua->request(HTTP::Request->new('GET', $uri));

    if ($reply->is_success) {
        my(@lines) = split("\n", $reply->content);
        for my $line (@lines) {
	    if ($line =~ /.+\">\s(\S+\.rpm)<\/A>/) {
		$result .= "$1\n";
	    }
        }
    } else {
	Bivio::IO::Alert->warn($uri, ": ", $reply->status_line);
    }
    return $result;
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
        return $_REPO_HOST.$name;
    } else {
        return $_REPO_HOST.$_REPO_DIR.$name;
    }
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

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

__PACKAGE__->main(@main::ARGV) if $0 eq __FILE__;
1;
