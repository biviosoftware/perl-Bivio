# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FileBaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	require_context => 1,
	other => [
	    {
		name => 'realm_file',
		type => 'Model.RealmFile',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field(realm_file =>
	$self->new_other('RealmFile')->load({
	    path => $self->req('path_info') || '/',
	}));
    return;
}

sub internal_unlock_realm_file {
    my($self, $is_override) = @_;
    my($realm_file) = $self->get('realm_file');
    my($user_id) = $self->new_other('RowTag')->get_value(
	$realm_file->get('realm_file_id'), 'REALM_FILE_LOCK');
    return unless $user_id;
    $realm_file->update({
	override_is_read_only => 1,
	is_read_only => 0,
	modified_date_time => $realm_file->get('modified_date_time'),
	user_id => $user_id,
    });
    my($lock) = $self->new_other('RowTag');
    $self->throw_die('FORBIDDEN')
	unless $lock->unsafe_load({
	    primary_id => $realm_file->get('realm_file_id'),
	    key => $self->use('Type.RowTagKey')->REALM_FILE_LOCK,
	    $is_override ? () : (value => $self->req('auth_user_id')),
	});
    $lock->delete;
    return;
}

1;
