# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Request;
my($req) = Bivio::Test::Request->setup_facade;
Bivio::Test->new('Bivio::UI::Text')->unit([
    sub {
	$req->get_nested('Bivio::UI::Facade', 'Text');
    } => [
	get_value => [
	    test_text => 'Global',
	    'Test_Text_Parent.test_text' => 'Child',
	    [qw(Test_Text_Parent test_text)] => 'Child',
	    [qw(Test_Text_Parent test_text_only_child)] => 'Only Child',
	    test_text_only_child => Bivio::DieCode->DIE,
	],
	get_widget_value => [
	    ['->get_value', 'test_text'] => 'Global',
	    'test_text' => 'Global',
	    'Test_Text_Parent.test_text' => 'Child',
        ],
	unsafe_get_value => [
	    'test_text' => 'Global',
	    'no_such_test_text' => [undef],
        ],
    ],
]);
