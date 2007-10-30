# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Motion;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub form {
    return shift->internal_body(vs_simple_form(
	MotionForm => [
	    'MotionForm.Motion.name',
	    'MotionForm.Motion.question',
 	    [
		'MotionForm.Motion.status' => {
		    enum_sort => 'get_short_desc',
		    show_unknown => 0,
		    column_count => 1,
		}
	    ],
 	    [
		'MotionForm.Motion.type' => {
		    enum_sort => 'get_short_desc',
		    show_unknown => 0,
		    column_count => 1,
		}
	    ],
	],
    ));
}

sub list {
    my($action) = sub {
	my($s, $task, $query) = @_;
	return $s->get_request->format_uri($task, {
	    map(($_ => $s->get($query->{$_})), keys(%$query))
	});
    };
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    'FORUM_MOTION_ADD',
	]),
	body => vs_paged_list(
	    MotionList => [
		'Motion.name',
		'Motion.question',
		'Motion.status',
		{
		    column_heading => String('Actions'),
		    column_widget => ListActions([
			[
			    'Vote',
			    'FORUM_MOTION_VOTE',
			    [$action, 'FORUM_MOTION_VOTE', {
				'ListQuery.this' => 'Motion.motion_id',
			    }],
			    [sub {
			        my($it) = @_;
				return 0
				    if $it->get('Motion.status')
					->equals_by_name('CLOSED');
				my($req) = $it->get_request;
				my($mv) = Bivio::Biz::Model->new($req,
								 'MotionVote');
				$mv->unsafe_load({
				    motion_id => $it->get('Motion.motion_id'),
				    user_id => $req->get('auth_user_id'),
				});
				return !($mv->is_loaded);
			    }],
			],
			[
			    'Results',
			    'FORUM_MOTION_VOTE_LIST',
			    [$action, 'FORUM_MOTION_VOTE_LIST', {
				'ListQuery.parent_id' => 'Motion.motion_id',
			    }],
			],
			[
			    'Edit',
			    'FORUM_MOTION_EDIT',
			],
		    ]),
		},
	    ],
	),
    );
}

sub vote_form {
    return shift->internal_put_base_attr(
	topic => Join([
	    String([qw(Model.MotionVoteForm Motion.name)]),
	    ': ',
	    String([qw(Model.MotionVoteForm Motion.question)]),
	]),
#TODO: Why can't we override attributes?
# 	byline => String('You may cast one vote for this motion, and may not change that vote at a later date. If you are unsure of your position at this time, please click Cancel to exit this page.'),
	body => vs_simple_form(
	    MotionVoteForm => [
		[
		    'MotionVoteForm.MotionVote.vote' => {
			enum_sort => 'get_short_desc',
			show_unknown => 0,
			column_count => 1,
		    }
		],
		'MotionVoteForm.MotionVote.comment',
	    ],
	),
    );
}

sub vote_result {
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    {
		task_id => 'FORUM_MOTION_VOTE_LIST_CSV',
		query => {
		    'ListQuery.parent_id'
			=> [qw(Model.MotionList Motion.motion_id)],
		},
	    },
	]),
	topic => Join([
	    String([qw(Model.MotionList Motion.name)]),
	    ': ',
	    String([qw(Model.MotionList Motion.question)]),
	]),
	body => vs_paged_list(
	    MotionVoteList => [
		'MotionVote.creation_date_time',
		'MotionVote.vote',
		'MotionVote.comment',
		'Email.email',
	    ],
	),
    );
}

sub vote_result_csv {
    return shift->internal_body(CSV(MotionVoteList => [qw(
        MotionVote.creation_date_time
	MotionVote.vote
	MotionVote.comment
	Email.email
    )]));
}

1;
