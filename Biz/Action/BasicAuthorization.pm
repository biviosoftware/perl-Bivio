# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::BasicAuthorization;
use strict;
use Bivio::Base 'Biz.Action';
use MIME::Base64 ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AC) = b_use('Ext.ApacheConstants');
b_use('Agent.Task')->register(__PACKAGE__);

sub execute {
    my($proto, $req) = @_;
    Bivio::IO::Alert->warn_deprecated(
	$req->get('task'), ': remove Action.BasicAuthorization and set want_basic_authorization=1 on task');
    return $proto->handle_pre_auth_task(undef, $req);
}

sub handle_pre_auth_task {
    my($self, $task, $req) = @_;
    return 0
	if $req->unsafe_get('auth_user');
    my($f) = Bivio::Biz::Model->new($req, 'UserLoginForm');
    my($r) = $req->unsafe_get('r');
    my($auth) = $r && $r->header_in('Authorization');
    return _unauth($task, $f)
	unless $auth;
    $f->disable_assert_cookie;
    my($u, $p)
	= (MIME::Base64::decode(($auth =~ /Basic\s*(\S+)/)[0] || '') || '')
	    =~ /^([^:]+):(.*)$/;
    unless ($u) {
	b_warn($u, ': could not parse user');
	return _unauth($task, $f);
    }
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
		b_warn($su, ': attempted to substitute user to: ', $u);
		return _unauth($task, $f);
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
    b_warn($f->get_errors)
        if $f->in_error;
    return _unauth($task, $f);
}

sub _unauth {
    my($task, $login) = @_;
    return 0
	unless !$task || $task->unsafe_get('want_basic_authorization');
    my($req) = $login->req;
    $req->get('reply')->set_header(
	'WWW-Authenticate',
	qq{Basic realm="@{[$login->get_basic_authorization_realm]}"},
    )->set_http_status($_AC->HTTP_UNAUTHORIZED)
	->set_output_type('text/plain')
        ->set_output(\(''));
    return 1;
}

1;
