# Copyright (c) 2005-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::HTTPConf;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = b_use('IO.File');
my($_SA) = b_use('Type.StringArray');
my($_V2) = b_use('Agent.Request')->if_apache_version(2, 1, 0);
my($_STRIP_VERSION) = $_V2 ? qr{^\s*v1:.*\n|\bv2:}m : qr{^\s*v2:.*\n|\bv1:}m;
my($_INIT_RC_V1);
my($_INIT_RC_V2);
my($_INIT_RC) = $_V2 ? \$_INIT_RC_V2 : \$_INIT_RC_V1;
my($_DATA);
my($_VARS) = {
    aliases => [],
    app_names_txt => '/etc/httpd/conf/app-names.txt',
    aux_http_conf => '',
    can_secure => 0,
    cookie_domain => '',
    cookie_tag => undef,
    facade_redirects => '',
    facade_uri => 1,
    global_params => '',
    httpd_httpd_conf => '/etc/httpd/conf/httpd.conf',
    httpd_init_rc => '/etc/rc.d/init.d/httpd',
    is_production => 0,
    legacy_rewrite_rules => '',
    limit_request_body => 50_000_000,
    listen => undef,
    mail_aliases => [],
    mail_hosts_txt => '/etc/httpd/conf/local-host-names.txt',
    no_proxy => 0,
    root_prefix => undef,
    server_admin => undef,
    server_status_allow => '127.0.0.1',
    server_status_location => '/s',
    servers => 4,
    ssl_chain => '',
    # ssl_crt is not defined so it can't be present at global level
    ssl_listen => '',
    ssl_mdc => 0,
    ssl_multi_crt => '',
    ssl_only => 0,
    timeout => 120,
    uris_txt => '/etc/httpd/conf/uris.txt',
    # Users can supply certain params here
    httpd => my $_HTTPD_VARS = {
	app => 'httpd',
	listen => '80',
    },
    # Trick to help _replace_vars
    '$' => '$',
};

sub USAGE {
    return <<'EOF';
usage: b-http-conf [options] command [args...]
commands:
    do_ping [list.txt] -- pings apps in list
    generate app-name [root-prefix] -- writes config for app-name
    validate_vars vars -- validates configuration
EOF
}

