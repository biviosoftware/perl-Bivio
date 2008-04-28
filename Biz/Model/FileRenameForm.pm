# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FileRenameForm;
use strict;
use Bivio::Base 'Model.FileBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = Bivio::Type->get_instance('FilePath');

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(name => $_FP->get_tail(
	$self->get('realm_file')->get('path')));
    return;
}

sub execute_ok {
    my($self) = @_;
    my(@parts) = split('/', $self->get('realm_file')->get('path'));
    my($name) = _file_name($self, pop(@parts));
    $self->get('realm_file')->update({
	path => $_FP->join(@parts, $name),
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	visible => [
	    {
		name => 'name',
		type => 'FileName',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub _file_name {
    my($self, $old_name) = @_;
    my($suffix) = $_FP->get_suffix($old_name);
    return $self->get('name')
	if $self->get('realm_file')->get('is_folder') || ! $suffix;
    return $suffix eq $_FP->get_suffix($self->get('name'))
	? $self->get('name')
	: join('.', $self->get('name'), $_FP->get_suffix($old_name));
}

1;
