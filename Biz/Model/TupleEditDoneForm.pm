# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleEditDoneForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
    });
}

sub internal_pre_execute {
    my($self) = @_;
    # AUTH: Make sure this realm can use this schema
    $self->new_other('TupleUseList')->load_this({
	this => $self->new_other('TupleList')->parse_query_from_request
	    ->unsafe_get(qw(parent_id)),
    });
    return;
}

1;
