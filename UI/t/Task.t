# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Request;
my($req) = Bivio::Test::Request->initialize_fully;
Bivio::Test->new('Bivio::UI::Task')->unit([
    'Bivio::UI::Task' => [
	{
	    method => 'format_uri',
	    compute_params => sub {
		my(undef, $params) = @_;
		my($task_id, $args) =@$params;
		$args->{task_id} = Bivio::Agent::TaskId->$task_id();
		return [$args, $req];
	    },
        } => [
	    [SITE_ROOT => {}], => '/',
	    [SITE_ROOT => {path_info => 'abc'}] => '/abc',
	    [LOGIN => {no_context => 0}] => qr{'/pub/login\?fc=.+},
	    [LOGIN => {no_context => 1}] => '/pub/login',
	    [SITE_ROOT => {require_context => 1}] => qr{'/\?fc=.+},
	],
     ],
]);
