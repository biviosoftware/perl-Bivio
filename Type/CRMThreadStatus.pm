# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::CRMThreadStatus;
use strict;
use Bivio::Base 'Type.Enum';

__PACKAGE__->compile([
    UNKNOWN => 0,
    # Alphabetical to get around sorting bug
    CLOSED => 1,
    # removed because unused
    LOCKED => 2,
    NEW => 3,
    OPEN => 4,
    PENDING_CUSTOMER => 5,
    # not necessary after removal of CRMActionList
    UNASSIGN => 6,
]);

sub crm_form_choices {
    my($proto) = @_;
    return b_use('Bivio.TypeValue')->new(
        $proto->package_name,
        _in_use($proto),
    );
}

sub crm_query_choices {
    my($proto) = @_;
    return b_use('Bivio.TypeValue')->new(
        $proto->package_name,
        [
            $proto->UNKNOWN,
            $proto->NEW,
            @{_in_use($proto)},
        ],
    );
}

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


sub _in_use {
    my($proto) = @_;
    return [
        $proto->CLOSED,
        $proto->OPEN,
        $proto->PENDING_CUSTOMER,
    ];
}

1;
