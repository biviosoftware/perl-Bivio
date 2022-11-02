# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventSeriesList;
use strict;
use Bivio::Base 'Model.CalendarEventList';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        other => [
            {
                name => 'series_count',
                type => 'Integer',
                constraint => 'NONE',
                in_select => 1,
                select_value => "(
                    SELECT COUNT(*)
                    FROM calendar_event_t ce
                    WHERE ce.uid = calendar_event_t.uid
                          AND ce.dtstart > calendar_event_t.dtstart
                ) AS series_count",
            },
        ],
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    if (my $uid = $query->unsafe_get('uid')) {
        $stmt->where($stmt->EQ('CalendarEvent.uid', [$uid]));
    }
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
