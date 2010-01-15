# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEventMonthList;
use strict;
use Bivio::Base 'Model.CalendarEventList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	want_date => 1,
    });
}

1;
