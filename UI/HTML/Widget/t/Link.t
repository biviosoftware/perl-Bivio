# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Widget;
use Bivio::UI::Widget::Join;
Bivio::Test::Widget->unit(
    'Bivio::UI::HTML::Widget::Link',
    sub {
	shift->put(task_id => Bivio::Agent::TaskId->LOGOUT);
	return;
    },
    [
	['txt', '#anchor'] => '<a target="_top" href="#anchor">txt</a>',
	['txt', '#', 'foo'] => '<a target="_top" class="foo" href="#">txt</a>',
	['txt', '#', {id => 'id6'}]
	    => '<a target="_top" id="id6" href="#">txt</a>',
	['txt', '#', {link_target => [sub {''}]}] => '<a href="#">txt</a>',
	['txt', [sub {'/url'}]]
	    => '<a target="_top" href="/url">txt</a>',
	map(($_ => '<a target="_top" href="/pub/login?fc=aNTE4!bMg__">txt</a>'),
	    ['txt', 'LOGIN'],
	    ['txt', [sub {'LOGIN'}]],
	    ['txt', Bivio::Agent::TaskId->LOGIN],
	    ['txt', [sub {Bivio::Agent::TaskId->LOGIN}]],
	    ['txt', {task_id => 'LOGIN'}],
	    [_j('txt'), _j('LOGIN')],
	    ['txt', [sub {_j('LOGIN')}]],
	),
	map(($_ => '<a target="_top" href="/pub/login">txt</a>'),
	    ['txt', {task_id => 'LOGIN', no_context => 1}],
	    ['txt', [sub {return {task_id => 'LOGIN', no_context => 1}}]],
	),
    ],
);

sub _j {
    return Bivio::UI::Widget::Join->new([@_]);
}
