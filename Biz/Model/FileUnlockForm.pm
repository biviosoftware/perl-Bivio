# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FileUnlockForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_cancel {
    return 'next';
}

sub execute_empty {
    my($self) = @_;
    $self->load_from_model_properties($self->req('Model.RealmFileLock'));
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->new_other('RealmFileLock')->load({
	realm_file_lock_id => $self->get('RealmFileLock.realm_file_lock_id'),
    })->delete;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
	hidden => [
	    'RealmFileLock.realm_file_lock_id',
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->get_model('RealmFileLock')
	if $self->get('RealmFileLock.realm_file_lock_id');
    return;
}

1;
