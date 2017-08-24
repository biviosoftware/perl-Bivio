# Copyright (c) 1999-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::HTTPD;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
b_use('IO.ClassLoaderAUTOLOAD');

my($_V2) = b_use('Agent.Request')->if_apache_version(2);
my($_HTTPD) = _find_file($_V2 ? qw(
    /usr/local/apache/bin/httpd2
    /usr/sbin/httpd2
    /usr/sbin/apache2
    /usr/sbin/httpd
) : qw(
    /usr/local/apache/bin/httpd
    /usr/sbin/httpd
));
Bivio::IO::Config->register(my $_CFG = {
    port => undef,
    handler => 'Bivio::Agent::HTTP::Dispatcher',
    additional_locations => '',
    additional_directives => '',
});

sub USAGE {
    return <<'EOF';
usage: bivio httpd [options] command [args..]
commands
   assert_in_exec_dir -- dies if not in execution directory
   run -- starts httpd in foreground
   run_background -- starts httpd in background
   run_db [breakpoint] -- starts httpd with the Devel::BivioDB debugger
EOF
}

sub assert_in_exec_dir {
    b_die(`pwd`, ': wrong directory to write restart sentinel')
	unless -r 'httpd.pid';
    return;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub internal_pre_exec {
    # Perform operations before httpd is started.
    return;
}

sub run {
    my($self, $background) = shift->name_args([[qw(background Boolean)]], \@_);
    $self->get_request;
    my($pwd) = b_use('Type.FilePath')->join(
	b_use('UI.Facade')->get_local_file_root,
	'httpd',
    );
#TODO: Let ShellUtil handle options; Create a default handler for commands
    local($_);
    if ($ENV{PERLLIB}) {
	my($httpd) = $ENV{PERLLIB} . '../external/apache/src/httpd';
	-x $httpd && ($_HTTPD = $httpd);
    }
    if ($self->is_execute) {
        -f "$pwd/httpd.pid" && (kill('QUIT', `cat $pwd/httpd.pid`), sleep(5));
	Bivio::IO::File->rm_rf($pwd);
	Bivio::IO::File->mkdir_p($pwd);
	CORE::system("cd $pwd; rm -f httpd.lock.* httpd.pid httpd[0-9]*.conf httpd[0-9]*.bconf httpd*.sem modules");
	Bivio::IO::File->mkdir_p("$pwd/files");
	_symlink($pwd, "$pwd/logs");
	_symlink(_find_file($_V2 ? qw(
            /usr/lib64/httpd/modules
            /usr/lib/apache2/modules
            /usr/lib64/apache2/modules
            /usr/local/apache2/libexec
            /usr/lib/apache2
            /usr/lib64/apache2
	    /usr/lib/httpd/modules
	) : qw(
	    /usr/lib/apache
	    /usr/libexec/httpd
	    /usr/local/apache/libexec
	)), "$pwd/modules");
    }
    my($log) = $background ? 'stderr.log' : '|/bin/cat';
    my($mime_types) = _find_file('/etc/mime.types', '/etc/httpd/mime.types',
			     '/usr/local/apache/conf/mime.types');
    my($keepalive) = $background ? 'on' : 'off';
    my($port) = $_CFG->{port} || b_die('port parameter not supplied');
    my($additional_directives) = $_CFG->{additional_directives};
    my($additional_locations) = $_CFG->{additional_locations};
    my($user) = getpwuid($>) || $>;
    my($group) = getgrgid($)) || $);
    my($hostname) = b_use('Bivio.BConf')->bconf_host_name;
    my($handler) = $_CFG->{handler};
    my($perl_module) = $handler =~ /^\+/ ? "" : "PerlModule $_CFG->{handler}";
    my(@start_mode) = $background ? () : ('-X');
    my($reload) = 'PerlInitHandler Bivio::Test::Reload';
    my($modules) = _dynamic_modules($_HTTPD);
    my($max_requests_per_child) = $background ? 120 : 100000;
    my($pass_env) = join(
	"\n",
	map(("PassEnv $_", "PerlPassEnv $_"),
	    grep(
		exists($ENV{$_}),
		qw(
		    BCONF
		    BIVIODB_BREAKPOINT
		    BIVIO_HTTPD_PORT
		    BIVIO_IS_2014STYLE
		    BIVIO_HOST_NAME
		    DBI_PASS
		    DBI_USER
		    HOME
		    ORACLE_HOME
		    PERL5OPT
	        ),
	    ),
	),
    );
    my($conf) = $self->is_execute ? "httpd$$.conf" : "&STDOUT";
    open(OUT, ">$pwd/$conf") || die("open $conf: $!");
    my($apache_status) = $_V2 ? 'PerlResponseHandler Apache2::Status'
	: 'PerlHandler Apache::Status';
    my($perl_handler) = $_V2 ? 'PerlResponseHandler' : 'PerlHandler';
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
    if ($self->is_execute) {
	$self->print("Starting: $_HTTPD @start_mode -d $pwd -f $pwd/$conf on port $port\n");
	$self->print("tail -f files/httpd/stderr.log\n")
	    if $background;
	Bivio::IO::File->chdir($pwd);
	while (1) {
	    $self->internal_pre_exec;
	    if ($background) {
		exec($_HTTPD, @start_mode, '-d', $pwd, '-f', $conf);
		die("$_HTTPD: $!");
	    }
	    system($_HTTPD, @start_mode, '-d', $pwd, '-f', $conf);
	    last
		unless b_use('Action.DevRestart')->restart_requested;
	}
    }
    else {
	$self->print("Would start: $_HTTPD -X -d $pwd -f $pwd/$conf\n");
    }
}

