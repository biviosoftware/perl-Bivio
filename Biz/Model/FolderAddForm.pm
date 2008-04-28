# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FolderAddForm;
use strict;
use Bivio::Base 'Model.FileBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');

sub execute_ok {
    my($self) = @_;
    $self->new_other('RealmFile')->create_folder({
	path => $_FP->join($self->get('realm_file')->get('path'),
	    $self->get('name')),
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

1;
