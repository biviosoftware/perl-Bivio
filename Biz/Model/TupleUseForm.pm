# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleUseForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    if (my $m = $self->get_request->unsafe_get('Model.TupleUse')) {
	$self->load_from_model_properties($m);
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my($o, $tdl) = $req->unsafe_get(
	qw(Model.TupleUse Model.TupleDefSelectList));
    unless ($tdl->find_row_by_id($self->get('TupleUse.tuple_def_id'))) {
	$self->internal_put_error('TupleUse.tuple_def_id' => 'NULL');
	return;
    }
    if (
	$o && $req->get('Model.TupleUseList')->get('tuple_count') > 0
           && $o->get('tuple_def_id') ne $self->get('TupleUse.tuple_def_id')
    ) {
	$self->internal_put_error('TupleUse.tuple_def_id' => 'EXISTS');
	return;
    }
    my($m) = $o ? 'update' : 'create';
    ($o || $self->new_other('TupleUse'))->$m({
	map(($_ => $self->get("TupleUse.$_") || $tdl->get("TupleDef.$_")),
	    qw(moniker label tuple_def_id)),
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
            map(+{name => "TupleUse.$_", constraint => 'NONE'},
		qw(label moniker)),
	    'TupleUse.tuple_def_id',
        ],
	auth_id => 'TupleUse.realm_id',
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my($l) = $self->new_other('TupleUseList');
    my($q) = $l->parse_query_from_request;
    $l->get_model('TupleUse')
	if $q->get('this') && $l->unsafe_load_this($q);
    $self->new_other('TupleDefSelectList')->load_all;
    return shift->SUPER::internal_pre_execute(@_);
}

1;
