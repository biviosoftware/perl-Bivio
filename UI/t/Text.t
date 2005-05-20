# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::UI::View;
use Bivio::Test::Request;
my($req) = Bivio::Test::Request->setup_facade;
Bivio::Test->new('Bivio::UI::Text')->unit([
    'Bivio::UI::Text' => [
	get_value => [
	    test_text => 'Global',
	    'Test_Text_Parent.test_text' => 'Child',
	    [qw(Test_Text_Parent test_text)] => 'Child',
	    [qw(Test_Text_Parent test_text_only_child)] => 'Only Child',
	    test_text_only_child => Bivio::DieCode->DIE,
	],
    ],
]);
