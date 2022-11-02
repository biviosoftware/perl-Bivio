# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventMonthList;
use strict;
use Bivio::Base 'Model.CalendarEventList';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_DT) = b_use('Type.DateTime');
my($_D) = b_use('Type.Date');
my($_TZ) = b_use('Type.TimeZone');

sub LIST_QUERY_FORM_CLASS {
    return b_use('Model.CalendarEventMonthForm');
}

sub auth_user_time_zone {
    my($self) = @_;
    return $self->req->cache_for_auth_user(
        'time_zone',
        sub {$_TZ->row_tag_get($self->req('auth_user_id'), $self->req)},
    );
}

sub begin_and_end_date_times {
    return @{shift->[$_IDI]};
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        other => [
            $self->field_decl([qw(
                CalendarEvent.dtstart
                CalendarEvent.dtend
            )], {sort_order => 1}),
        ],
        other_query_keys => $self
            ->get_instance($self->LIST_QUERY_FORM_CLASS)
            ->filter_keys,
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    _if_tz($self, sub {
        $row->{'CalendarEvent.time_zone'} = shift;
        return;
    });
    return shift->SUPER::internal_post_load_row(@_);
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($bom) = _query($self, 'b_month');
    $self->new_other('MonthList')->load_all({b_month => $bom});
    my($begin) = $_DT->set_beginning_of_week($bom);
    my($end) = $_DT->set_end_of_week(
        $_DT->set_end_of_day($_DT->set_end_of_month($bom)));
    _if_tz($self, sub {
        my($tz) = @_;
        $begin = $tz->date_time_to_utc($begin);
        $end = $tz->date_time_to_utc($end);
        return;
    });
    $self->[$_IDI] = [$begin, $end];
    $stmt->where(
        $stmt->OR(
            map($stmt->AND(
                $stmt->GTE("CalendarEvent.$_", [$begin]),
                $stmt->LTE("CalendarEvent.$_", [$end]),
            ), qw(dtstart dtend)),
        ),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

sub _if_tz {
    my($self, $op) = @_;
    return
        unless _query($self, 'b_time_zone');
    return $op->($self->auth_user_time_zone);
}

sub is_list_view {
    return _query(shift, 'b_list_view');
}

sub is_time_zone {
    return _query(shift, 'b_time_zone');
}

sub this_month {
    return $_DT->get_parts(_query(shift, 'b_month'), 'month');
}

sub week_list {
    my($self) = @_;
    return $self->new_other('CalendarEventWeekList')
        ->load_all({b_month_list => $self});
}

sub _query {
    my($self, $which) = @_;
    return $self->req($self->LIST_QUERY_FORM_CLASS)->get($which);
}

1;
