# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FileLockForm;
use strict;
use Bivio::Base 'Model.FileBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    my($realm_file) = $self->get('realm_file');
    $self->internal_put_field(file_uri => $self->req->format_uri({
	task_id => 'FORUM_FILE',
	path_info => $realm_file->get('path'),
    }));
    $self->new_other('RowTag')->replace_value(
	$realm_file->update({
	    is_read_only => 1,
	    modified_date_time => $realm_file->get('modified_date_time'),
	    user_id => $self->req('auth_user_id'),
	})->get('realm_file_id'),
	REALM_FILE_LOCK => $realm_file->get('user_id'));
    return {
	method => 'server_redirect',
	task_id => 'next',
	query => $self->unsafe_get_context
	    ? $self->unsafe_get_context->get('query')
	    : undef,
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        other => [
	    {
		name => 'file_uri',
		type => 'Line',
		constraint => 'NONE',
	    },
	],
    });
}

1;
