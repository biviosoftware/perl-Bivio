# Copyright (c) 1999-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::HTTPD;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::IO::ClassLoader;
use Bivio::IO::Config;
use Bivio::IO::File;
use Sys::Hostname ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_V2) = b_use('Bivio::Agent::Request')->if_apache_version(2 => sub {1});
my($_HTTPD) = _find_file($_V2 ? qw(
    /usr/local/apache/bin/httpd2
    /usr/sbin/httpd2
) : qw(
    /usr/local/apache/bin/httpd
    /usr/sbin/httpd
));
Bivio::IO::Config->register(my $_CFG = {
    port => Bivio::IO::Config->REQUIRED,
    handler => 'Bivio::Agent::HTTP::Dispatcher',
    additional_locations => '',
    additional_directives => '',
});
my($_WLFC_ERROR) = <<'EOF';
Could not set want_local_file_cache.  Your .bconf needs:
    'Bivio::UI::Facade' => {
         want_local_file_cache => 0,
    },
EOF

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub internal_pre_execute {
    # Perform operations before httpd is started.
    return;
}

sub main {
    my($self, @argv) = @_;
    my($execute) = 1;
    my($background) = 0;
    my($server_name) = undef;
    my($at_mode) = 0;
    my($pwd) = $self->get_project_root() . '/httpd';
#TODO: Let ShellUtil handle options; Create a default handler for commands
    local($_);
    while (@argv) {
	$_ = shift(@argv);
	/^-n/ && ($execute = 0, next);
	/^-(?:b|bg|background)/ && ($background = 1, next);
	/^--at/ && ($at_mode = 1, next);
	/^-/ && &_usage("unknown option \"$_\"");
	defined($server_name) && &_usage('too many arguments');
	$server_name = $_;
    }
    if ($ENV{PERLLIB}) {
	my($httpd) = $ENV{PERLLIB} . '../external/apache/src/httpd';
	-x $httpd && ($_HTTPD = $httpd);
    }
    if ($execute) {
        -f "$pwd/httpd.pid" && (kill('TERM', `cat $pwd/httpd.pid`), sleep(5));
	Bivio::IO::File->rm_rf($pwd);
	Bivio::IO::File->mkdir_p($pwd);
	CORE::system("cd $pwd; rm -f httpd.lock.* httpd.pid httpd[0-9]*.conf httpd[0-9]*.bconf httpd*.sem modules");
	Bivio::IO::File->mkdir_p("$pwd/files");
	_symlink($pwd, "$pwd/logs");
	_symlink(_find_file($_V2 ? qw(
            /usr/local/apache/libexec
            /usr/lib/apache2
	) : qw(
	    /usr/lib/apache
	    /usr/libexec/httpd
	    /usr/local/apache/libexec
	)), "$pwd/modules");
    }
    my($log) = $background ? 'stderr.log' : '|cat';
    my($mime_types) = _find_file('/etc/mime.types', '/etc/httpd/mime.types',
			     '/usr/local/apache/conf/mime.types');
    my($keepalive) = $background ? 'on' : 'off';
    my($port) = $_CFG->{port};
    my($additional_directives) = $_CFG->{additional_directives};
    my($additional_locations) = $_CFG->{additional_locations};
    my($user) = getpwuid($>) || $>;
    my($group) = getgrgid($)) || $);
    my($hostname) = Sys::Hostname::hostname();
    my($handler) = $_CFG->{handler};
    my($perl_module) = $handler =~ /^\+/ ? "" : "PerlModule $_CFG->{handler}";
    my(@start_mode) = $background ? () : ('-X');

    # write custom bconf
    my($bconf_data) = Bivio::IO::File->read($ENV{'BCONF'});
    die($_WLFC_ERROR, "\n")
        if $at_mode && !($$bconf_data =~
            s/(\bwant_local_file_cache)\s+=>\s+\d,/$1 => 1/);
    Bivio::IO::File->write("$pwd/httpd$$.bconf", $bconf_data);
    _symlink(
	Bivio::IO::File->absolute_path(File::Basename::dirname($ENV{'BCONF'}))
	    . '/bconf.d',
	"$pwd/bconf.d",
    ) unless -l "$pwd/bconf.d";
    my($bconf) = "PerlSetEnv BCONF $pwd/httpd$$.bconf";

     my($reload) = $at_mode
         ? ''
         : 'PerlInitHandler Bivio::Test::Reload';
    my($hostip) = sprintf("%d.%d.%d.%d",
            unpack('C4', (gethostbyname($hostname))[4]));

    my($modules) = _dynamic_modules($_HTTPD);

    my($conf) = $execute ? "httpd$$.conf" : "&STDOUT";
    open(OUT, ">$pwd/$conf") || die("open $conf: $!");
    my($apache_status) = $_V2 ? 'PerlResponseHandler Apache2::Status'
	: 'PerlHandler Apache::Status';
    my($version_config) = $_V2 ? <<'2' : <<'1';
