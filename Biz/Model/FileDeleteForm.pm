# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FileDeleteForm;
use strict;
use Bivio::Base 'Model.FileBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    my($realm_file) = $self->get('realm_file');

    if ($realm_file->get('is_folder')) {
	$realm_file->unauth_delete_deep;
    }
    else {
	$self->internal_unlock_realm_file;
	$realm_file->delete;
    }
    return;
}

1;
