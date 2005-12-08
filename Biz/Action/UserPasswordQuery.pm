# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::UserPasswordQuery;
use strict;
use base ('Bivio::Biz::Action');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_KEY) = 'x';

sub execute {
    my($proto, $req) = @_;
    my($pw) = delete(($req->get('query') || {})->{$_KEY});
    my($u) = $req->get_nested(qw(auth_realm owner));
    my($die) = Bivio::Die->catch(sub {
	Bivio::Die->throw_quietly('invalid password in query')
	    unless $u->get_field_type('password')->is_equal(
	    $u->get('password'), $pw);
	Bivio::Biz::Model->get_instance('UserLoginForm')->execute($req, {
	    realm_owner => $u,
            # there might not be a cookie if user is visiting site
            # from the reset-password URI
            disable_assert_cookie => 1,
	});
    });

    if ($die) {
        $die->throw
            if $die->get('code')->eq_missing_cookies;
	$proto->get_instance('Acknowledgement')->save_label(
	    password_nak => $req);
	Bivio::Die->throw(NOT_FOUND => {
	    entity => $pw,
	    realm => $u,
	});
	# DOES NOT RETURN
    }
    $proto->new({password => $pw})->put_on_request($req, 1);
    $proto->get_instance('Acknowledgement')->save_label($req);
    $req->server_redirect({
        task_id => $req->get('task')->get('password_task'),
        no_context => 1,
    });
    # DOES NOT RETURN
}

sub format_uri {
    my(undef, $req) = @_;
    my($pw) = sprintf('%08d', int(rand(100_000_000)) + 1);
    $req->get_nested(qw(auth_realm owner))->update_password($pw);
    return $req->format_http({
	task_id => $req->get_nested(qw(task reset_task)),
	# sprintf ensures is at least six chars
	query => {$_KEY => $pw},
	no_context => 1,
    });
}

1;
