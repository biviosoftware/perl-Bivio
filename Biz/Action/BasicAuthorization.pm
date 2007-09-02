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
    return 0
	if $req->unsafe_get('auth_user');
    my($auth) = $req->get('r')->header_in('Authorization');
    my($f) = Bivio::Biz::Model->new($req, 'UserLoginForm');
    $f->disable_assert_cookie;
    if ($auth) {
	my($u, $p)
	    = (MIME::Base64::decode(($auth =~ /Basic\s*(\S+)/)[0] || '') || '')
		=~ /^([^:]+):(.*)$/;
	if ($u) {
	    my($su);
	    my($ro);
	    if ($u =~ s/^(.*)\>//) {
		my($su) = $1;
		$f->validate($su, $p);
		unless ($f->in_error) {
		    $f->execute_ok;
		    if ($req->is_super_user) {
			$f->validate_login($u);
			$f->substitute_user($ro = $f->get('realm_owner'), $req)
			    unless $f->in_error;
		    }
		    else {
			Bivio::IO::Alert->warn(
			    $su, ': attempted to substitute user to: ', $u);
		    }
		}
	    }
	    else {
		$f->validate($u, $p);
		unless ($f->in_error) {
		    $f->execute_ok;
		    $ro = $f->unsafe_get('realm_owner');
		}
	    }
	    return 0
		if $ro;
	    Bivio::IO::Alert->warn($f->get_errors)
	        if $f->in_error;
	}
	else {
	    Bivio::IO::Alert->warn($auth, ': could not parse user');
	}
    }
    $req->get('reply')->set_header(
	'WWW-Authenticate',
	qq{Basic realm="@{[$f->get_basic_authorization_realm]}"},
    )->set_http_status(Bivio::Ext::ApacheConstants->HTTP_UNAUTHORIZED)
	->set_output_type('text/plain')
        ->set_output(\(''));
    return 1;
}

1;
