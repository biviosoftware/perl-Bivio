# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FormModeFormBase;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FM) = b_use('Type.FormMode');

sub execute_empty {
    return _dispatch(@_);
}

sub execute_ok {
    return _dispatch(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        other => [
	    $self->field_decl([
		[qw(form_mode FormMode)],
		['list_model', 'Model.' . $self->LIST_MODEL],
	    ]),
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    my($lm) = $self->new_other($self->LIST_MODEL);
    my($fm) = $_FM->setup_by_list_this($lm, $self->PROPERTY_MODEL);
    $self->internal_put_field(
	map(
	    ($_ => $lm->get($_)),
	    @{$lm->get_info('primary_key_names')},
	),
    ) if $fm->eq_edit;
    $self->internal_put_field(
	form_mode => $fm,
	list_model => $lm,
    );
    return @res;
}

sub is_create {
    return shift->get('form_mode')->eq_create;
}

sub is_edit {
    return shift->get('form_mode')->eq_edit;
}

sub _dispatch {
    my($self) = shift;
    my($method) = $self->my_caller . ($self->get('form_mode')->eq_edit ? '_edit' : '_create');
    return $self->$method(@_);
}

1;
