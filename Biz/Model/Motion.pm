# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Motion;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

sub create {
    my($self, $values) = @_;
    $values->{name_lc} = lc($values->{name});

    if ($values->{status}->eq_open) {
	$values->{start_date_time} ||= $_DT->now;
    }
    return shift->SUPER::create(@_);
}

sub update {
    my($self, $values) = @_;
    $values->{name_lc} = lc($values->{name});

    if ($values->{status}
	&& $values->{status} != $self->get('status')) {

	if ($values->{status}->eq_open) {
	    $values->{start_date_time} ||= $_DT->now;
	    $values->{end_date_time} = undef;
	}
	else {
	    $values->{end_date_time} ||= $_DT->now;
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
	    question => ['Text', 'NOT_NULL'],
	    status => ['MotionStatus', 'NOT_NULL'],
	    type => ['MotionType', 'NOT_NULL'],
	    start_date_time => ['DateTime', 'NONE'],
	    end_date_time => ['DateTime', 'NONE'],
	    motion_file_id => ['RealmFile.realm_file_id', 'NONE'],
	    moniker => ['TupleMoniker', 'NONE'],
	},
	other => [
	    [qw(realm_id RealmOwner.realm_id)],
	    [qw(motion_file_id RealmFile.realm_file_id)],
	],
    });
}

1;
