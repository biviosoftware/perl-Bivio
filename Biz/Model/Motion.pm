# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Motion;
use strict;
use Bivio::Base 'Model.RealmBase';

my($_DT) = b_use('Type.DateTime');
my($_MS) = b_use('Type.MotionStatus');
my($_MT) = b_use('Type.MotionType');
my($_VT) = b_use('Type.MotionVote');

sub create {
    my($self, $values) = @_;
    $values->{name_lc} = lc($values->{name});
    $values->{type} ||= $_MT->VOTE_PER_USER;
    $values->{status} ||= $_MS->OPEN;

    if ($values->{status}->eq_open) {
	$values->{start_date_time} ||= $_DT->now;
    }
    return shift->SUPER::create(@_);
}

sub update {
    my($self, $values) = @_;

    if ($values->{name}) {
	$values->{name_lc} = lc($values->{name});
    }

    if ($values->{status}
	&& $values->{status} != $self->get('status')) {

	if ($values->{status}->eq_open) {
	    $values->{start_date_time} = $_DT->now;
	    $values->{end_date_time} = undef;
	}
	elsif ($values->{status}->eq_closed) {
	    $values->{end_date_time} = $_DT->now;
	}
    }
    return shift->SUPER::update(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'motion_t',
        columns => {
            motion_id => ['PrimaryId', 'PRIMARY_KEY'],
	    name => ['Line', 'NOT_NULL'],
	    name_lc => ['Line', 'NOT_NULL'],
	    question => ['Text64K', 'NOT_NULL'],
	    status => ['MotionStatus', 'NOT_NULL'],
	    type => ['MotionType', 'NOT_NULL'],
	    start_date_time => ['DateTime', 'NONE'],
	    end_date_time => ['DateTime', 'NONE'],
      	    motion_file_id => ['RealmFile.realm_file_id', 'NONE'],
	    tuple_def_id => ['TupleUse.tuple_def_id', 'NONE'],
	},
	other => [
	    [qw(realm_id RealmOwner.realm_id)],
	    [qw(motion_file_id RealmFile.realm_file_id)],
	    [qw(tuple_def_id TupleDef.tuple_def_id)],
	],
    });
}

sub is_open {
    my($self) = @_;
    my($end) = $self->get('end_date_time');
    return 1 unless $end;
    return $_DT->compare_defined($end, $_DT->now) > 0 ? 1 : 0;
}

sub vote_count {
    my($self,  $vote_type) = @_;
    return b_use('SQL.Connection')->execute_one_row('
        SELECT COUNT(*)
        FROM motion_vote_t mv
        WHERE mv.motion_id = ?
        ' . ($vote_type ? 'AND mv.vote = ?' : ''),
	[$self->get('motion_id'), $vote_type->as_sql_param || ()])->[0];
}

sub vote_count_abstain {
    return shift->vote_count($_VT->ABSTAIN);
}

sub vote_count_no {
    return shift->vote_count($_VT->NO);
}

sub vote_count_yes {
    return shift->vote_count($_VT->YES);
}

1;
