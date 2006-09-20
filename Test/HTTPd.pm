# Copyright (c) 2006 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTTPd;
use strict;
$Bivio::Test::HTTPd::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::HTTPd::VERSION;

=head1 NAME

Bivio::Test::HTTPd - starts Apache running Bivio::Agent::HTTP::Dispatcher

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::HTTPd;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Test::HTTPd::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Test::HTTPd>

=cut

=head1 ENVIRONMENT

=over 4

=item $PERLLIB

Must point to the appropriate development directory if you are
starting the server for testing your own copy.  See L<"FILES">.

=back

=head1 FILES

=over 4

=item httpd.lock.*

is removed and rewritten with new pid

=item httpd.pid

is removed and rewritten with new pid

=item httpd[0-9]*.conf

is removed and rewritten with new pid

=item $PERLLIB/../external/apache/src/httpd

binary to be used if it exists and is executable

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::ClassLoader;
use Cwd ();
use Sys::Hostname ();

#=VARIABLES
my($_HTTPD) = _find_file(qw(
    /usr/local/apache/bin/httpd
    /usr/sbin/httpd
));
Bivio::IO::Config->register({
    Bivio::IO::Config->NAMED => {
	'port' => Bivio::IO::Config->REQUIRED,
	'handler' => 'Bivio::Agent::HTTP::Dispatcher',
    },
});

=head1 METHODS

=cut

=for html <a name="PRJ_ROOT"></a>

=head2 PRJ_ROOT() : string

Return $PRJ_ROOT env variable

=cut

sub PRJ_ROOT {
    Bivio::Die->die('$PRJ_ROOT not defined in env')
        unless $ENV{PRJ_ROOT};
    return $ENV{PRJ_ROOT};
}

# We don't do dynamic reconfiguration
sub handle_config {
#    shift->SUPER::handle_config(@_);
}

