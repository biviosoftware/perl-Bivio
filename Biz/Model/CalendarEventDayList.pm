# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventDayList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	%{$self->get_instance('CalendarEventList')
	      ->decl_for_internal_initialize},
	other_query_keys => ['b_rows'],
    });
}

sub detail_uri {
    return shift->format_uri('THIS_DETAIL', 'FORUM_CALENDAR_EVENT_DETAIL');
}

sub internal_load_rows {
    my(undef, $query) = @_;
    return $query->get('b_rows');
}

1;
