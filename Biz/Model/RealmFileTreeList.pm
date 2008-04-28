# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileTreeList;
use strict;
use Bivio::Base 'Model.TreeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RF) = __PACKAGE__->use('Model.RealmFile');
my($_RTK) = __PACKAGE__->use('Type.RowTagKey');
my($_TLN) = __PACKAGE__->use('Type.TreeListNode');

sub LOAD_ALL_SIZE {
    return 5000;
}

sub PARENT_NODE_ID_FIELD {
    return 'RealmFile.folder_id';
}

sub can_check_in {
    my($self) = @_;
    return 0 unless $self->is_file;
    return $self->get('lock_user_id')
	&& ($self->get('lock_user_id') eq $self->req('auth_user_id'))
	? 1 : 0;
}

sub can_check_out {
    my($self) = @_;
    return 0 unless $self->is_file;
    return $self->get('RealmFile.is_read_only') ? 0 : 1;
}

sub can_unlock {
    my($self) = @_;
    return $self->get('lock_user_id') && $self->can_check_in ? 1 : 0;
}

sub internal_default_expand {
    my($self) = @_;
    return [$self->new_other('RealmFile')->load({folder_id => undef})
	->get('realm_file_id')];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
        primary_key => ['RealmFile.realm_file_id'],
        auth_id => ['RealmFile.realm_id', 'RealmOwner.realm_id'],
	order_by => [qw(
	    RealmFile.path_lc
	    RealmFile.modified_date_time
            Email.email
            RealmOwner_2.display_name
	)],
	other => [
	    'RealmOwner.name',
	    'RealmFile.path',
	    'RealmFile.folder_id',
	    'RealmFile.is_read_only',
            [qw(RealmFile.user_id Email.realm_id RealmOwner_2.realm_id)],
	    'RealmFile.is_folder',
	    {
		name => 'base_name',
		type => 'FilePath',
		constraint => 'NONE',
	    },
	    ['Email.location', [$self->use('Model.Email')->DEFAULT_LOCATION]],
	    {
		name => 'lock_user_id',
		type => 'User.user_id',
		in_select => 1,
		select_value => "(
                    SELECT value
                    FROM row_tag_t
                    WHERE primary_id = realm_file_t.realm_file_id
                    AND key = @{[$_RTK->REALM_FILE_LOCK->as_sql_param]}
                 ) AS lock_user_id",
	    },
	],
    });
}

sub internal_is_parent {
    my(undef, $row) = @_;
    return $row->{'RealmFile.is_folder'};
}

sub internal_leaf_node_uri {
    my($self, $row) = @_;
    return $self->get_request->format_uri({
	task_id => $self->get_request->get('task')->get('next'),
	path_info => $row->{'RealmFile.path'},
	query => undef,
    });
}

sub internal_parent_id {
    my($self, $id) = @_;
    return $self->new_other('RealmFile')->load({realm_file_id => $id})
	->get('folder_id');
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{node_state} = $_TLN->LOCKED_LEAF_NODE
	if $row->{lock_user_id};
    $row->{base_name} = $row->{'RealmFile.path'} eq '/' ? '/'
	: Bivio::Type::FileName->get_tail($row->{'RealmFile.path'});
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    # /Mail is probably large so we'll ignore it
    # dot-files are uninteresting, so we'll ignore them.
    # All are available via DAV
    my($mf) = lc($self->get_instance('RealmFile')->MAIL_FOLDER);
    $stmt->where(@{$stmt->map_invoke(
	NOT_LIKE => ['/.%', '%/.%', $mf . '/%', $mf],
	['RealmFile.path_lc'],
    )});
    return shift->SUPER::internal_prepare_statement(@_);
}

sub internal_root_parent_node_id {
    return undef;
}

sub is_child_folder {
    my($self) = @_;
    return is_folder($self) && $self->get('RealmFile.path_lc') ne '/';
}

sub is_file {
    my($self) = @_;
    return $self->get('RealmFile.is_folder') ? 0 : 1;
}

sub is_folder {
    my($self) = @_;
    return $self->get('RealmFile.is_folder');
}

sub is_root {
    my($self) = @_;
    return $self->get_cursor == 0;
}

sub is_text_content_type {
    return $_RF->is_text_content_type(shift, 'RealmFile.');
}

1;
