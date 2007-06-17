# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::HTTPConf;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::IO::File;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DATA);
my($_VARS) = {
    is_production => 0,
    legacy_rewrite_rules => '',
    cookie_tag => undef,
    listen => undef,
    mail_host => undef,
    root_prefix => undef,
    server_admin => undef,
    server_status_allow => '127.0.0.1',
    server_status_location => '/s',
    timeout => 120,
    servers => 4,
    httpd_init_rc => '/etc/rc.d/init.d/httpd',
    httpd_httpd_conf => '/etc/httpd/conf/httpd.conf',
    limit_request_body => 4194304,
    # Users can supply certain params here
    httpd => my $_HTTPD_VARS = {
	app => 'httpd',
	listen => '80',
    },
    aux_http_conf => '',
    facade_redirects => '',
    # Trick to help _replace_vars
    '$' => '$',
};

sub USAGE {
    return <<'EOF';
usage: b-http-conf [options] command [args...]
commands:
    gen_app app-name [root-prefix] -- writes config for app-name
EOF
}

sub generate {
    my($vars) = shift->validate_vars(@_);
    umask(027);
    foreach my $v (map(_app_vars($vars->{$_}), @{$vars->{apps}})) {
	_write(_httpd_conf($v));
	_write(_app_bconf($v));
	_write(_app_init_rc($v));
	_mkdir($v->{log_directory});
	_write(_logrotate($v));
    }
    _httpd_vars($vars);
    _write($vars->{httpd_init_rc}, _httpd_init_rc());
    _write(_httpd_conf($vars->{httpd}));
    _write(_logrotate($vars->{httpd}));
    return;
}

=for html <a name="validate_vars"></a>

=head2 static validate_vars(string vars) : hash_ref

=cut

sub validate_vars {
    my($self, $vars) = @_;
    # The configuration for an application server is provided via I<vars>, and
    # returned by this routine as a hash_ref.  I<vars> is a perl hash_ref whose keys
    # are the applications to configure, and values are hash_refs containing the
    # config, e.g.
    #
    #     {
    #         petshop => {
    #             listen => 8080,
    #             server_admin => 'webmaster@bivio.biz',
    #         },
    #     }
    #
    # I<vars> may also contain default entries for the attributes defined below, e.g.
    #
    #     {
    #         server_admin => 'webmaster@bivio.biz',
    #         petshop => {
    #             listen => 8080,
    #         },
    #         my_app => {
    #             listen => 8081,
    #         },
    #     }
    #
    # The attributes and their global defaults are defined as follows:
    #
    # =over 4
    #
    # =item listen : int (required)
    #
    # Port the app server listens on.
    #
    # =item servers : int [4]
    #
    # Number of application servers to start.  The number of front-end httpd
    # servers will be 2 x the sum of I<servers> for all apps being configured.
    #
    # =item server_status_allow : string [127.0.0.1]
    #
    # Addresses from which we allow access to I<server_status_location>
    #
    # =item server_status_location : string [/s]
    #
    # Location of Apache server-status
    #
    # =item server_admin : string (required)
    #
    # Email address of webmaster to be set to ServerAdmin.
    #
    # =back
    #
    $vars = {
	%$_VARS,
	%{Bivio::Die->eval_or_die($vars)},
    };
    foreach my $app (
	@{$vars->{apps} = [sort(grep(!exists($_VARS->{$_}), sort(keys(%$vars))))]},
    ) {
	foreach my $k (keys(%$_VARS)) {
	    my($v) = $vars->{$app};
	    $self->usage_error($k, ': variable missing value for ', $app, "\n")
		unless defined($v->{$k}) || defined($v->{$k} = $vars->{$k});
	}
	$vars->{$app}->{app} = $app;
    }
    return $vars
}

sub _app_bconf {
    my($vars) = @_;
    return _replace_vars_for_file($vars, bconf => <<'EOF');
use $root_prefix::BConf;
$root_prefix::BConf->merge_dir({
    'Bivio::Agent::Request' => {
        is_production => $is_production,
    },
    'Bivio::Delegate::Cookie' => {
        tag => '$cookie_tag',
    },
    'Societas::Agent::HTTP::Cookie' => {
        tag => '$cookie_tag',
    },
    'Bivio::UI::Facade' => {
        local_file_root => '/var/www/facades',
        want_local_file_cache => 1,
        http_suffix => '$http_suffix',
        mail_host => '$mail_host',
    },
    'Bivio::Util::HTTPLog' => {
        error_file => '$log_directory/error_log',
    },
});
EOF
}

