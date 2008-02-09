# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TreeList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_N) = Bivio::Type->get_instance('TreeListNode');
my($_P) = Bivio::Type->get_instance('PrimaryId');
my($_IDI) = __PACKAGE__->instance_data_index;

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	other => [
	    {
		name => 'node_state',
		type => $_N,
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'node_level',
		type => 'Integer',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'node_uri',
		type => 'LongText',
		constraint => 'NONE',
	    },
	],
        other_query_keys => [qw(expand)],
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($rows) = shift->SUPER::internal_load_rows(@_);
    my($e) = $self->[$_IDI];
    my($pkf) = $self->get_info('primary_key_names')->[0];
    my($req) = $self->get_request;
#TODO: Clean expand of dead values, in case from bookmark
    return [map({
	my($row) = $_;
	$row->{node_state} = $self->internal_is_parent($row)
	    ? grep($row->{$pkf} eq $_, @$e) ? $_N->NODE_EXPANDED
	    : $_N->NODE_COLLAPSED : $_N->LEAF_NODE;
	$row->{node_uri} = $row->{node_state}->eq_leaf_node
	    ? $self->internal_leaf_node_uri($row)
	    : $self->internal_parent_node_uri($row);
	$row;
    } @{_sort(
	$self->internal_root_parent_node_id,
	0,
	$rows,
	$pkf,
	$self->PARENT_NODE_ID_FIELD,
    )})]
}

sub internal_parent_node_uri {
    #EXPERIMENTAL: Only override to return undef
    my($self, $row) = @_;
    my($e) = $self->[$_IDI];
    my($pkf) = $self->get_info('primary_key_names')->[0];
    return $self->get_request->format_uri({
	query => $self->get_query->format_uri(
	    $self->internal_get_sql_support, {
		expand => join(
		    ',',
		    grep($row->{$pkf} ne $_, @$e),
		    $row->{node_state}->eq_node_collapsed
			? $row->{$pkf} : (),
		),
		page_number => undef,
	    }),
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    if (my $this = $query->unsafe_get('this')) {
	$query->put(
	    this => undef,
	    expand => join(',', @{_parents($self, $this->[0])}),
	);
    }
    my($e) = [split(
	/,+/,
	$query->get_if_exists_else_put(expand =>
	    join(',', @{$self->internal_default_expand})),
    )];
    $self->[$_IDI] = [@$e];
    my($rpid) = $self->internal_root_parent_node_id;
    $stmt->where(
	defined($rpid) ? $stmt->IN($self->PARENT_NODE_ID_FIELD, [@$e, $rpid])
	    : $stmt->OR(
		$stmt->IN($self->PARENT_NODE_ID_FIELD, $e),
		$stmt->IS_NULL($self->PARENT_NODE_ID_FIELD),
	    ),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

sub _parents {
    my($self, $id) = @_;
    my($pid) = $self->internal_parent_id($id);
    return [
	$id,
	$_P->compare($pid, $self->internal_root_parent_node_id) == 0 ? ()
	    : @{_parents($self, $pid)},
    ];
}

sub _sort {
    my($pid, $level, $rows, $pkf, $pf) = @_;
    my($parents) = [];
    my($children) = [grep(
	!($_P->compare($_->{$pf}, $pid) == 0
	    && push(@$parents, {%$_, node_level => $level})),
	@$rows,
    )];
    return [
	map(($_, @{_sort($_->{$pkf}, $level + 1, $children, $pkf, $pf)}),
	    @$parents),
    ];
}

1;
