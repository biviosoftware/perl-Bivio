# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileRestoreForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_FP) = b_use('Type.FilePath');
my($_VERSIONS_FOLDER) = $_FP->VERSIONS_FOLDER;

sub execute_ok {
    my($self) = @_;
    $self->get('realm_file')->restore;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_context => 1,
	other => [
	    {
		name => 'realm_file',
		type => 'Model.RealmFile',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field(
	realm_file => $self->new_other('RealmFile')
	    ->set_ephemeral
	    ->load({path => $self->req('path_info')}),
    );
    return @res;
}

1;
