# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TreeBaseList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info(
	$self->get_instance(
	    $self->get_instance($self->LIST_FORM_CLASS)->get_list_class,
	)->internal_initialize,
	{
	    other => [
		{
		    name => 'full_list_index',
		    type => 'Integer',
		    constraint => 'NOT_NULL',
		},
	    ],
	},
    );
}

sub internal_load_rows {
    my($self) = @_;
    my($fm) = $self->get_request->get('Model.' . $self->LIST_FORM_CLASS);
    my($lm) = $self->[$_IDI] = $fm->get_list_model;
    my($pk) = $lm->get_info('primary_key_names')->[0];
    my($rows) = [];
    my($collapsed) = {};
    for ($fm->reset_cursor, my $index = 0; $fm->next_row; $index++) {
	my($pc) = $collapsed->{$lm->get('parent_node_id') || 0};
	$collapsed->{$lm->get($pk)}
	    = $pc || $fm->get('node_state')->eq_node_collapsed
	    if $lm->get('is_parent_node');
	# Don't replicate all the data.  See internal_put
	push(@$rows, {full_list_index => $index})
	    unless $pc;
    }
    $fm->reset_cursor;
    return $rows;
}

sub internal_put {
    my($self, $row) = @_;
    my($i) = $row->{full_list_index};
    return shift->SUPER::internal_put(
	defined($i) ? {
	    %$row,
	    %{$self->[$_IDI]->set_cursor_or_die($i)->internal_get},
	} : @_,
    );
}

1;
