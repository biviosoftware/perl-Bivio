# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Motion;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;
use Bivio::UI::DateTimeMode;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_VT) = b_use('Type.MotionVote');


sub WANT_BADGE_NUMBER {
    return 0;
}

sub WANT_FILE_FIELDS {
    return 1;
}

sub WANT_VOTE_COMMENT {
    return 1;
}

sub comment_form {
    my($self) = @_;
    $self->internal_topic_from_list;
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
	    {
		task_id => 'FORUM_MOTION_COMMENT_LIST_CSV',
		query => ['->req', 'query'],
	    },
	    'FORUM_MOTION_LIST',
	]),
	$self->internal_topic_from_motion,
	body => [ \&_comment_list,  [qw(Model.MotionCommentList)]],
    );
}


sub comment_result_csv {
    my($self) = @_;
    return shift->internal_body([sub {
	my($source) = @_;
        return CSV(MotionCommentList =>
	    $self->internal_comment_csv_fields(
		$source->req('Model.MotionCommentList')),
	);
    }]);
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
	    map(["MotionForm.Motion.$_" => {
		enum_sort => 'get_short_desc',
		show_unknown => 0,
		column_count => 1,
	    }], qw(status type)),
	    $self->WANT_FILE_FIELDS
		? $self->internal_file_fields
		: (),
	]),
    );
}

sub internal_comment_csv_fields {
    my($self, $model) = @_;
    return [
	'RealmOwner.display_name',
	'MotionComment.comment',
	map($_, $model->tuple_tag_field_check),
    ];
}

sub internal_date_time_attr {
    return (
	mode => 'DATE_TIME',
    );
}

sub internal_file_fields {
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

sub internal_list_actions {
    return [
	[
	    'Edit',
	    'FORUM_MOTION_FORM',
	],
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
	    'Status',
	    'FORUM_MOTION_STATUS',
	    'THIS_AS_PARENT',
	],
    ];
}

sub internal_topic_from_list {
    my($self) = @_;
    $self->internal_put_base_attr(
	topic => Join([
	    String([qw(Model.MotionList Motion.name)]),
	    ': ',
	    String([qw(Model.MotionList Motion.question)]),
	]),
    );
    return;
}

sub internal_topic_from_motion {
    my($self) = @_;
    $self->internal_put_base_attr(
	topic => Join([
	    String([qw(Model.Motion name)]),
	    ': ',
	    String([qw(Model.Motion question)]),
	]),
    );
    return;
}

sub list {
    my($self) = @_;
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
		[ 'Motion.status', {
		    column_widget =>	
			If( [ '->is_open' ] ,	
			    String("Open"),	
			    String("Closed"))
		    }
	        ],
		[ 'Motion.start_date_time', {
		    $self->internal_date_time_attr,
		    value => ['Motion.start_date_time'],
		}],
		[ 'Motion.end_date_time', {
		    $self->internal_date_time_attr,
		    value => ['Motion.end_date_time'],
		}],
		[ 'vote_count', {
		    column_data_class => 'vote_count',
		        column_widget => Join([       
			    Integer("yes_count"),
			    String("/"),	
			    Integer("no_count"),
			    String("/"),
			    Integer("abstain_count"),
			]), 
		    }
	        ],
		vs_actions_column($self->internal_list_actions),
	    ],
	),
    );
}

sub status {
    my($self) = @_;

    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    {
		task_id => 'FORUM_MOTION_VOTE_LIST_CSV',
		query => ['->req', 'query'],
	    },
	    {
		task_id => 'FORUM_MOTION_COMMENT_LIST_CSV',
		query => ['->req', 'query'],
	    },
	    'FORUM_MOTION_LIST',
	]),
	body => Join( [
	    Grid([
		[ _label_cell('Name'), _value_cell([qw(Model.Motion name)] )],
		[ _label_cell('Question'), _value_cell([qw(Model.Motion question)]) ],
		[ _label_cell('File'), _value_cell([\&_file_link, [qw(Model.Motion)]]) ],
		[ _label_cell('Start time'), _value_cell(
		    vs_display('Motion.start_date_time', {
			value => [qw(Model.Motion start_date_time)],
			$self->internal_date_time_attr,
		    }))],
		[ _label_cell('End time'), _value_cell(
		    If([qw(Model.Motion end_date_time)],
		       vs_display('Motion.end_date_time', {
			   value => [qw(Model.Motion end_date_time)],
			   $self->internal_date_time_attr,
		       }),
		       'open',
		    ),
		)],
		[ _label_cell('Yes'),  _value_cell([ 'Model.Motion', '->vote_count_yes' ], ), ],  	
		[ _label_cell('No'),  _value_cell([ 'Model.Motion', '->vote_count_no' ], ), ],  	
		[ _label_cell('Abstain'),  _value_cell([ 'Model.Motion', '->vote_count_abstain' ], ),  ],  	
	    ],
		 {
		     class => 'simple',
		     align => 'center',
		 }
	     ),
             Grid([
		 [ _value_cell(' ') ],
		 [ _label_cell('Votes'), Join([ [\&_vote_list, $self ]]) ],
		 [ _value_cell(' ') ],
		 [ _label_cell('Comments'), Join([ [ \&_comment_list, [qw(Model.MotionCommentList)] ] ] ) ],
	    ],
		 {
		     class => 'simple',
		     align => 'center',
		 }
	    ),
	]
      )
    )
}

sub vote_form {
    my($self) = @_;
    $self->internal_topic_from_list;
    return shift->internal_body(
	vs_simple_form(MotionVoteForm => [
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
    my($self) = @_;
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    {
		task_id => 'FORUM_MOTION_VOTE_LIST_CSV',
		query => ['->req', 'query'],
	    },
	    'FORUM_MOTION_LIST',
	]),
	$self->internal_topic_from_motion,
	body => [ \&_vote_list, $self ]
    );
}

sub vote_result_csv {
    my($self) = @_;
    return shift->internal_body(CSV(MotionVoteList => [
        'MotionVote.creation_date_time',
	'MotionVote.vote',
	$self->WANT_VOTE_COMMENT ? 'MotionVote.comment' : (),
	'Email.email',
    ]));
}

sub _comment_list {
    my($req, $model) = @_;
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
}

sub _file_link {
    my ($req, $motion) = @_;
    if (my $mfid = $motion->unsafe_get('motion_file_id')) {
	if (my $rf = $motion->new_other('Bivio::Biz::Model::RealmFile')
		->load({realm_file_id => $mfid})) {
	    if (my $path = $rf->unsafe_get('path')) {
		return Link(
		    String($path),
		    URI({
			task_id => 'FORUM_FILE',
			path_info => $path,
		    }),
  		),		
	    }
	}
    }
    return;
}

sub _label_cell  {
    my($text) = @_;
    return String(Join([String($text), ':']))
	->put(map(($_ => 'label label_ok'),
	    qw(column_data_class cell_class column_footer_class)));
}

sub _value_cell {
    my($text) = @_;
    return String($text)
	->put(cell_class => 'simple field');
}

sub _vote_list {
    my ($req, $self) = @_;
    return vs_paged_list(
	    MotionVoteList => [
		'MotionVote.creation_date_time',
		'MotionVote.vote',
		$self->WANT_VOTE_COMMENT ? 'MotionVote.comment' : (),
		'Email.email',
	    ],
	    {
		no_pager => 1,
	    }
	);
}

1;
