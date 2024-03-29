# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleExpandableListForm;
use strict;
use Bivio::Base 'Biz.ExpandableListFormModel';


sub ROW_INCREMENT {
    return 10;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
    });
}

sub internal_initialize_list {
    my($self) = @_;
    my($pl) = $self->new_other($self->PARENT_LIST);
    my($q) = $pl->parse_query_from_request;
    if ($q->get('this') && $pl->unsafe_load_this($q)) {
        $self->internal_initialize_this_list(
            $pl, $self->new_other($self->get_list_class));
    }
    else {
        $self->new_other($self->get_list_class)->load_empty;
    }
    return shift->SUPER::internal_initialize_list(@_);
}

1;
