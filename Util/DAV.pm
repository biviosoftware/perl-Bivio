# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::DAV;
use strict;
use base 'Bivio::ShellUtil';
use Bivio::Ext::LWPUserAgent;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-realm-file [options] command [args...]
commands:
    propfind uri user [user [password]] -- returns output of dav request
EOF
}

sub propfind {
    my($self, $uri, $user, $password) = @_;
    $password ||= 'password';
    my($ua) = Bivio::Ext::LWPUserAgent->new;
    $ua->agent('b-dav');
    my($resp) = $ua->request(
	HTTP::Request->new(
	PROPFIND => $uri => [
	    Depth => 0,
	    Translate => 'f',
	    $user ? (Authorization => "Basic " . MIME::Base64::encode("$user:$password"))
		: (),
	],
    ));
    return $resp->as_string;
}

1;
