# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::RequestId;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Digest::MD5 ();
use Sys::Hostname ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_COUNT) = 0;
my($_BASE);
my($_DT) = b_use('Type.DateTime');

sub current {
    my($proto, $req) = @_;
    return $req->get_if_exists_else_put($proto->package_name => sub {
	return (
	    $_BASE ||= substr(
		Digest::MD5::md5_hex(
		    Sys::Hostname::hostname() . $_DT->now_as_file_name . $$,
		),
		-16,
	    )
	) . sprintf('%08x', ++$_COUNT);
    });
}

sub clear_current {
    my($proto, $req) = @_;
    $req->delete($proto->package_name);
    return;
}

1;
