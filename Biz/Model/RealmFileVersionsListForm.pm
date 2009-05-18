# Copyright (c) 2008 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileVersionsListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub execute_empty_row {
    my($self) = @_;
    $self->internal_put_field('compare' => $self->get_list_model->get('RealmFile.realm_file_id'))
	if $self->get_list_model->get_cursor == 1;
    return if $self->get_list_model->get_cursor;
    $self->internal_put_field('selected' => $self->get_list_model->get('RealmFile.realm_file_id'));
    return;
}

sub execute_ok {
    my($self) = @_;
    return {
	query => {
	    compare => $self->get('compare'),
	    selected => $self->get('selected'),
	},
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'RealmFileVersionsList',
	visible => [
	    map({
		name => $_,
		type => 'PrimaryId',
		constraint => 'NOT_NULL',
		in_list => 0,
	    }, qw(compare selected)),
	],
    });
}

sub internal_initialize_list {
    my($self) = @_;
    my($lm) = shift->SUPER::internal_initialize_list(@_);
    $self->[$_IDI] = (
	@{$lm->map_rows(sub {
	    return shift->get('RealmFile.realm_file_id');
	})},
    );
    $lm->reset_cursor;
    return $lm;
}

1;
