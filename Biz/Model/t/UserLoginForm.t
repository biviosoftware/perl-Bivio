# $Id$
# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
#
# Only works for petshop (needs demo and root) users
#
use strict;
use Bivio::Biz::Model::UserLoginForm;
use Bivio::Test;
use Bivio::Test::Request;
my($_req) = Bivio::Test::Request->initialize_fully->setup_http;
my($_compute_params) = sub {
    my($case, $params) = @_;
    my($realm) = $params->[0] ? Bivio::Biz::Model->new($_req, 'RealmOwner')
	->unauth_load_or_die({name => $params->[0]})
	: undef;
    return $case->get('method') eq 'execute'
	? [$_req, {realm_owner => $realm}]
	: [$realm, $_req];
};
my($_check_return) = sub {
    my($case, undef, $expect) = @_;
    my($cookie) = $_req->get('cookie');
    my($p) = $cookie->unsafe_get(
	Bivio::Biz::Model::UserLoginForm->PASSWORD_FIELD);
    Bivio::Die->die('password=', $p, ' and auth_user=',
	$_req->get('auth_user'), ' disagree')
	    if $p xor $_req->get('auth_user');
    my($u) = $cookie->unsafe_get(
	Bivio::Biz::Model::UserLoginForm->USER_FIELD);
    Bivio::Die->die('cookie_user=', $u, ' and auth_user_id=',
	$_req->get('auth_user_id'), ' disagree')
	    if $p && !Bivio::IO::Ref->nested_equals(
		$u, $_req->get('auth_user_id'));
    Bivio::Die->die('bad is_substitute_user=', $_req->is_substitute_user),
	if $_req->is_substitute_user
	    xor $case->get('method') eq 'substitute_user';
    Bivio::Die->die('bad is_super_user=', $_req->is_super_user)
	if $_req->is_super_user
	    xor ($expect->[0] || '') eq 'root';
    $case->actual_return([$_req->get('auth_user')
	&& $_req->get('auth_user')->get('name')]);
    return $expect;
};
Bivio::Test->new({
    check_return => $_check_return,
})->unit([
    {
	compute_params => $_compute_params,
	object => 'Bivio::Biz::Model::UserLoginForm',
    } => [
	execute => [
	    demo => 'demo',
	    [undef] => [undef],
	    sub {
		# This case simulates the request not being fully initialized
		# when the cookie is set.
		my($case) = @_;
		$_req->put(auth_realm => undef, auth_id => undef);
		return $_compute_params->($case, ['demo']);
	    } => 'demo',
	    root => 'root',
	],
	substitute_user => [
	    demo => 'demo',
	    demo => Bivio::DieCode->DIE,
        ],
	execute => [
	    # Exit from su
	    [undef] => 'root',
	    [undef] => [undef],
	],
	substitute_user => [
	    demo => Bivio::DieCode->DIE,
	],
	execute => [
	    demo => 'demo',
	],
	substitute_user => [
	    demo => Bivio::DieCode->DIE,
	],
    ],
    {
	compute_params => sub {
	    my($case, $params) = @_;
	    return [$_req, @$params];
        },
	object => 'Bivio::Biz::Model::UserLoginForm',
    } => [
	execute => [
	    # Logs out previous test
	    [{login => undef}] => [undef],
	    [{login => 'demo'}] => 'demo',
	    [{login => 'user'}] => Bivio::DieCode->NOT_FOUND,
	    [{login => 'club'}] => Bivio::DieCode->NOT_FOUND,
	    [{}] => Bivio::DieCode->DIE,
	    [{login => 'bad%realm!name'}] => Bivio::DieCode->NOT_FOUND,
	],
    ],
]);
