# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionForm;
use strict;
use Bivio::Base 'Model.FormModeBaseForm';
use Bivio::Biz::Model::StringArrayList;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_MS) = b_use('Type.MotionStatus');
my($_MT) = b_use('Type.MotionType');

my(%_TIME_CONVERSIONS) = (
    'now' => '$_DT->now',
    'end of day' => '$_DT->local_end_of_today',
    'tomorrow' => '$_DT->add_days($_DT->local_end_of_today, 1)',
);
my(@_TIME_NAMES) = sort keys %_TIME_CONVERSIONS;

sub DATE_TIME_SIZE {
    return length('01/01/1970 00:00');
}

sub LIST_MODEL {
    return 'MotionList';
}

sub MOTIONS_FOLDER {
    return '/Polls/';
}

sub PROPERTY_MODEL {
    return 'Motion';
}




sub execute_empty_create {
    my($self) = @_;
    return;
}

sub execute_empty_edit {
    my($self) = @_;
    $self->load_from_model_properties('Motion');
    my($et) = $self->get('Motion.end_date_time');
    if ($et) {   
	$self->internal_put_field('end_date_string',
				  substr($_DT->to_local_string($et), 0, DATE_TIME_SIZE));	
    }
    return;
}

sub execute_ok_create {
    my($self) = @_;
    _add_file($self);
    $self->new_other('Motion')->create($self->get_model_properties('Motion'));
    return;
}

sub execute_ok_edit {
    my($self) = @_;
    _add_file($self);
    
    $self->update_model_properties('Motion');
    return;
}

sub execute_unwind {
    my($self) = @_;
    return;
}

sub get_motion_document {
    my($self) = @_;
    return $self->get('Motion.motion_file_id')
	? $self->new_other('RealmFile')->load({
	    realm_file_id => $self->get('Motion.motion_file_id'),
	})
	: undef;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	visible => [qw(
	    Motion.name
	    Motion.question
	    Motion.moniker
	),
	    {
		name => 'file',
		type => 'FileField',
		constraint => 'NONE',
	    },
	    {
		name => 'end_date_string',
		type => 'String',
		constraint => 'NONE',
	    },
	    {
		name => 'Motion.end_date_time',
		type => 'Date',
	    },
	],
	hidden => [qw(
	    Motion.motion_file_id
	)],
	other => [qw(
	    Motion.motion_id
	    Motion.name_lc
	)],
    });
}


sub internal_pre_execute {
    my($self) = @_;
    my($sal) = $self->new_other('StringArrayList');
    $sal->load_from_string_array(b_use('Type.StringArray')->from_literal(\@_TIME_NAMES));
    $self->internal_put_field('Model.StringArrayList', $sal);
    return shift->SUPER::internal_pre_execute(@_);
}


sub validate {
    my($self) = @_;
    $self->_fix_up_end_date();
    if ($self->get('Motion.moniker')) {
	$self->internal_put_error('Motion.moniker' => 'NOT_FOUND')
	    unless $self->new_other('TupleUse')->unsafe_load({
		moniker => $self->get('Motion.moniker'),
	    });
    }
    return shift->SUPER::validate(@_);
}

sub _add_file {
    my($self) = @_;
    return unless $self->get('file');
    my($name) = b_use('Model.FileChangeForm')
	->validate_file_name($self, 'file');
    return if $self->in_error;
    $self->internal_put_field('Motion.motion_file_id' =>
        $self->new_other('RealmFile')->create_with_content({
	    path => $self->MOTIONS_FOLDER . $name,
	    is_read_only => 1,
	}, $self->get('file')->{content})->get('realm_file_id'));
    return;
}

sub _fix_up_end_date { 
    my($self) = @_;
    my(undef, undef, undef, $day, $month, $year) = $_DT->local_to_parts($_DT->now);  
    my(@suffices) = ('', ':59', ':59', ' 23', "/$year", "/$day");

    my($eds) = $self->get('end_date_string');
    return unless $eds;
    if (my($code) = $_TIME_CONVERSIONS{$eds}) {
        my($edt) = eval($code);
	$self->internal_put_field('Motion.end_date_time', $edt);
	return;
    }
    my($s, $suffix, $edt, $err);
    foreach $s (@suffices) {
        $suffix = $s . $suffix;
	($edt, $err) = $_DT->from_local_literal($eds . $suffix);
        unless ($err) {
	    $self->internal_put_field('Motion.end_date_time', $edt);
            return;
	}
    } 
    $self->internal_put_error('end_date_string' => $err);
    return;    
}

1;
