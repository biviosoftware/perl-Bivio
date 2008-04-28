# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FileUpdateForm;
use strict;
use Bivio::Base 'Model.FileBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    $self->internal_unlock_realm_file;
    $self->new_other('RowTag')->replace_value(
	$self->get('realm_file')->update_with_content({
	    override_is_read_only => 1,
	}, $self->get('file')->{content})->get('realm_file_id'),
	REALM_FILE_COMMENT => $self->get('comment'));
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	visible => [
	    {
		name => 'file',
		type => 'FileField',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'comment',
		type => 'Text',
		constraint => 'NONE',
	    },
	],
    });
}

1;
