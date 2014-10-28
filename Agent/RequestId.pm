# Copyright (c) 2008-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::RequestId;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';
use Digest::MD5 ();

my($_COUNT) = 0;
my($_BASE);

sub current {
    my($proto, $req) = @_;
    return $req->get_if_exists_else_put($proto->package_name => sub {
	return (
	    $_BASE ||= Digest::MD5::md5_hex(
		b_use('Bivio.BConf')->bconf_host_name
	            . b_use('Type.DateTime')->now_as_file_name
		    . $$,
	    ),
	) . sprintf('%08x', ++$_COUNT);
    });
}

sub clear_current {
    my($proto, $req) = @_;
    $req->delete($proto->package_name);
    return;
}

1;
