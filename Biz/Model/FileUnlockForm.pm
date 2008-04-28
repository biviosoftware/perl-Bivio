# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FileUnlockForm;
use strict;
use Bivio::Base 'Model.FileBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    $self->internal_unlock_realm_file(
	$self->req('task_id')->get_name =~ /OVERRIDE/ ? 1 : 0);
    return;
}

1;
