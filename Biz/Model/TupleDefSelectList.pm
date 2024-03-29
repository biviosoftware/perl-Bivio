# Copyright (c) 2006-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleDefSelectList;
use strict;
use Bivio::Base 'Model.TupleDefList';


sub internal_load_rows {
    my($self) = shift;
    return [
        {
            map(($_ => undef), @{$self->get_info('column_names')}),
            'TupleDef.label' => 'Select Schema',
            'TupleDef.tuple_def_id' => $self->EMPTY_KEY_VALUE,
        },
        @{$self->SUPER::internal_load_rows(@_)},
    ];
}

1;
