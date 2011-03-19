# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Motion;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub WANT_FILE_FIELDS {
    return 1;
}

sub comment_form {
    my($self) = @_;
    return shift->internal_body([sub {
        my($source) = @_;
	my($model) = $source->req('Model.MotionCommentForm');
        return vs_simple_form(MotionCommentForm => [
	    'MotionCommentForm.MotionComment.comment',
	    map(["MotionCommentForm.$_", {
		wf_type => $model->get_field_type($_),
	    }], $model->tuple_tag_field_check),
	]);
    }]);
}

sub comment_result {
    my($self) = @_;
    vs_put_pager('MotionCommentList');
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    'FORUM_MOTION_LIST',
	]),
	_topic(),
	body => [sub {
            my($source) = @_;
	    my($model) = $source->req('Model.MotionCommentList');
	    return vs_paged_list(
		MotionCommentList => [
		    'RealmOwner.display_name',
		    'MotionComment.comment',
		    map([$_, {
			wf_type => $model->get_field_type($_),
			column_heading =>
			    String(vs_text($model->simple_package_name, $_)),
		    }], $model->tuple_tag_field_check),
		], {
		    no_pager => 1,
		});
	}],
    );
}

sub form {
    my($self) = @_;
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    'FORUM_MOTION_LIST',
	]),
	body => vs_simple_form(MotionForm => [
	    FormFieldError('Motion.name_lc'),
	    'MotionForm.Motion.name',
	    'MotionForm.Motion.question',
	    $self->WANT_FILE_FIELDS
		? _file_fields($self)
		: (),
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
	    'MotionForm.Motion.moniker',
	]),
    );
}

sub list {
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    'FORUM_MOTION_FORM',
	]),
	body => vs_paged_list(
	    MotionList => [
		'Motion.name',
		'Motion.question',
		['Motion.motion_file_id', {
		    column_widget => Link(
			String(['file_name']),
			URI({
			    task_id => 'FORUM_FILE',
			    path_info => ['RealmFile.path'],
			}),
		    ),
		    column_order_by => ['RealmFile.path_lc'],
		}],
		'Motion.status',
		'Motion.start_date_time',
		'Motion.end_date_time',
		'vote_count',
		vs_actions_column([
		    [
			'Vote',
			'FORUM_MOTION_VOTE',
			'THIS_DETAIL',
			['->can_vote'],
		    ],
		    [
			'Comment',
			'FORUM_MOTION_COMMENT',
			'THIS_DETAIL',
			['->can_comment'],
		    ],
		    [
			'Results',
			'FORUM_MOTION_VOTE_LIST',
			'THIS_AS_PARENT',
		    ],
		    [
			'View Comments',
			'FORUM_MOTION_COMMENT_LIST',
			'THIS_AS_PARENT',
		    ],
		    [
			'Edit',
			'FORUM_MOTION_FORM',
		    ],
		]),
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
	body => vs_simple_form(MotionVoteForm => [
	    [
		'MotionVoteForm.MotionVote.vote' => {
		    enum_sort => 'get_short_desc',
		    show_unknown => 0,
		    column_count => 1,
		}
	    ],
	    'MotionVoteForm.MotionVote.comment',
	]),
    );
}

sub vote_result {
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    {
		task_id => 'FORUM_MOTION_VOTE_LIST_CSV',
		query => ['->req', 'query'],
	    },
	    'FORUM_MOTION_LIST',
	]),
	_topic(),
	body => vs_paged_list(
	    MotionVoteList => [qw(
		MotionVote.creation_date_time
		MotionVote.vote
		MotionVote.comment
		Email.email
	    )],
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

sub _file_fields {
    my($self) = @_;
    return (
	[String(After(vs_text('Motion.motion_file_id'), ':'))
	    ->put(cell_class => 'label label_ok'),
	    If(['Model.MotionForm', 'Motion.motion_file_id'],
	        Link(
		    String([['Model.MotionForm', '->get_motion_document'],
		        'path']),
		    URI({
			task_id => 'FORUM_FILE',
			path_info => [['Model.MotionForm',
		            '->get_motion_document'], 'path'],
		    }),
		),
	    )->put(row_control =>
	        ['Model.MotionForm', 'Motion.motion_file_id'],
	    ),
        ],
        'MotionForm.file',
    );
}

sub _topic {
    return (
	topic => Join([
	    String([qw(Model.Motion name)]),
	    ': ',
	    String([qw(Model.Motion question)]),
	]),
    );
}

1;
