# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FullTreeBaseList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub ROOT_PARENT_NODE_ID {
    return 0;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	other => [
	    {
		name => 'parent_node_id',
		type => 'PrimaryId',
		constraint => 'NONE',
	    },
	    {
		name => 'is_parent_node',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'node_level',
		type => 'Integer',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_load {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_load(@_);
    my($rows) = $self->internal_get_rows;
    @$rows = @{_sort(
	$self->ROOT_PARENT_NODE_ID,
	0,
	$rows,
	$self->get_info('primary_key_names')->[0],
    )};
    return;
}

sub _sort {
    my($pid, $level, $rows, $pk) = @_;
    my($parents) = [];
    my($children) = [grep(
	!($_->{parent_node_id} eq $pid
	    && push(@$parents, {%$_, node_level => $level})),
	@$rows,
    )];
    return [
	map(($_, @{_sort($_->{$pk}, $level + 1, $children, $pk)}), @$parents),
    ];
}

1;
