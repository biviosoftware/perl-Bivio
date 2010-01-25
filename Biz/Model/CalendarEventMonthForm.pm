# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventMonthForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');

sub get_current_query_for_list {
    my($query) = shift->SUPER::get_current_query_for_list(@_);
#TODO: This needs to be encapsulated.  The concent of "month" is
# across CalendarEventMonthForm, CalendarEventMonthList, and MonthList
    $query->{b_month} = $_D->to_literal(
	$_D->set_beginning_of_month($_D->from_literal_or_die($query->{b_month})),
    ) if $query->{b_month};
    return $query;
}

sub get_list_for_field {
    my($self, $field) = @_;
    return $self->get_instance('MonthList')
	if $field eq 'b_month';
    return shift->SUPER::get_list_for_field(@_);
}

sub internal_query_fields {
    return [
	[qw(b_month Date), {
	    default_value => sub {$_D->set_beginning_of_month($_D->now)},
	}],
	[qw(b_list_view Boolean), {default_value => 0}],
	[qw(b_time_zone Boolean), {default_value => 0}],
    ];
}

1;
