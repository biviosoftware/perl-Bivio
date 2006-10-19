# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleDefList;
use strict;
use base 'Bivio::Biz::Model::AscendingAuthList';

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
    });
}

sub label_to_id {
    return shift->find_row_by_label(@_)->get('TupleDef.tuple_def_id');
}

1;
