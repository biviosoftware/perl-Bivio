# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventDayList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	%{$self->get_instance('CalendarEventList')
	      ->decl_for_internal_initialize},
	other_query_keys => ['b_rows'],
    });
}

sub internal_load_rows {
    my(undef, $query) = @_;
    return $query->get_and_delete('b_rows');
}

1;
