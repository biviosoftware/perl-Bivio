# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Request;
my($_REQ) = Bivio::Test::Request->setup_facade;
Bivio::Test->new('Bivio::Biz::t::ExpandableListFormModel::T1ListForm')->unit([
    [$_REQ] => [
	execute => [
	    sub {
		Bivio::Biz::Model->new($_REQ, 'NumberedList')->load_page;
		return [$_REQ];
	    } => sub {
		my($case) = @_;
		my($m) = $_REQ->get('Model.T1ListForm');
		$m->reset_cursor;
		$case->actual_return(
		    [$m->get_result_set_size,
			map({
			    $m->next_row;
			    $m->get('form_index');
			} 1..$m->get_result_set_size),
		    ]);
		$m->next_row;
		my($l) = $m->get_list_model;
		return [14, 0..$l->PAGE_SIZE - 1,
		    map({$l->EMPTY_KEY_VALUE} 1..$m->ROW_INCREMENT)];
	    },
	],
    ],
]);