sub _app_vars {
    my($vars) = @_;
    # Augments vars for a single app ($vars->{$app}) to include _app_vars.  Returns
    # a $vars with updated config.
    my($app) = $vars->{app};
    my($bconf) = "/etc/$app.bconf";
    %$vars = (
	%$vars,
	bconf => $bconf,
	document_root => "/var/www/facades/$app/plain",
	httpd_conf => "/etc/httpd/conf/$app.conf",
	init_rc => "/etc/rc.d/init.d/$app",
	lock_file => "/var/lock/subsys/$app",
	log_directory => "/var/log/$app",
	logrotate => "/etc/logrotate.d/$app",
	pid_file => "/var/run/$app.pid",
	process_name => "$app-httpd",
	content => <<"EOF",
PerlWarn on
PerlFreshRestart off
PerlSetEnv BCONF $bconf
PerlTransHandler Apache::OK
# Override the translation handler to avoid local file permission checks
PerlModule Bivio::Agent::HTTP::Dispatcher

<Location />
    SetHandler perl-script
    PerlHandler Bivio::Agent::HTTP::Dispatcher
</Location>
EOF
    );
    return $vars;
}

sub _app_init_rc {
    my($vars) = @_;
    return _replace_vars_for_file($vars, init_rc => <<'EOF');
#!/bin/bash
#
# Startup script for the $app App Server
#
# chkconfig: 345 84 16
# description: $app Application Server
# processname: $app
# pidfile: $pid_file
# config: $httpd_conf

b_httpd_app=$app

# Source function library.
. $httpd_init_rc
EOF
}

sub _httpd_conf {
    my($vars) = @_;
    return _replace_vars_for_file($vars, 'httpd_conf', <<'EOF');
ResourceConfig /dev/null
AccessConfig /dev/null

Listen $listen

User apache
Group apache
ServerAdmin $server_admin
ServerTokens Min

Timeout $timeout
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 15
MinSpareServers 1
MaxSpareServers $servers
StartServers $servers
MaxClients $servers
MaxRequestsPerChild 100000
LimitRequestBody $limit_request_body

ServerRoot /etc/httpd
PidFile $pid_file
LockFile $lock_file
ScoreBoardFile $log_directory/apache_runtime_status
TypesConfig /etc/mime.types
DefaultType text/plain
UseCanonicalName Off
LogFormat "%V %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
CustomLog $log_directory/access_log combined
ErrorLog $log_directory/error_log
LogLevel info
ExtendedStatus On

DocumentRoot /var/www/html

<Directory />
    AllowOverride None
    Options FollowSymLinks
</Directory>

$content

<Location $server_status_location>
    SetHandler server-status
    deny from all
    allow from $server_status_allow
</Location>

$aux_http_conf

BrowserMatch "Mozilla/2" nokeepalive
BrowserMatch "MSIE 4\.0b2;" nokeepalive downgrade-1.0 force-response-1.0
BrowserMatch "RealPlayer 4\.0" force-response-1.0
BrowserMatch "Java/1\.0" force-response-1.0
BrowserMatch "JDK/1\.0" force-response-1.0
EOF
}

sub _logrotate {
    my($vars) = @_;
    return _replace_vars_for_file($vars, logrotate => <<'EOF');
$log_directory/access_log $log_directory/agent_log $log_directory/error_log $log_directory/referer_log {
    missingok
    sharedscripts
    postrotate
        /bin/kill -HUP `cat $pid_file 2>/dev/null` 2> /dev/null || true
    endscript
}
EOF
}

sub _mkdir {
    my($name) = @_;
    $name =~ s,^/,,;
    return Bivio::IO::File->mkdir_p($name);
}

sub _httpd_init_rc {
    unless ($_DATA) {
	local($/);
	$_DATA = <DATA>;
	close(DATA);
    }
    my($d) = $_DATA;
    return \$d;
}

