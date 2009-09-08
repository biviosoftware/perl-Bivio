# $Id$
# Copyright (c) 2004 bivio Software, Inc.  All rights reserved.
use strict;
use Bivio::Test::Request;
my($req) = Bivio::Test::Request->initialize_fully;
Bivio::Test->new({
    class_name => 'Bivio::Biz::FormContext',
    check_return => sub {
	my($case, $actual, $expect) = @_;
	$case->actual_return([$actual->[0]->get_shallow_copy]);
	return $expect;
    },
})->unit([
    'Bivio::Biz::FormContext' => [
	'new_empty' => [
	    [$req, Bivio::Biz::Model->new($req, 'UserLoginForm')] => [{
		form_model => undef,
		form => undef,
		form_context => undef,
		query => undef,
		path_info => undef,
		unwind_task => Bivio::Agent::TaskId->SITE_ROOT,
	        cancel_task => Bivio::Agent::TaskId->SITE_ROOT,
		realm => undef,
	    }],
        ],
    ],
    sub {'Bivio::Biz::FormModel'} => [
	'get_context_from_request' => [
	    [{}, $req] => [{
		form_model => undef,
		form => undef,
		form_context => undef,
		query => undef,
		path_info => undef,
		unwind_task => Bivio::Agent::TaskId->SHELL_UTIL,
	        cancel_task => Bivio::Agent::TaskId->SITE_ROOT,
		realm => Bivio::Auth::Realm->get_general,
	    }],
#NOTE: task state change
	    sub {
		return [{},
		    $req->put(
		    task_id => Bivio::Agent::TaskId->LOGIN,
		    task => Bivio::Agent::Task->get_by_id(
			Bivio::Agent::TaskId->LOGIN),
		)];
	    } => [{
		form_model => qr{Bivio::\w+::Model::UserLoginForm},
		form => undef,
		form_context => undef,
		query => undef,
		path_info => undef,
		unwind_task => Bivio::Agent::TaskId->LOGIN,
	        cancel_task => Bivio::Agent::TaskId->CART,
		realm => Bivio::Auth::Realm->get_general,
	    }],
        ],
    ],
    sub {
	return $req->put(
	    task_id => Bivio::Agent::TaskId->SITE_ROOT,
	    task => Bivio::Agent::Task->get_by_id(
		Bivio::Agent::TaskId->SITE_ROOT),
	);
    } => [
	server_redirect => [
	    [Bivio::Agent::TaskId->LOGIN] => undef,
        ],
	get => [
	    form_context => [{
		form_model => undef,
		form => undef,
		form_context => undef,
		query => undef,
		path_info => undef,
		unwind_task => Bivio::Agent::TaskId->SITE_ROOT,
	        cancel_task => undef,
		realm => Bivio::Auth::Realm->get_general,
	    }],
	],
    ],
]);