PerlModule Apache2::compat
2
ResourceConfig /dev/null
AccessConfig /dev/null
PerlFreshRestart off
1
    foreach my $line (<DATA>) {
	$line =~ s/(\$[a-z0-9_]+\b)/$1/eeg;
    }
    continue {
	(print OUT $line) || die("write $conf: $!");
    }
    close(OUT) || die("close $conf: $!");
    close(DATA);
    if ($execute) {
	print(STDERR "Starting: $_HTTPD @start_mode -d $pwd -f $pwd/$conf on port $port\n");
	print(STDERR "tail -f stderr.log\n")
	    if $background;
	Bivio::IO::File->chdir($pwd);
	$self->internal_pre_execute();
	exec($_HTTPD, @start_mode, '-d', $pwd, '-f', $conf);
	die("$_HTTPD: $!");
    }
    else {
	print "Would start: $_HTTPD -X -d $pwd -f $pwd/$conf\n";
    }
}

sub _dynamic_modules {
    # (string) : string
    # Returns AddModule and LoadModule statements.
    my($httpd) = @_;
    return '' if $] < 5.006;
    my($loaded) = {map {
	/\s*(mod_\w+\.c)/ ? ($1, 1) : ();
    } split("\n", `$httpd -l`)};
    my($load);
    my($add);
    foreach my $module (
	qw(
	    env
	    mime
	    status
	    rewrite
	    setenvif
            alias
        ),
        $_V2 ? qw(
            log_config:mod_log_config:mod_log_config.c
	    perl
	) : qw(
	    info
	    config_log:mod_log_config:mod_log_config.c
	    perl:libperl
	),
    ) {
	my($base, $so, $mod) = split(/:/, $module);
	$mod ||= $_V2 ? "$base.c" : "mod_$base.c";
	$add .= "AddModule $mod\n";
	next if $loaded->{$mod};
	$so ||= "mod_$base";
	$load .= "LoadModule ${base}_module\t\tmodules/$so.so\n";
    }
    return ''
        unless $load;
    return $load
        . ($_V2 ? '' : "ClearModuleList\nAddModule mod_so.c\n" . $add);
}

sub _find_file {
    my(@path) = @_;
    foreach my $f (@path) {
	return $f
	    if -e $f;
    }
    die('Could not find any of: ', @path);
    # DOES NOT RETURN
}

sub _symlink {
    my($file, $link) = @_;
    -l $link || CORE::symlink($file, $link)
	|| die("symlink($file, $link): $!");
}

sub _usage {
    my($msg) = join('', @_);
    print STDERR <<"EOF";
$0: $msg
usage: $0 [--config] [-n] [-background] [server-name]
EOF
    exit(1);
}

1;

__DATA__
#
# This file was dynamically generated by <$0>
#

$modules

Listen $port
User $user
Group $group
ServerAdmin $user

PerlWarn on
# Can't be on and use PERLLIB.
$bconf
$reload
$perl_module
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
$version_config

Timeout 60
KeepAlive $keepalive
MinSpareServers 1
MaxSpareServers 4
StartServers 1
MaxClients 4
MaxRequestsPerChild 100000
LimitRequestBody 4194304

ServerRoot $pwd
# This is technically incorrect.
DocumentRoot $pwd/files
ServerName localhost.localdomain
PidFile httpd.pid
ErrorLog $log
# Possible values include: debug, info, notice, warn, error, crit,
# alert, emerg.
LogLevel debug
LogFormat "%{host}i %h %P %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
CustomLog $log combined
TypesConfig $mime_types
DefaultType text/plain
LockFile httpd.lock

<Directory />
    AllowOverride None
    Options FollowSymLinks
</Directory>

$additional_directives

ErrorDocument 502 /m/maintenance.html
ErrorDocument 413 /m/upload-too-large.html

<VirtualHost *:$port>
    <Location />
        SetHandler perl-script
        PerlHandler $handler
    </Location>
    <Location /s>
        SetHandler perl-script
        $apache_status
    </Location>
    $additional_locations
</VirtualHost>

BrowserMatch "Mozilla/2" nokeepalive
BrowserMatch "MSIE 4\.0b2;" nokeepalive downgrade-1.0 force-response-1.0
BrowserMatch "RealPlayer 4\.0" force-response-1.0
BrowserMatch "Java/1\.0" force-response-1.0
BrowserMatch "JDK/1\.0" force-response-1.0
