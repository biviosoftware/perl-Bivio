# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = b_use('Type.FilePath');
my($_DT) = b_use('Type.DateTime');
my($_VT) = b_use('Type.MotionVote');

sub can_comment {
    my($self) = @_;
    return $self->is_open;
}

sub can_vote {
    my($self) = @_;
    return $self->is_open;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	auth_id => ['Motion.realm_id'],
	primary_key => ['Motion.motion_id'],
	order_by => [qw(
	    Motion.name_lc
	    Motion.question
	    Motion.start_date_time
	    Motion.end_date_time
	    Motion.status
	    RealmFile.path_lc
	)],
        other => [qw(
	    Motion.name
	    Motion.question
	    Motion.type
	    Motion.motion_file_id
	    Motion.tuple_def_id
	    TupleUse.moniker
	    RealmFile.path
	    ),
	    {
		name => 'file_name',
		type => 'FileName',
		constraint => 'NONE',
	    },
	    $self->vote_count_field($_VT->YES),
	    $self->vote_count_field($_VT->NO),
	    $self->vote_count_field($_VT->ABSTAIN),
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{file_name} = defined($row->{'RealmFile.path'})
	? $_FP->get_versionless_tail($row->{'RealmFile.path'})
	: undef;
    return shift->SUPER::internal_post_load_row(@_);
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->from($stmt->LEFT_JOIN_ON('Motion', 'RealmFile', [
	[qw(Motion.motion_file_id RealmFile.realm_file_id)],
    ]));
    $stmt->from($stmt->LEFT_JOIN_ON('Motion', 'TupleUse', [
	[qw(Motion.tuple_def_id TupleUse.tuple_def_id)],
	[qw(Motion.realm_id TupleUse.realm_id)],
    ]));
    return;
}

sub is_open {
    my($self) = @_;
    my($end) = $self->get('Motion.end_date_time');
    return 1 unless $end;
    return $_DT->compare_defined($end, $_DT->now) > 0 ? 1 : 0;
}

sub vote_count_field {
    my($self, $vote) = @_;
    return {
	name => lc($vote->get_name) . '_count',
	type => 'Integer',
	constraint => 'NONE',
	in_select => 1,
	select_value => '(
            SELECT COUNT(*)
                FROM motion_vote_t mv
                WHERE mv.motion_id = motion_t.motion_id
                AND mv.vote = ' . $vote->as_sql_param
		 . ') AS ' . lc($vote->get_name) . '_count'
    };
}

1;
