# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleExpandableListForm;
use strict;
use base 'Bivio::Biz::ExpandableListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ROW_INCREMENT {
    return 10;
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
