# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Request;
use Bivio::PetShop::Util;
my($req) = Bivio::Test::Request->initialize_fully();
my($demo, $guest) = map(Bivio::PetShop::Util->$_(), qw(DEMO_USER GUEST_USER));
Bivio::Test->new('Bivio::Biz::Action::RealmlessRedirect')->unit([
    [] =>[
	{
	    method => 'execute',
	    compute_params => sub {
		my($task, $user, $state) = @{splice(@_, 1, 1)};
		$req->set_realm(undef);
		$req->put(
		    task_id => $task = Bivio::Agent::TaskId->$task(),
		    task => Bivio::Agent::Task->get_by_id($task),
		);
		$req->set_user($user);
		$req->put(user_state => Bivio::Type::UserState->from_name(
		    $state || ($user ? 'LOGGED_IN' : 'JUST_VISITOR')));
		return [$req];
	    },
	    compute_return => sub {
		my($t) = @{splice(@_, 1, 1)};
		return [
		    ref($t) ? $t->get_name : $t,
		    $req->unsafe_get_nested(qw(auth_realm owner name)),
		];
	    },
	} => [
	    [USER_REALMLESS_REDIRECT => undef] => [visitor_task => undef],
	    [USER_REALMLESS_REDIRECT => undef, 'LOGGED_OUT'] => [LOGIN => undef],
	    [USER_REALMLESS_REDIRECT => $demo] => [USER_ACCOUNT_EDIT => $demo],
	    [USER_REALMLESS_REDIRECT => $demo] => [USER_ACCOUNT_EDIT => $demo],
	    [ORDER_REALMLESS_REDIRECT => $guest] => [unauth_task => undef],
	],
    ],
]);
