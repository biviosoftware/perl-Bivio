# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleUseList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub find_row_by_moniker {
    return shift->find_row_by('TupleUse.moniker', shift);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => ['TupleUse.tuple_def_id'],
        order_by => [qw(
	    TupleUse.label
	    TupleUse.moniker
	)],
	auth_id => 'TupleUse.realm_id',
    });
}

sub moniker_to_id {
    return shift->find_row_by_moniker(@_)->get('TupleUse.tuple_def_id');
}

sub monikers {
    my($self) = @_;
    $self->load_all
	unless $self->is_loaded;
    return $self->map_rows(sub {shift->get('TupleUse.moniker')});
}

1;
