# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleUseList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub find_row_by_id {
    return shift->find_row_by('TupleUse.tuple_def_id', shift);
}

sub find_row_by_moniker {
    return shift->find_row_by('TupleUse.moniker', shift);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => [[qw(TupleUse.tuple_def_id TupleDef.tuple_def_id)]],
        order_by => [qw(
	    TupleUse.label
	    TupleUse.moniker
	    TupleDef.label
	)],
	other => [
	    {
		name => 'tuple_count',
		type => 'Integer',
		constraint => 'NOT_NULL',
		in_select => 1,
		select_value => '(SELECT COUNT(*)
                    FROM tuple_t
                    WHERE tuple_use_t.tuple_def_id = tuple_t.tuple_def_id
                    AND tuple_use_t.realm_id = tuple_t.realm_id)
                    AS tuple_count',
	    },
	],
	auth_id => 'TupleUse.realm_id',
    });
}

sub moniker_to_id {
    return shift->find_row_by_moniker(@_)->get('TupleUse.tuple_def_id');
}

sub monikers {
    return shift->map_rows(sub {shift->get('TupleUse.moniker')});
}

1;
