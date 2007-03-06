# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MS) = Bivio::Type->get_instance('MotionStatus');
my($_MT) = Bivio::Type->get_instance('MotionType');

sub execute_empty {
    my($self) = @_;
    if (_is_create($self)) {
	$self->internal_put_field('Motion.status' => $_MS->from_name('OPEN'));
	$self->internal_put_field('Motion.type' =>
				      $_MT->from_name('VOTE_PER_USER'));
    }
    else {
	$self->load_from_model_properties('Motion');
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    shift->SUPER::execute_ok(@_);
    return if $self->in_error;
    $self->new_other('Motion')->create_or_update({
	%{$self->get_model_properties('Motion')},
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	visible => [qw(
		       Motion.name
		       Motion.question
		       Motion.status
		       Motion.type
		   )],
	other => [qw(
		     Motion.motion_id
		 )],
    });
}

sub validate {
    my($self) = @_;
    shift->SUPER::validate(@_);
    $self->new_other('MotionList')->do_iterate(
	sub {
	    my($it) = @_;
	    if (lc($self->get('Motion.name')) eq lc($it->get('Motion.name'))) {
		$self->internal_put_error('Motion.name' => 'EXISTS')
		    unless _is_create($self) ||
			$self->get('Motion.motion_id')
			    eq $it->get('Motion.motion_id');
	    }
	    return 1;
	});
    return;
}

sub _is_create {
    my($self) = @_;
    my($fm) = $self->get_request->unsafe_get('Type.FormMode');
    return !$fm || $fm->eq_create ? 1 : 0;
}

sub internal_pre_execute {
    my($self) = @_;
    unless (_is_create($self)) {
	my($l) = $self->get_request->unsafe_get('Model.MotionList');
	$self->internal_put_field('Motion.motion_id' =>
				      $l->get('Motion.motion_id'))
	    if $l && $l->unsafe_get('Motion.motion_id');
    }
    return;
}

1;
