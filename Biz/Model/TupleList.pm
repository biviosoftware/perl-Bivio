# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TSN) = Bivio::Type->get_instance('TupleSlotNum');

sub execute_load_history_list {
    my($proto, $req) = @_;
    my($thl) = $proto->new($req, 'TupleHistoryList');
    my($q) = $thl->parse_query_from_request;
    $thl->load_all($q);
    my($t) = $thl->new_other('Tuple')->load({
	thread_root_id => $q->get('parent_id'),
    });
    $proto->new($req)->load_this({
	parent_id => $t->get('tuple_def_id'),
	this => $t->get('tuple_num'),
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        order_by => [qw(
	    Tuple.tuple_num
	    Tuple.modified_date_time
	),
	    @{$_TSN->map_list(sub {'Tuple.' . shift(@_)})},
	],
	primary_key => [
	    'Tuple.tuple_num',
	],
	other => [
	    'Tuple.thread_root_id',
        ],
	parent_id => 'Tuple.tuple_def_id',
	auth_id => 'Tuple.realm_id',
    });
}

sub internal_prepare_statement {
    my($self, undef, $query) = @_;
    $self->new_other('TupleUseList')->load_this({
	this => $query->get('parent_id'),
    });
    $self->new_other('TupleSlotDefList')->unauth_load_all({
	map(($_ => $query->get($_)), qw(parent_id auth_id)),
    });
    return shift->SUPER::internal_prepare_statement(@_);
}

sub parse_query {
    return shift->SUPER::parse_query(@_)->put(want_only_one_order_by => 1);
}

sub slot_label {
    return _slot_row(@_)->get('TupleSlotDef.label');
}

sub is_slot_defined {
    return _slot_row(@_) ? 1 : 0;
}

sub _slot_row {
    return shift->get_request->get('Model.TupleSlotDefList')
	->find_row_by_num(@_);
}

1;
