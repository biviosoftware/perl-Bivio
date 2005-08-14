# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
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
    },
    server_admin => 'default@default.com',
};
EOF
            sub {
		my($vars) = Bivio::Die->eval_or_die(shift->get('params')->[0]);
		foreach my $app (grep(/^a\d+$/, sort(keys(%$vars)))) {
		    foreach my $x (
			["etc/httpd/conf/$app.conf", qw(listen server_admin servers)],
			["etc/$app.bconf", qw(cookie_tag http_suffix mail_host)],
		    ) {
			my($file) = shift(@$x);
			my($c) = Bivio::IO::File->read($file);
			foreach my $k (@$x) {
			    my($n) = ($k =~ /([a-z]+)$/)[0];
			    # 4 is default servers, only default being tested
			    my($v) = $vars->{$app}->{$k} || $vars->{$k} || 4;
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
