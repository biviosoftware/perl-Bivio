#!perl
#
# $Id$
#
use Cwd ();
@ARGV || die('usage: perl run_httpd.pl <port>');
$ENV{PERLLIB} = '.';
open(OUT, ">run_httpd.conf") || die;
my($user) = getpwuid($>) || $>;
my($group) = getgrgid($)) || $);
my($pwd) = &Cwd::cwd();
my($port) = shift;
while (<DATA>) {
    s/\bUSER\b/$user/g;
    s/\bGROUP\b/$group/g;
    s/\bPWD\b/$pwd/g;
    s/\bPORT\b/$port/g;
}
continue {
    print OUT;
}
close(OUT);
sub symlink ($$) {
    my($file, $link) = @_;
    -e $link || symlink($file, $link) || die("symlink($file, $link): $!");
}
-e 'html' || mkdir('html', 0755) || die("mkdir(html): $!");
&symlink('../../../html/i', 'html/i');
&symlink('../../data', 'data');
&symlink('.', 'Bivio');
&symlink('.', 'logs');
&symlink('/usr/local/apache/libexec', 'libexec');
#-e 'data/clubs/cosmic/messages/maillist.html'
#    || system('mhonarc -rc ../../etc/majordomo/club.mrc -outdir data/clubs/cosmic/messages/ /usr/local/mail/archive/cosmic.1999??');
system('rm -f httpd.lock.* httpd.pid');
exec('/usr/local/apache/bin/httpd', '-X', '-f', "$pwd/run_httpd.conf");
__DATA__
#
# $Id$
#
# Test configuration for Bivio::Club
#
# To run:
#    env PERLLIB=. /usr/local/apache/bin/httpd -X -f $PWD/httpd.conf
#
ResourceConfig /dev/null
AccessConfig /dev/null

#
# Configure modules minimally
#
LoadModule access_module      libexec/mod_access.so
LoadModule config_log_module  libexec/mod_log_config.so
LoadModule agent_log_module   libexec/mod_log_agent.so
LoadModule referer_log_module libexec/mod_log_referer.so
LoadModule mime_module        libexec/mod_mime.so
LoadModule dir_module         libexec/mod_dir.so
LoadModule setenvif_module    libexec/mod_setenvif.so

ClearModuleList
AddModule mod_access.c
AddModule mod_log_config.c
AddModule mod_log_agent.c
AddModule mod_log_referer.c
AddModule mod_mime.c
AddModule mod_dir.c
AddModule mod_so.c
AddModule mod_setenvif.c
AddModule mod_perl.c

#
# Server
#
ServerName bivio.com
ServerType standalone
Port PORT
User USER
Group GROUP
ServerAdmin USER@bivio.com
UseCanonicalName on
# Single server has strange behaviour
KeepAlive off

#
# Perl
#
PerlWarn on
# Can't be on and use PERLLIB.
#PerlTaintCaheck on
PerlFreshRestart on
#PerlSetEnv BIVIO_REQUEST_DEBUG 1
PerlModule Bivio::Agent::Dispatcher

#
# Files
#
# logs is linked to /var/log/httpd.  conf is linked to /etc.
ServerRoot PWD
DocumentRoot PWD/html
PidFile httpd.pid
ErrorLog |cat
# Possible values include: debug, info, notice, warn, error, crit,
# alert, emerg.
LogLevel debug
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
CustomLog |cat combined
TypesConfig /etc/mime.types
DefaultType text/html
LockFile httpd.lock

<Directory />
Order deny,allow
Deny from all
</Directory>

<Directory PWD/html>
AllowOverride None
# Always FollowSymLinks for performance
Options FollowSymLinks
Allow from all
</Directory>


<Location /naic>
SetHandler perl-script
PerlHandler Bivio::NAICRegister
</Location>

#
# Browsers
#
BrowserMatch "Mozilla/2" nokeepalive
BrowserMatch "MSIE 4\.0b2;" nokeepalive downgrade-1.0 force-response-1.0
BrowserMatch "RealPlayer 4\.0" force-response-1.0
BrowserMatch "Java/1\.0" force-response-1.0
BrowserMatch "JDK/1\.0" force-response-1.0
