# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventMonthForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');

sub get_list_for_field {
    my($self, $field) = @_;
    return $self->get_instance('MonthList')
	if $field eq 'b_month';
    return shift->SUPER::get_list_for_field(@_);
}

sub internal_query_fields {
    return [
	[qw(b_month Date), {default_value => sub {$_D->now}}],
	[qw(b_list_view Boolean), {default_value => 0}],
    ];
}

1;
