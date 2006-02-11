# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TreeBaseListForm;
use strict;
use base 'Bivio::Biz::ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_N) = Bivio::Type->get_instance('TreeListNode');

sub execute_empty_row {
    my($self) = @_;
    $self->internal_put_field(
	node_state => $self->get_list_model->get('is_parent_node')
	    ? $_N->NODE_COLLAPSED : $_N->LEAF_NODE,
    );
    return;
}

sub execute_ok_end {
    shift->internal_stay_on_page;
    return;
}

sub execute_ok_row {
    my($self) = @_;
    $self->internal_put_field(
	node_state => $self->get('node_state')->eq_node_collapsed
	    ? $_N->NODE_EXPANDED : $_N->NODE_COLLAPSED,
    ) if $self->unsafe_get('node_button');
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    {
		name => 'node_button',
		type => 'OKButton',
		constraint => 'NONE',
		in_list => 1,
	    },
	],
        hidden => [
	    {
		name => 'node_state',
		type => $_N,
		constraint => 'NOT_NULL',
		in_list => 1,
	    },
	],
    });
}

1;
