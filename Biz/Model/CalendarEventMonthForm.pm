# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventMonthForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

my($_CEMD) = b_use('Type.CalendarEventMonthDate');


sub date_to_query {
    my($proto, $date) = @_;
    return {
        b_month => $_CEMD->to_query_value($date),
    };
}

sub get_list_for_field {
    my($self, $field) = @_;
    return $self->get_instance('MonthList')
        if $field eq 'b_month';
    return shift->SUPER::get_list_for_field(@_);
}

sub internal_query_fields {
    return [
        [qw(b_month), $_CEMD, {default_value => sub {$_CEMD->get_default}}],
        [qw(b_list_view Boolean), {default_value => 0}],
        [qw(b_time_zone Boolean), {default_value => 0}],
    ];
}

1;
