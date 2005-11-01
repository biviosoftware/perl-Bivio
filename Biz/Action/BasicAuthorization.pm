# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::BasicAuthorization;
use strict;
use base 'Bivio::Biz::Action';
use Bivio::Ext::ApacheConstants;
use MIME::Base64 ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
    my($auth) = $req->get('r')->header_in('Authorization');
    if ($auth) {
	my($u, $p)
	    = (MIME::Base64::decode(($auth =~ /Basic\s*(\S+)/)[0] || '') || '')
		=~ /^([^:]+):(.*)$/;
	if ($u) {
	    my($f) = Bivio::Biz::Model->new($req, 'UserLoginForm');
	    $f->validate($u, $p);
	    unless ($f->in_error) {
		$req->set_user($f->get('realm_owner'));
		$req->get('r')->connection->user(
		    'ba-' . $req->get('auth_user_id'));
		return 0;
	    }
	    else {
		Bivio::IO::Alert->warn($f->get_errors);
	    }
	}
	else {
	    Bivio::IO::Alert->warn($auth, ': could not parse user');
	}
    }
    $req->get('reply')->set_header('WWW-Authenticate', 'Basic realm="*"')
	->set_http_status(Bivio::Ext::ApacheConstants->HTTP_UNAUTHORIZED)
	->set_output_type('text/plain')
        ->set_output(\(''));
    return 1;
}

1;