sub main {
    my($self, @argv) = @_;
    my($execute) = 1;
    my($background) = 0;
    my($server_name) = undef;
#    my($pwd) = &Cwd::cwd();
    my($pwd) = $self->PRJ_ROOT . '/httpd';
    mkdir($pwd)
	unless -e $pwd;

    local($_);
    while (@argv) {
	$_ = shift(@argv);
	/^-n/ && ($execute = 0, next);
	/^-(?:b|bg|background)/ && ($background = 1, next);
	/^-/ && &_usage("unknown option \"$_\"");
	defined($server_name) && &_usage('too many arguments');
	$server_name = $_;
    }
    my($cfg) = Bivio::IO::Config->get(
	defined($server_name) ? $server_name : 'http');
    if ($ENV{PERLLIB}) {
	my($httpd) = $ENV{PERLLIB} . '../external/apache/src/httpd';
	-x $httpd && ($_HTTPD = $httpd);
    }
    if ($execute) {
        -f "$pwd/httpd.pid" && (kill('TERM', `cat $pwd/httpd.pid`), sleep(5));
	CORE::system("(cd $pwd; rm -f httpd.lock.* httpd.pid httpd[0-9]*.conf httpd*.sem modules)");
	_symlink($pwd, "$pwd/logs");
	_symlink(_find_file('/usr/lib/apache', '/usr/libexec/httpd'),
	    "$pwd/modules") unless $] < 5.006;
    }
    else {
	print <<"EOF";
(cd $pwd;
  rm -f httpd.lock.* httpd.pid httpd[0-9]*.conf httpd*.sem;
  ln -s . logs;
)
EOF
    }
    my($log) = $background ? 'stderr.log' : '|cat';
    my($mime_types) = _find_file('/etc/mime.types', '/etc/httpd/mime.types');
    my($keepalive) = $background ? 'on' : 'off';
    my($port) = $cfg->{port};
    my($user) = getpwuid($>) || $>;
    my($group) = getgrgid($)) || $);
    my($hostname) = Sys::Hostname::hostname();
    my($handler) = $cfg->{handler};
    my($perl_module) = $handler =~ /^\+/ ? "" : "PerlModule $cfg->{handler}";
    my(@start_mode) = $background ? () : ('-X');
    my($bconf) = $ENV{'BCONF'}
	? "PerlSetEnv BCONF $ENV{'BCONF'}" : '';
    my($hostip) = sprintf("%d.%d.%d.%d",
            unpack('C4', (gethostbyname($hostname))[4]));

    my($facades) = '';
    # TIGHT COUPLING with Bivio::UI::Facade
    foreach my $facade (@{_get_facade_uri_list()}) {
        my($server) = $facade =~ /\./ ? $facade : $facade . '.' . $hostname;
	$facades .= <<"EOF";
	    <VirtualHost *:$port>
		ServerName $server
		RewriteEngine On
		RewriteLog rewrite.log
		RewriteLogLevel 0

		RewriteRule ^(.*) /*$facade\$1 [NS,PT]

		SetHandler perl-script
		PerlHandler $handler
	    </VirtualHost>
EOF
    }

    my($modules) = _dynamic_modules($_HTTPD);

    local($_);
    my($conf) = $execute ? "httpd$$.conf" : "&STDOUT";
    open(OUT, ">$pwd/$conf") || die("open $conf: $!");
    while (<DATA>) {
	# Yup, want an extra "e" to get double interpolation.  Kewl, huh?
	s/<(\$\w+)>/$1/eeg;
    }
    continue {
	(print OUT) || die("write $conf: $!");
    }
    close(OUT) || die("close $conf: $!");
    close(DATA);
    if ($execute) {
	print(STDERR "Starting: $_HTTPD @start_mode -d $pwd -f $pwd/$conf on port $port\n");
	print(STDERR "tail -f stderr.log\n")
	    if $background;
#	exec("$_HTTPD", @start_mode, '-d', $pwd, '-f', "$conf");
	exec("(cd $pwd; $_HTTPD @start_mode -d $pwd -f $conf)");
	die("$_HTTPD: $!");
    }
    else {
	print "Would start: $_HTTPD -X -d $pwd -f $pwd/$conf\n";
    }
}

#=PRIVATE SUBROUTINES

# _dynamic_modules(string httpd) : string
#
# Returns AddModule and LoadModule statements.
#
sub _dynamic_modules {
    my($httpd) = @_;
    return '' if $] < 5.006;
    my($loaded) = {map {
	/\s*(mod_\w+\.c)/ ? ($1, 1) : ();
    } split("\n", `$httpd -l`)};
    my($load);
    my($add);
    foreach my $module (qw(
	env
	config_log:mod_log_config:mod_log_config.c
	mime
	status
	info
	rewrite
	setenvif
	perl:libperl
    )) {
	my($base, $so, $mod) = split(/:/, $module);
	$mod ||= "mod_$base.c";
	$add .= "AddModule $mod\n";
	next if $loaded->{$mod};
	$so ||= "mod_$base";
	$load .= "LoadModule ${base}_module\t\tmodules/$so.so\n";
    }
    return '' unless $load;
    return $load . "ClearModuleList\nAddModule mod_so.c\n" . $add;
}

sub _symlink {
    my($file, $link) = @_;
    -e $link || CORE::symlink($file, $link)
	|| die("symlink($file, $link): $!");
}

sub _find_file {
    my(@path) = @_;
    foreach my $f (@path) {
	return $f
	    if -e $f;
    }
    die('Could not find any of: ', \@path);
    # DOES NOT RETURN
}

# _get_facade_uri_list()
#
# Returns list of facade uris by reaching inside the Facades.
#
sub _get_facade_uri_list {
    my(@files, @uri);

    # The filter is used as a hack to load, just get the names of the uris,
    # but return false so nothing loads.
    Bivio::IO::ClassLoader->map_require_all('Facade', sub {
	my($class, $file) = @_;
	push(@files, $file);
	return 0;
    });

    foreach my $file (@files) {
	open(IN, $file) || next;
	# Find the uri if set, otherwise the package base name in lower case.
	my($uri) = $file;
	$uri =~ s/.*\/(\w+)\.pm$/\L$1/;
	my($uri2) = grep(s/^\s*uri\s*=>\s*['"]([^'"]+).*\n/\L$1/, <IN>);
	push(@uri, $uri2 || $uri);
    }
    close(IN);
    return \@uri;
}

sub _usage {
    my($msg) = join('', @_);
    print STDERR <<"EOF";
$0: $msg
usage: $0 [--config] [-n] [-background] [server-name]
EOF
    exit(1);
}

=head1 COPYRIGHT

Copyright (c) 2006 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;

__DATA__
#
# This file was dynamically generated by <$0>
#
ResourceConfig /dev/null
AccessConfig /dev/null

<$modules>

Listen <$port>
User <$user>
Group <$group>
ServerAdmin <$user>

PerlWarn on
# Can't be on and use PERLLIB.
PerlFreshRestart off
<$bconf>
PerlInitHandler Bivio::Test::Reload
<$perl_module>
#RJN: This doesn't work for some reason
PassEnv HOME
PassEnv ORACLE_HOME
PassEnv DBI_USER
PassEnv DBI_PASS
PassEnv ORACLE_SID
PerlPassEnv HOME
PerlPassEnv ORACLE_HOME
PerlPassEnv DBI_USER
PerlPassEnv DBI_PASS
PerlPassEnv ORACLE_SID

Timeout 60
KeepAlive <$keepalive>
MinSpareServers 1
MaxSpareServers 4
StartServers 1
MaxClients 4
MaxRequestsPerChild 100000
LimitRequestBody 4194304

ServerRoot <$pwd>
# This is technically incorrect.
DocumentRoot <$pwd>/files/www/plain
PidFile httpd.pid
ErrorLog <$log>
# Possible values include: debug, info, notice, warn, error, crit,
# alert, emerg.
LogLevel debug
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
CustomLog <$log> combined
TypesConfig <$mime_types>
DefaultType text/plain
LockFile httpd.lock

<Directory />
    AllowOverride None
    Options FollowSymLinks
</Directory>

ErrorDocument 502 /m/maintenance.html
ErrorDocument 413 /m/upload-too-large.html

<Location /s>
    SetHandler perl-script
    PerlHandler Apache::Status
</Location>

NameVirtualHost *:<$port>

<VirtualHost *:<$port>>
    ServerName <$hostname>
    SetHandler perl-script
    PerlHandler <$handler>
</VirtualHost>

<$facades>

BrowserMatch "Mozilla/2" nokeepalive
BrowserMatch "MSIE 4\.0b2;" nokeepalive downgrade-1.0 force-response-1.0
BrowserMatch "RealPlayer 4\.0" force-response-1.0
BrowserMatch "Java/1\.0" force-response-1.0
BrowserMatch "JDK/1\.0" force-response-1.0
