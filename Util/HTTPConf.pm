# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::HTTPConf;
use strict;
$Bivio::Util::HTTPConf::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::HTTPConf::VERSION;

=head1 NAME

Bivio::Util::HTTPConf - start httpd (apache)

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::HTTPConf;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::HTTPConf::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::HTTPConf>

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

See below

=cut

sub USAGE {
    return <<'EOF';
usage: b-http-conf [options] command [args...]
commands:
    gen_app app-name [root-prefix] -- writes config for app-name
EOF
}

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::File;

#=VARIABLES
my($_DATA);
Bivio::IO::Config->register(my $_CFG = {
    ports => {},
    server_status_uri => '/s',
    webmaster_email => Bivio::IO::Config->REQUIRED,
});

=head1 METHODS

=cut

=for html <a name="gen_app"></a>

=head2 gen_app(string app)

=cut

sub gen_app {
    my($self, $app, $cfg) = _app_cfg(@_);
    Bivio::IO::File->mkdir_parent_only($cfg->{httpd_conf});
    return Bivio::IO::File->write(
	$cfg->{httpd_conf},
	_httpd_conf($cfg),
    );
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item ports : hash_ref [{}]

Hash of app to port, e.g.

    ports => {
        petshop => 8080,
    },

=item server_status_uri : string [/s]

Location of Apache server-status

=item webmaster_email : string (required)

Email address of webmaster to be set to ServerAdmin.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    Bivio::Die->die($cfg->{ports}, ': ports must be a hash_ref')
	unless ref($cfg->{ports}) eq 'HASH';
    __PACKAGE__->convert_literal('Email', $cfg->{webmaster_email});
    $_CFG = $cfg;
    return;
}

#=PRIVATE SUBROUTINES

# _app_cfg(self, string app) : hash_ref
#
# Return configuration used to write _httpd_conf
#
sub _app_cfg {
    my($self, $app) = @_;
    return ($self, $app, {
	bconf => "/etc/$app.bconf",
	document_root => "/var/www/facades/$app/plain",
	generator => ('$Header$' =~ /Header:\s*(.+?)\s*\$/i)[0] || __PACKAGE__,
	httpd_conf => "etc/httpd/conf/$app.conf",
	listen => $_CFG->{ports}->{$app}
	    || $self->usage_error($app, ': no port configured'),
	lock_file => "/var/lock/subsys/$app",
	log_directory => "/var/log/$app",
	location_server_status => $_CFG->{server_status_uri},
	mime_types => '/etc/mime.types',
	pid_file => "/var/run/$app.pid",
	process_name => "$app-httpd",
	server_admin => $_CFG->{webmaster_email},
    });
}

# _httpd_conf(hash_ref cfg) : string_ref
#
# Copy __DATA__, and fill in $cfg.
#
sub _httpd_conf {
    my($cfg) = @_;
    unless ($_DATA) {
	local($/);
	$_DATA = <DATA>;
	close(DATA);
    }
    my($d) = $_DATA;
    $d =~ s/\$(\w+)/$cfg->{$1} || die("$1: bad __DATA__")/seg;
    return \$d;
}

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
__DATA__
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: $generator
################################################################
ResourceConfig /dev/null
AccessConfig /dev/null

Listen $listen

User apache
Group apache
ServerAdmin $server_admin
ServerTokens Min

Timeout 120
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 15
MinSpareServers 1
MaxSpareServers 4
StartServers 4
MaxClients 4
MaxRequestsPerChild 100000
LimitRequestBody 4194304

ServerRoot /etc/httpd
PidFile $pid_file
LockFile $lock_file
ScoreBoardFile $log_directory/apache_runtime_status
TypesConfig $mime_types
DefaultType text/plain
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
CustomLog $log_directory/access_log combined
ErrorLog $log_directory/error_log
LogLevel info
ExtendedStatus On

PerlWarn on
PerlFreshRestart off
PerlSetEnv BCONF $bconf
PerlTransHandler Apache::OK
# Override the translation handler to avoid local file permission checks
PerlModule Bivio::Agent::HTTP::Dispatcher

DocumentRoot $document_root
<Directory />
    AllowOverride None
    Options FollowSymLinks
    deny from all
    allow from 127.0.0.1
</Directory>

<Location />
    SetHandler perl-script
    PerlHandler Bivio::Agent::HTTP::Dispatcher
</Location>

<Location $location_server_status>
    SetHandler server-status
    deny from all
    allow from 127.0.0.1
</Location>

BrowserMatch "Mozilla/2" nokeepalive
BrowserMatch "MSIE 4\.0b2;" nokeepalive downgrade-1.0 force-response-1.0
BrowserMatch "RealPlayer 4\.0" force-response-1.0
BrowserMatch "Java/1\.0" force-response-1.0
BrowserMatch "JDK/1\.0" force-response-1.0
