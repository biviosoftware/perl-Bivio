# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::BlogForm;
use strict;
use base 'Bivio::Biz::Model::WikiForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    shift->SUPER::execute_ok(@_);
    $self->get_request()->delete('path_info');
    return;
}

sub internal_pre_execute {
    my($self) = @_;
    shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field('RealmFile.path_lc'
        => Bivio::Biz::Model::WikiForm::_authorized_name($self))
	    if $self->get('file_exists');
    $self->internal_clear_error('RealmFile.path_lc');
    return;
}

sub is_field_editable {
    my($self, $field) = @_;
    return 0
	if $field eq 'RealmFile.path_lc' && $self->get('file_exists');
    return 1;
}

sub name_type {
    return Bivio::Type->get_instance('BlogName');
}

1;
