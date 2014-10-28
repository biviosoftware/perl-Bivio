# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FormModeBaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_FM) = b_use('Type.FormMode');

sub execute_empty {
    return _dispatch(@_);
}

sub execute_empty_create {
}

sub execute_empty_edit {
}

sub execute_ok {
    return _dispatch(@_);
}

sub execute_ok_create {
}

sub execute_ok_edit {
}

sub internal_initialize {
    my(undef, $delegator, $info) = shift->delegated_args(@_);
    return $delegator->merge_initialize_info(
	$info || $delegator->SUPER::internal_initialize,
	{
	    version => 1,
	    other => [
		$delegator->field_decl([
		    [qw(form_mode FormMode)],
		    ['list_model', 'Model.' . $delegator->LIST_MODEL],
		]),
	    ],
	},
    );
}

sub internal_pre_execute {
    my(undef, $delegator) = shift->delegated_args(@_);
    my(@res) = $delegator->SUPER::internal_pre_execute(@_);
    my($lm) = $delegator->new_other($delegator->LIST_MODEL);
    my($fm) = $_FM->setup_by_list_this($lm, $delegator->PROPERTY_MODEL);
    $delegator->internal_put_field(
	map(
	    ($_ => $lm->get($_)),
	    @{$lm->get_info('primary_key_names')},
	),
    ) if $fm->eq_edit;
    $delegator->internal_put_field(
	form_mode => $fm,
	list_model => $lm,
    );
    return @res;
}

sub is_create {
    my(undef, $delegator) = shift->delegated_args(@_);
    return $delegator->get('form_mode')->eq_create;
}

sub is_edit {
    my(undef, $delegator) = shift->delegated_args(@_);
    return $delegator->get('form_mode')->eq_edit;
}

sub _dispatch {
    my($self) = shift;
    my($method) = $self->my_caller . ($self->get('form_mode')->eq_edit ? '_edit' : '_create');
    return $self->$method(@_);
}

1;
