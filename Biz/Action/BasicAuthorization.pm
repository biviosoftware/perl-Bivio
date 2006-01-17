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
	    my($su);
	    my($ro);
	    if ($u =~ s/^(.*)\>//) {
		$f->validate($1, $p);
		unless ($f->in_error) {
		    $req->put(super_user_id =>
		        $su = $f->get_nested(qw(realm_owner realm_id)));
		    $ro = $f->validate_login($u);
		}
	    }
	    else {
		$f->validate($u, $p);
		$ro = $f->unsafe_get('realm_owner');
	    }
	    if ($ro && !$f->in_error) {
		$req->set_user($ro);
		$req->get('r')->connection->user(
		    ($su ? "sb-$su-" : '')
		    . 'ba-' . $req->get('auth_user_id'));
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
