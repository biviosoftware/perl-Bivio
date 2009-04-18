# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CRMThreadStatus;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

__PACKAGE__->compile([
    UNKNOWN => 0,
    # Alphabetical to get around sorting bug
    CLOSED => 1,
    LOCKED => 2,
    NEW => 3,
    OPEN => 4,
    PENDING_CUSTOMER => 5,
]);

sub get_default {
    return shift->OPEN;
}

sub get_desc_for_query_form {
    my($self) = @_;
    return $self->eq_open ? 'Not Closed' : $self->get_short_desc;
}

sub get_criteria_list {
    my($self) = @_;
    return grep(!$_->eq_closed, $self->get_list)
        if $self->eq_open;
    return $self;
}

1;