sub do_ping {
    my($self, $list) = @_;
    $self->get_request;
    my($uris);
    return $self->new_other('HTTPPing')->page(
	map("http://$_/pub/ping",
	    @{$_F->map_lines(
		$list || $_VARS->{uris_txt},
		sub {shift =~ /^([^\s#]+)/},
	    )},
	),
    );
}

sub generate {
    my($vars) = shift->validate_vars(@_);
    umask(027);
    foreach my $v (
	map(_app_vars($vars->{$_}, $vars->{httpd}), @{$vars->{apps}})
    ) {
	_write(_httpd_conf($v));
	_write(_app_bconf($v));
	_write(_app_init_rc($v));
	_write(_logrotate($v));
    }
    _httpd_vars($vars);
    _write($vars->{httpd_init_rc}, $_INIT_RC);
    _write(_httpd_conf($vars->{httpd}));
    _write(_logrotate($vars->{httpd}));
    foreach my $x (qw(app_names mail_hosts uris)) {
	_write(_conf_txt($x, $vars->{httpd}));
    }
    return;
}

sub validate_vars {
    my($self, $vars) = @_;
    $vars ||= ${$self->read_input};
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
    return $vars;
}

sub _app_bconf {
    my($vars) = @_;
    return _replace_vars_for_file($vars, bconf => <<'EOF');
use $root_prefix::BConf;
$root_prefix::BConf->merge_dir({
    'Bivio::Agent::Request' => {
        can_secure => $can_secure,
    },
    'Bivio::IO::Config' => {
        is_production => $is_production,
    },
    'Bivio::Delegate::Cookie' => {
        tag => '$cookie_tag',$cookie_domain_cfg
    },
    'Bivio::UI::Facade' => {
        local_file_root => '/var/www/facades',
        want_local_file_cache => 1,
        # Only used on test systems
        http_host => '$http_host',
        mail_host => '$mail_host',
    },
    'Bivio::Util::HTTPLog' => {
        error_file => '$log_directory/error_log',
    },
});
EOF
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

sub _app_vars {
    my($vars, $httpd_vars) = @_;
    # Augments vars for a single app ($vars->{$app}) to include _app_vars.  Returns
    # a $vars with updated config.
    $vars = _file_name_vars($vars);
    my($app) = $vars->{app};
    $vars->{content} = <<"EOF";
PerlWarn on
v1:PerlFreshRestart off
v2:PerlModule Apache2::compat
PerlSetEnv BCONF $vars->{bconf}
# Override the translation handler to avoid local file permission checks
PerlModule Bivio::Ext::ApacheConstants
PerlModule Bivio::Agent::HTTP::Dispatcher

<Location />
    SetHandler perl-script
v1:    PerlHandler Bivio::Agent::HTTP::Dispatcher
v2:    PerlResponseHandler Bivio::Agent::HTTP::Dispatcher
</Location>
EOF
    Bivio::Die->die(
	$app, ': virtual_hosts and mail_host/http_host incompatible'
    ) if $vars->{virtual_hosts} && ($vars->{mail_host} || $vars->{http_host});
#TODO: Deprecate non-virtual_hosts config
    $vars->{virtual_hosts} ||= [
	$vars->{http_host} =~ /^(?:www\.)?\Q$vars->{mail_host}\E$/
	    ? ('@' . $vars->{http_host} => $app)
	    : (
		$vars->{http_host} => $app,
		'@' . $vars->{mail_host} => $app,
	    ),
    ];
    $vars->{cookie_domain_cfg} = !$vars->{cookie_domain} ? ''
	: "\n        domain => '$vars->{cookie_domain}',";
    b_die($app, ': virtual_hosts must be an array_ref of pairs')
	unless ref($vars->{virtual_hosts}) eq 'ARRAY'
        && @{$vars->{virtual_hosts}} % 2 == 0;
    $vars->{httpd_redirects} = '';
    $vars->{can_secure} = 0;
    $httpd_vars->{ssl_global} ||= {};
    __PACKAGE__->map_by_two(
	sub {
	    my($left, $right) = @_;
	    my($is_mail) = $left =~ s/^\@//;
	    my($mh) = $left =~ /^www\.(.+)$/;
	    my($cfg) = ref($right) eq 'HASH' ? $right : {facade_uri => $right};
	    $cfg->{http_host} ||= $left;
	    $cfg->{mail_host} ||= $mh || $cfg->{http_host};
	    $cfg->{www_stripped_host} = $mh;
	    __PACKAGE__->map_by_two(
		sub {
		    my($k, $v) = @_;
		    $cfg->{$k} = $v
			unless defined($cfg->{$k});
	        },
		($cfg->{facade_uri} || '') eq 'dav' ? [
		    local_file_prefix => $app,
		    rewrite_icons => 0,
		] : [
		    local_file_prefix => $cfg->{facade_uri},
		    rewrite_icons => 1,
		],
	    );
	    $cfg = {%$vars, %$cfg};
	    map($vars->{$_} ||= $cfg->{$_}, qw(http_host mail_host));
	    _push($httpd_vars, uris => $cfg->{http_host});
	    $cfg->{back_http} = "http://$cfg->{http_host}:$vars->{listen}\$1";
	    if ($is_mail) {
		foreach my $h (
		    $cfg->{mail_host}, @{$cfg->{mail_aliases} || []}
		) {
		    _push($vars, mail_hosts => $h);
		    _push($vars, mail_receive => "$h $cfg->{back_http}");
		}
	    }
	    _app_vars_vhost($vars, $cfg);
	    $vars->{httpd_content} .= _app_vars_ssl($vars, $cfg, $httpd_vars);
	    _app_vars_redirects($vars, $cfg);
	    return;
	},
	$vars->{virtual_hosts},
    );
    $vars->{httpd_content} .= $vars->{httpd_redirects};
    return $vars;
}

sub _app_vars_document_root {
    my($vars, $cfg) = @_;
    return ''
	unless $cfg->{local_file_prefix};
    return <<"EOF";
    DocumentRoot /var/www/facades/$cfg->{local_file_prefix}/plain
EOF
}

sub _app_vars_legacy {
    my($vars, $cfg) = @_;
    return ''
	unless my $res = $cfg->{legacy_rewrite_rules};
    _app_vars_rewrite_engine($vars, $cfg);
    $res =~ s{(?<=[^\n])$}{\n}s;
    return $res;
}

sub _app_vars_proxy {
    my($vars, $cfg) = @_;
    return ''
	if $cfg->{no_proxy};
    return <<"EOF"
    ProxyVia on
    ProxyIOBufferSize 4194304
    RewriteRule ^(.*) $cfg->{back_http} [proxy]
EOF
}

sub _app_vars_redirects {
    my($vars, $cfg) = @_;
    my($seen) = $cfg->{ssl_only} ? {} : {$cfg->{http_host} => 1};
    my($front_http) = ($cfg->{ssl_only} ? 'https' : 'http') . "://$cfg->{http_host}";
    foreach my $h (
	$cfg->{www_stripped_host},
	$vars->{ssl_only} && $cfg->{http_host},
	map(
	    ($_, $_ =~ /^www\.(.+)$/),
	    sort(@{$cfg->{aliases} || []}),
	),
    ) {
	next
	    if !$h || $seen->{$h}++;
	$vars->{httpd_redirects} .= <<"EOF";
<VirtualHost *>
    ServerName $h
    RedirectPermanent / $front_http/
</VirtualHost>
EOF
    }
    return;
}

sub _app_vars_rewrite {
    my($vars, $cfg) = @_;
    return ''
	if $cfg->{no_proxy} || !$cfg->{rewrite_icons};
    _app_vars_rewrite_engine($vars, $cfg);
    return <<'EOF';
    RewriteRule ^/_.* - [forbidden]
    RewriteRule ^/./ - [L]
    RewriteRule .*favicon.ico$ /i/favicon.ico [L]
EOF
    return;
}

sub _app_vars_rewrite_engine {
    my($vars, $cfg) = @_;
    $cfg->{rewrite_engine} ||= <<"EOF";
    RewriteEngine On
    RewriteOptions inherit
EOF
    return;
}

sub _app_vars_ssl {
    my($vars, $cfg, $httpd_vars) = @_;
    my($hc) = $cfg->{vhost};
    return $hc
	if $cfg->{no_proxy}
	|| !_app_vars_ssl_crt($vars, $cfg, $httpd_vars);
    _app_vars_ssl_addr_port($cfg);
#output for app.conf
    $vars->{ssl_listen} ||= "\nListen " . ($cfg->{listen} + 1);
    $hc =~ s{\*\>}{$cfg->{ssl_addr_port}>};
    ($cfg->{back_https} = $cfg->{back_http}) =~ s{(?<=\:)(\d+)}{$1 + 1}e;
    $hc =~ s{\Q$cfg->{back_http}\E}{$cfg->{back_https}}g;
    $hc =~ s{(?=^\s+Rewrite)}{_app_vars_ssl_directives($cfg)}mex;
    _app_vars_ssl_global($cfg, $httpd_vars);
    return ($cfg->{ssl_only} ? '' : $cfg->{vhost}) . $hc;
}

sub _app_vars_ssl_addr_port {
    my($cfg) = @_;
    my($addr) = Type_IPAddress()->from_domain($cfg->{http_host});
    $cfg->{ssl_addr_port} = "$addr:443";
    b_die($addr, ': no reverse dns entry')
	unless $cfg->{ssl_default_host} = Type_IPAddress()->unsafe_to_domain($addr);
    b_die($cfg->{http_host}, ': http_host may not be reverse dns (PTR) entry')
	if $cfg->{ssl_multi_crt}
	&& Type_DomainName()->is_equal($cfg->{ssl_default_host}, $cfg->{http_host});
    return;
}

sub _app_vars_ssl_crt {
    my($vars, $cfg) = @_;
#TODO: Remove once system.*spec packages updated for ssl_mdc
    if ($cfg->{ssl_mdc} && $cfg->{ssl_mdc} eq '1') {
	delete($cfg->{ssl_mdc});
	$cfg->{ssl_multi_crt} = $cfg->{ssl_crt}
	    if $cfg->{ssl_crt} && !$cfg->{ssl_multi_crt};
    }
    # Subtle: ssl_crt only really should apply to a single virtual host
    # so you want to allow people to clear it for a virtual host if the
    # ssl_multi_crt is set globally
    $cfg->{ssl_crt} = $cfg->{ssl_multi_crt}
	unless defined($cfg->{ssl_crt});
    return $cfg->{ssl_only} = 0
	unless $cfg->{ssl_crt} ||= $cfg->{ssl_multi_crt};
    $cfg->{ssl_multi_crt} = undef
	unless Type_String()->is_equal($cfg->{ssl_crt}, $cfg->{ssl_multi_crt});
    $vars->{can_secure} = 1;
    foreach my $x (qw(ssl_crt ssl_chain)) {
	$cfg->{$x} .= '.crt'
	    if $cfg->{$x} && $cfg->{$x} !~ /\.crt$/;
    }
    ($cfg->{ssl_key} = $cfg->{ssl_crt}) =~ s/crt$/key/;
    return 1;
}

sub _app_vars_ssl_global {
    my($cfg, $httpd_vars, $hc) = @_;
    $httpd_vars->{ssl_global}->{''} = <<'EOF';
Listen 443
SSLSessionCache shm:logs/ssl_scache(512000)
SSLSessionCacheTimeout 300
v1:SSLMutex file:logs/ssl_mutex
v2:SSLMutex sem
v2:SSLProtocol All -SSLv2
v2:SSLHonorCipherOrder On
v2:SSLCipherSuite DHE-RSA-AES256-SHA:AES256-SHA:DHE-RSA-AES128-SHA:EDH-RSA-DES-CBC3-SHA:RC4-SHA:HIGH:!ADH
v1:SSLLog logs/error_log
v1:SSLLogLevel warn
EOF
# need to dig -x to get reverse dns
# forward dns
    return
	unless $cfg->{ssl_multi_crt};
    my($vh) = <<"EOF";
NameVirtualHost $cfg->{ssl_addr_port}
<VirtualHost $cfg->{ssl_addr_port}>
    ServerName $cfg->{ssl_default_host}
    DocumentRoot /var/www/html
@{[_app_vars_ssl_directives($cfg)]}</VirtualHost>
EOF
    my($vh2) = $httpd_vars->{ssl_global}->{$cfg->{ssl_addr_port}} ||= $vh;
    b_die($cfg->{ssl_addr_port}, ': ssl config must be identical for vhosts')
	unless $vh2 eq $vh;
    return;
}

sub _app_vars_ssl_directives {
    my($cfg) = @_;
    my($chain) = $cfg->{ssl_chain} ? <<"EOF" : '';
    SSLCertificateChainFile /etc/httpd/conf/ssl.crt/$cfg->{ssl_chain}
EOF
    return <<"EOF";
    SSLEngine on
    SSLCertificateFile /etc/httpd/conf/ssl.crt/$cfg->{ssl_crt}
    SSLCertificateKeyFile /etc/httpd/conf/ssl.key/$cfg->{ssl_key}
$chain    SetEnv nokeepalive 1
    SetEnvIf User-Agent ".*MSIE.*" nokeepalive ssl-unclean-shutdown
    <Location />
	SSLRequireSSL
	SSLOptions +StrictRequire
    </Location>
EOF
}

sub _app_vars_vhost {
    my($vars, $cfg) = @_;
    $cfg->{document_root} = _app_vars_document_root($vars, $cfg);
    $cfg->{rewrite_engine} = '';
    $cfg->{vhost_rules} = _app_vars_legacy($vars, $cfg)
	. _app_vars_rewrite($vars, $cfg)
	. _app_vars_proxy($vars, $cfg);
    $cfg->{vhost} = <<"EOF";
<VirtualHost *>
    ServerName $cfg->{http_host}
$cfg->{document_root}$cfg->{rewrite_engine}$cfg->{vhost_rules}</VirtualHost>
EOF
    return;
}

sub _conf_txt {
    my($which, $vars) = @_;
    return (
	$vars->{$which . '_txt'},
	\(join("\n", sort(@{$vars->{$which}}), '')),
    );
}

sub _file_name_vars {
    my($vars) = @_;
    my($app) = $vars->{app};
    %$vars = (
	%$vars,
	bconf => "/etc/$app.bconf",
	document_root => "/var/www/facades/$app/plain",
	httpd_conf => "/etc/httpd/conf/$app.conf",
	init_rc => "/etc/rc.d/init.d/$app",
	lock_file => "/var/lock/subsys/$app",
	log_directory => "/var/log/$app",
	logrotate => "/etc/logrotate.d/$app",
	pid_file => "/var/run/$app.pid",
	process_name => "$app-httpd",
    );
    return $vars;
}

sub _httpd_conf {
    my($vars) = @_;
    return _replace_vars_for_file($vars, 'httpd_conf', <<'EOF');
v1:ResourceConfig /dev/null
v1:AccessConfig /dev/null
v2:
v2:# The order of this list matters a bit
v2:#? LoadModule actions_module modules/mod_actions.so
v2:LoadModule alias_module modules/mod_alias.so
v2:LoadModule auth_basic_module modules/mod_auth_basic.so
v2:#? LoadModule auth_digest_module modules/mod_auth_digest.so
v2:#? LoadModule authn_alias_module modules/mod_authn_alias.so
v2:#? LoadModule authn_anon_module modules/mod_authn_anon.so
v2:#? LoadModule authn_dbm_module modules/mod_authn_dbm.so
v2:LoadModule authn_default_module modules/mod_authn_default.so
v2:LoadModule authn_file_module modules/mod_authn_file.so
v2:#? LoadModule authnz_ldap_module modules/mod_authnz_ldap.so
v2:#? LoadModule authz_dbm_module modules/mod_authz_dbm.so
v2:LoadModule authz_default_module modules/mod_authz_default.so
v2:#? LoadModule authz_groupfile_module modules/mod_authz_groupfile.so
v2:LoadModule authz_host_module modules/mod_authz_host.so
v2:#? LoadModule authz_owner_module modules/mod_authz_owner.so
v2:LoadModule authz_user_module modules/mod_authz_user.so
v2:LoadModule autoindex_module modules/mod_autoindex.so
v2:#? LoadModule cache_module modules/mod_cache.so
v2:LoadModule cgi_module modules/mod_cgi.so
v2:#? LoadModule dav_module modules/mod_dav.so
v2:#? LoadModule dav_fs_module modules/mod_dav_fs.so
v2:LoadModule deflate_module modules/mod_deflate.so
v2:LoadModule dir_module modules/mod_dir.so
v2:#? LoadModule disk_cache_module modules/mod_disk_cache.so
v2:LoadModule env_module modules/mod_env.so
v2:#? LoadModule expires_module modules/mod_expires.so
v2:#? LoadModule ext_filter_module modules/mod_ext_filter.so
v2:#? LoadModule file_cache_module modules/mod_file_cache.so
v2:#? LoadModule headers_module modules/mod_headers.so
v2:#? LoadModule include_module modules/mod_include.so
v2:LoadModule info_module modules/mod_info.so
v2:#? LoadModule ldap_module modules/mod_ldap.so
v2:LoadModule log_config_module modules/mod_log_config.so
v2:#? LoadModule logio_module modules/mod_logio.so
v2:#? LoadModule mem_cache_module modules/mod_mem_cache.so
v2:#? LoadModule mime_magic_module modules/mod_mime_magic.so
v2:LoadModule mime_module modules/mod_mime.so
v2:#? LoadModule negotiation_module modules/mod_negotiation.so
v2:LoadModule perl_module modules/mod_perl.so
v2:LoadModule proxy_module modules/mod_proxy.so
v2:#? LoadModule proxy_balancer_module modules/mod_proxy_balancer.so
v2:#? LoadModule proxy_connect_module modules/mod_proxy_connect.so
v2:#? LoadModule proxy_ftp_module modules/mod_proxy_ftp.so
v2:LoadModule proxy_http_module modules/mod_proxy_http.so
v2:LoadModule rewrite_module modules/mod_rewrite.so
v2:LoadModule setenvif_module modules/mod_setenvif.so
v2:#? LoadModule speling_module modules/mod_speling.so
v2:LoadModule ssl_module modules/mod_ssl.so
v2:LoadModule status_module modules/mod_status.so
v2:#? LoadModule suexec_module modules/mod_suexec.so
v2:#? LoadModule userdir_module modules/mod_userdir.so
v2:#? LoadModule usertrack_module modules/mod_usertrack.so
v2:#? LoadModule version_module modules/mod_version.so
v2:LoadModule vhost_alias_module modules/mod_vhost_alias.so
v2:LoadModule reqtimeout_module modules/mod_reqtimeout.so


Listen $listen$ssl_listen

User apache
Group apache
ServerAdmin $server_admin
ServerTokens ProductOnly

Timeout $timeout
KeepAlive On
MaxKeepAliveRequests 10
KeepAliveTimeout 2
MinSpareServers 1
MaxSpareServers $servers
StartServers $servers
MaxClients $servers
MaxRequestsPerChild 120
LimitRequestBody $limit_request_body
$global_params

ServerRoot /etc/httpd
PidFile $pid_file
v1:LockFile $lock_file
v1:ScoreBoardFile $log_directory/apache_runtime_status
TypesConfig /etc/mime.types
DefaultType text/plain
UseCanonicalName Off
LogFormat "%V %h %P %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
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
$log_directory/access_log $log_directory/error_log {
    missingok
    sharedscripts
    postrotate
        /bin/kill -HUP `cat $pid_file 2>/dev/null` 2> /dev/null || true
    endscript
    compress
}
EOF
}

sub _mkdir {
    my($name) = @_;
    $name =~ s,^/,,;
    return $_F->mkdir_p($name);
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
    $v = _file_name_vars($v);
    $v->{content} = join(
	"\n",
	_replace_vars($v, "httpd_content", <<'EOF'),
NameVirtualHost *
<VirtualHost *>
    ServerName $host_name
    DocumentRoot /var/www/html
</VirtualHost>
EOF
	map(
	    $v->{ssl_global}->{$_},
	    sort(keys(%{$v->{ssl_global}})),
	),
	map($vars->{$_}->{httpd_content}, @{$vars->{apps}}),
	join('',
	    <<'EOF',
<VirtualHost *>
    ServerName localhost.localdomain
    DocumentRoot /var/www/html
    RewriteEngine On
    RewriteOptions inherit
    ProxyVia on
    ProxyIOBufferSize 4194304
EOF
	     map({
		 my($mh, $vh) = split(' ', $_);
		 "    RewriteRule ^(.*_mail_receive/.*\@$mh.*) $vh \[proxy,nocase\]\n";
	     } sort(map(
		 @{$vars->{$_}->{mail_receive} || []}, @{$vars->{apps}},
	     ))),
	     <<'EOF',
    RewriteRule .* - [forbidden]
</VirtualHost>
EOF
        ),
    );
    $v->{mail_hosts} = [sort(
	map(@{$vars->{$_}->{mail_hosts} || []}, @{$vars->{apps}}))];
    $v->{app_names} = [@{$vars->{apps}}];
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

sub _push {
    my($vars, $name, $value) = @_;
    push(@{$vars->{$name} ||= []}, $value);
    return;
}

sub _replace_vars {
    my($vars, $name, $template) = @_;
    # One of the $_VARS is '$'
    $template =~ s{\$(\w+|\$)}{
	defined($vars->{$1}) ? $vars->{$1}
	    : Bivio::Die->die("$1: in template ($name), but not in ", $vars)
    }xseg;
    $template =~ s/$_STRIP_VERSION//mg;
    return $template;
}

sub _replace_vars_for_file {
    my($vars, $name) = @_;
    return ($vars->{$name}, \(_replace_vars(@_)));
}

sub _write {
    my($name, $data) = @_;
    $name =~ s{^/}{};
    $_F->mkdir_parent_only($name);
    my($generator) = ('$Header$' =~ m{Header:\s*(.+?)\s*\$}i)[0]
	|| __PACKAGE__;
    $$data =~ s{^(#!.+?\n|)}{$1 . <<"EOF"}es;
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: $generator
################################################################
EOF
    return $_F->write($name, $$data);
}

$_INIT_RC_V1 = <<'EOF';
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
	sleep 3
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
EOF

$_INIT_RC_V2 = <<'EOF';
#!/bin/bash
#
# httpd        Startup script for the Apache HTTP Server
#
# chkconfig: 345 85 15
# description: Apache is a World Wide Web server.  It is used to serve \
#	       HTML files and CGI.
# processname: httpd
# config: /etc/httpd/conf/httpd.conf
# config: /etc/sysconfig/httpd
# pidfile: /var/run/httpd.pid

. /etc/rc.d/init.d/functions

if [ -f /etc/sysconfig/httpd ]; then
        . /etc/sysconfig/httpd
fi

HTTPD_LANG=${HTTPD_LANG-"C"}
INITLOG_ARGS=""
httpd=${HTTPD-/usr/sbin/httpd}
prog=$(basename ${b_httpd_app-$httpd})
pidfile=${PIDFILE-/var/run/$prog.pid}
conffile=${CONFFILE-/etc/httpd/conf/$prog.conf}
lockfile=${LOCKFILE-/var/lock/subsys/$prog}
RETVAL=0
STOP_TIMEOUT=${STOP_TIMEOUT-10}

start() {
        echo -n $"Starting $prog: "
        LANG=$HTTPD_LANG daemon --pidfile=${pidfile} $httpd -f $conffile $OPTIONS
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && touch ${lockfile}
        return $RETVAL
}
stop() {
	echo -n $"Stopping $prog: "
	killproc -p ${pidfile} -d ${STOP_TIMEOUT} $prog
	RETVAL=$?
	echo
	[ $RETVAL = 0 ] && rm -f ${lockfile} ${pidfile}
}
reload() {
    echo -n $"Reloading $prog: "
    if ! LANG=$HTTPD_LANG $httpd -f $conffile $OPTIONS -t >&/dev/null; then
        RETVAL=$?
        echo $"not reloading due to configuration syntax error"
        failure $"not reloading $prog due to configuration syntax error"
    else
        killproc -p ${pidfile} $prog -HUP
        RETVAL=$?
    fi
    echo
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
        status -p ${pidfile} $httpd
	RETVAL=$?
	;;
  restart)
	stop
        sleep 3
	start
	;;
  condrestart)
	if [ -f ${pidfile} ] ; then
		stop
		start
	fi
	;;
  reload)
        reload
	;;
  *)
	echo $"Usage: $prog {start|stop|restart|condrestart|reload|status}"
	exit 1
esac

exit $RETVAL
EOF

1;
