# $Id$
# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
#
# Only works for petshop (needs demo and root) users
#
use strict;
use Bivio::Biz::Model::UserLoginForm;
use Bivio::Test;
use Bivio::Test::Request;
my($_req) = Bivio::Test::Request->get_instance->setup_http;
Bivio::Test->unit([
    'Bivio::Biz::Model::UserLoginForm' => [
	{
	    method => 'execute',
	    compute_params => sub {
		my($case, $params) = @_;
		return [$_req, {
		    realm_owner => $params->[0]
		        ? Bivio::Biz::Model->new($_req, 'RealmOwner')
		            ->unauth_load_or_die({name => $params->[0]})
		        : undef,
		}];
	    },
	    check_return => sub {
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
		return [$_req->get('auth_user')
		    && $_req->get('auth_user')->get('name')];
	    },
	} => [
	    demo => 'demo',
	    [undef] => [undef],
	    root => 'root',
	],
    ],
]);
