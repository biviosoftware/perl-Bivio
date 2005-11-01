# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::IO::File;
my($tmp) = "$ENV{PWD}/HTTPConf.tmp/";
CORE::system("rm -rf $tmp; mkdir $tmp");
Bivio::IO::File->chdir($tmp);
Bivio::Test->new('Bivio::Util::HTTPConf')->unit([
    'Bivio::Util::HTTPConf' => [
	generate => [
	    <<'EOF',
{
    httpd => {
        host_name => 'proxy.com',
    },
    a1 => {
        cookie_tag => 'A1T',
        http_suffix => 'www.a1.com',
        listen => 2121,
        mail_host => 'a2.com',
        root_prefix => 'A1',
        server_admin => 'a1@a1.com',
    },
    a2 => {
        is_production => 1,
        cookie_tag => 'A2T',
        root_prefix => 'A2',
        listen => 1010,
        legacy_rewrite_rules => 
             'RewriteRule ^(/[^/]+\.html)$ /hm$1 [R=permanent,L]',
        mail_host => 'a2.com',
        http_suffix => 'a2.com',
        servers => 333,
        limit_request_body => 1_000_000_000,
    },
    server_admin => 'default@default.com',
    limit_request_body => 9999,
};
EOF
            sub {
		my($vars) = Bivio::Die->eval_or_die(shift->get('params')->[0]);
		my($h) = $vars->{httpd};
		$h->{listen} = 80;
		# Doubles on the last round so matches 2 * sum(servers)
		$h->{servers} = 0;
		$h->{limit_request_body} = 0;
		foreach my $app (grep(/^a\d+$/, sort(keys(%$vars))), 'httpd') {
		    $h->{servers} += ($vars->{$app}->{servers} ||= 4);
		    $h->{limit_request_body} = $vars->{$app}->{limit_request_body}
			if $h->{limit_request_body} < ($vars->{$app}->{limit_request_body} || 0);
		    foreach my $x (
			["etc/httpd/conf/$app.conf", qw(listen server_admin servers limit_request_body)],
			["etc/$app.bconf", qw(cookie_tag http_suffix mail_host)],
			["etc/rc.d/init.d/$app"],
			["etc/logrotate.d/$app"],
		    ) {
			my($file) = shift(@$x);
			next if $file eq 'etc/httpd.bconf';
			my($c) = Bivio::IO::File->read($file);
			foreach my $k (@$x) {
			    my($n) = ($k =~ /([a-z]+)$/)[0];
			    # 4 is default servers, only default being tested
			    my($v) = $vars->{$app}->{$k} || $vars->{$k};
			    die("$n $v: not found in $file")
				unless $$c =~ /${n}[^\n]+$v/is;
			}
		    }
		}
		return 1;
	    },
	],
    ],
]);
