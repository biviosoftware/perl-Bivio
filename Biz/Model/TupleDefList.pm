# Copyright (c) 2006-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleDefList;
use strict;
use Bivio::Base 'Model.AscendingAuthBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub AUTH_ID_FIELD {
    return 'TupleDef.realm_id';
}

sub find_row_by_label {
    return shift->find_row_by('TupleDef.label', shift);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => ['TupleDef.tuple_def_id'],
        order_by => [qw(
	    TupleDef.label
	    TupleDef.moniker
	)],
	other => [
	    {
		name => 'use_count',
		type => 'Integer',
		constraint => 'NOT_NULL',
		in_select => 1,
		select_value => '(SELECT COUNT(*)
                    FROM tuple_use_t
                    WHERE tuple_use_t.tuple_def_id = tuple_def_t.tuple_def_id)
                    AS use_count',
	    },
	],
    });
}

sub label_to_id {
    return shift->find_row_by_label(@_)->get('TupleDef.tuple_def_id');
}

1;