sub _httpd_vars {
    my($vars) = @_;
    my($v) = $vars->{httpd};
    %$v = (
	%$_VARS,
	%$_HTTPD_VARS,
	map(($_ => $vars->{$_}), qw(
            server_status_allow
	    server_status_location
	    server_admin
        )),
	%$v,
    );
    _app_vars($v);
    foreach my $a (@{$vars->{apps}}) {
	my($av) = $vars->{$a};
	$av->{rewrite_rules}
	    = _replace_vars($av, "rewrite_rules($a)", <<'EOF');
    RewriteRule ^/./ - [L]
    RewriteRule .*favicon.ico$$ /i/favicon.ico [L]
    RewriteRule ^(.*) http://$http_suffix:$listen$$1 [proxy]
EOF
	$av->{permanent_redirects} = $av->{http_suffix} ne "www.$av->{mail_host}"
	    ? '' : _replace_vars($av, "permanent_redirects($a)", <<'EOF');
<VirtualHost *>
    ServerName $mail_host
    RedirectPermanent / http://$http_suffix/
</VirtualHost>
EOF
	$av->{httpd_content}
	    = _replace_vars($av, "httpd_content($a)", <<'EOF');
<VirtualHost *>
    ServerName $http_suffix
    DocumentRoot /var/www/facades/$app/plain
    ProxyVia on
    ProxyIOBufferSize 4194304
    RewriteEngine On
    RewriteOptions inherit
$legacy_rewrite_rules
$rewrite_rules
</VirtualHost>
$permanent_redirects
$facade_redirects
EOF
    }
    my($t);
    $v->{content} = join(
	"\n",
	_replace_vars($vars->{httpd}, "httpd_content", <<'EOF'),
NameVirtualHost *
<VirtualHost *>
    ServerName $host_name
    DocumentRoot /var/www/html
</VirtualHost>
EOF
	map($vars->{$_}->{httpd_content}, @{$vars->{apps}}),
    );
    my($n) = 0;
    foreach my $s (@{$vars->{apps}}) {
	$n += $vars->{$s}->{servers};
	foreach my $var (qw(limit_request_body timeout)) {
	    $v->{$var} = $vars->{$s}->{$var}
		if $vars->{$s}->{$var} > ($v->{$var} || 0);
	}
    }
    $v->{server_admin} ||= 'webmaster@' . $v->{host_name};
    $v->{servers} = $n * 2;
    return;
}

sub _replace_vars {
    my($vars, $name, $template) = @_;
    # One of the $_VARS is '$'
    $template =~ s{\$(\w+|\$)}{
	defined($vars->{$1}) ? $vars->{$1}
	    : Bivio::Die->die("$1: in template ($name), but not in ", $vars)
    }xseg;
    return $template;
}

sub _replace_vars_for_file {
    my($vars, $name) = @_;
    return ($vars->{$name}, \(_replace_vars(@_)));
}

sub _write {
    my($name, $data) = @_;
    $name =~ s{^/}{};
    Bivio::IO::File->mkdir_parent_only($name);
    my($generator) = ('$Header$' =~ m{Header:\s*(.+?)\s*\$}i)[0]
	|| __PACKAGE__;
    $$data =~ s{^(#!.+?\n|)}{$1 . <<"EOF"}es;
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: $generator
################################################################
EOF
    return Bivio::IO::File->write($name, $$data);
}

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
__DATA__
#!/bin/bash
#
# Startup script for the Apache Web Server
#
# chkconfig: 345 85 15
# description: Apache is a World Wide Web server.  It is used to serve \
#	       HTML files and CGI.
# processname: httpd
# pidfile: /var/run/httpd.pid
# config: /etc/httpd/conf/access.conf
# config: /etc/httpd/conf/httpd.conf
# config: /etc/httpd/conf/srm.conf

# Source function library.
. /etc/rc.d/init.d/functions

# This will prevent initlog from swallowing up a pass-phrase prompt.
INITLOG_ARGS=""

# Source additional OPTIONS if we have them.
if [ -f /etc/sysconfig/apache ] ; then
	. /etc/sysconfig/apache
fi

httpd=${b_httpd_app:-/usr/sbin/httpd}
prog=$(basename $httpd)
RETVAL=0

# Change the major functions into functions.
moduleargs() {
	moduledir=/usr/lib/apache
	moduleargs=`
	/usr/bin/find ${moduledir} -type f -perm -0100 -name "*.so" | env -i tr '[:lower:]' '[:upper:]' | awk '{\
		gsub(/.*\//,"");\
		gsub(/^MOD_/,"");\
		gsub(/^LIB/,"");\
		gsub(/\.SO$/,"");\
		print "-DHAVE_" $0}'`
	echo ${moduleargs}
}
start() {
	echo -n $"Starting $prog: "
	# The goal of this is to change the process name
	daemon --check=$prog perl -e "'exec {q{/usr/sbin/httpd}} (qw{$prog $(moduleargs) $OPTIONS -f /etc/httpd/conf/$prog.conf}) or die(qq{exec: \$!})'"
	RETVAL=$?
	echo
	[ $RETVAL = 0 ] && touch /var/lock/subsys/$prog
	return $RETVAL
}
stop() {
	echo -n $"Stopping $prog: "
	killproc $prog
	RETVAL=$?
	echo
	[ $RETVAL = 0 ] && rm -f /var/lock/subsys/$prog /var/run/$prog.pid
}

# See how we were called.
case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  status)
	status $prog
	;;
  restart)
	stop
	start
	;;
  reload)
	echo -n $"Reloading $prog: "
	killproc $process -HUP
	RETVAL=$?
	echo
	;;
  condrestart)
	if [ -f /var/run/$prog.pid ] ; then
		stop
		start
	fi
	;;
  *)
	echo $"Usage: $prog {start|stop|restart|reload|condrestart|status}"
	exit 1
esac

exit $RETVAL