sub run_background {
    return shift->run(1);
}

sub run_db {
    my($self, $breakpoint) = @_;
    $ENV{PERL5OPT} = '-d:BivioDB';
    $ENV{BIVIODB_BREAKPOINT} = $breakpoint ? $breakpoint : '';
    return $self->run;
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
#TODO: wordpress requires mod_dir, but including it causes a
#      slash to be appended to image paths
#TODO: wordpress requires mod_php5:libphp5:libphp5.c, but it
#      causes the server to crash
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
	    actions
	    auth_basic
	    auth_digest
	    authn_anon
	    authn_dbm
	    authn_file
	    authz_core
	    authz_dbm
	    authz_groupfile
	    authz_host
	    authz_owner
	    authz_user
	    autoindex
	    cache
	    cgi
	    dav
	    dav_fs
	    deflate
	    expires
	    ext_filter
            filter
	    headers
	    include
	    info
	    log_config
	    logio
	    mime_magic
            mpm_prefork
	    negotiation
	    perl
	    proxy
	    proxy_balancer
	    proxy_connect
	    proxy_ftp
	    proxy_http
            reqtimeout
            slotmem_shm
	    speling
	    suexec
            unixd
	    userdir
	    usertrack
	    version
	    vhost_alias
	) : qw(
	    info
	    config_log:mod_log_config:mod_log_config.c
	    perl:libperl
	),
# unixd - don't need chroot with docker
# mpm_prefork - don't need prefork as we have fixed servers
# socache_shmcb - preformance
#  - do we need this?
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
    b_die('could not find any of: ', \@path);
    # DOES NOT RETURN
}

sub _symlink {
    my($file, $link) = @_;
    -l $link || CORE::symlink($file, $link)
	|| die("symlink($file, $link): $!");
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
#Only valid with MP_TRACE compile option
#PerlTrace all
# Can't be on and use PERLLIB.
$reload
$perl_module
$pass_env
$version_config


Timeout 60
KeepAlive $keepalive
MinSpareServers 1
MaxSpareServers 4
StartServers 1
MaxClients 4
MaxRequestsPerChild $max_requests_per_child
LimitRequestBody 4194304
RequestReadTimeout header=2

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
DefaultRuntimeDir .

ExtendedStatus On
AddOutputFilterByType DEFLATE application/json

<Directory />
    AllowOverride None
    Options +FollowSymLinks
</Directory>

$additional_directives

ErrorDocument 502 /m/maintenance.html
ErrorDocument 413 /m/upload-too-large.html

<VirtualHost *:$port>
    <Location />
        Require all granted
        SetHandler perl-script
        $perl_handler $handler
    </Location>
    <Location /s>
        Require local
        SetHandler perl-script
        $apache_status
    </Location>
    <Location /z>
        Require local
        SetHandler server-status
        $apache_status
    </Location>
    $additional_locations
</VirtualHost>

BrowserMatch "Mozilla/2" nokeepalive
BrowserMatch "MSIE 4\.0b2;" nokeepalive downgrade-1.0 force-response-1.0
BrowserMatch "RealPlayer 4\.0" force-response-1.0
BrowserMatch "Java/1\.0" force-response-1.0
BrowserMatch "JDK/1\.0" force-response-1.0
