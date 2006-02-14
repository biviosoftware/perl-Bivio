# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileTreeList;
use strict;
use base 'Bivio::Biz::Model::TreeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LOAD_ALL_SIZE {
    return 5000;
}

sub PARENT_NODE_ID_FIELD {
    return 'RealmFile.folder_id';
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
        auth_id => 'RealmFile.realm_id',
	order_by => [qw(
	    RealmFile.path_lc
	    RealmFile.modified_date_time
            Email.email
	)],
	other => [
	    'RealmFile.path',
	    'RealmFile.folder_id',
            [qw(RealmFile.user_id Email.realm_id)],
	    'RealmFile.is_folder',
	    {
		name => 'base_name',
		type => 'FilePath',
		constraint => 'NONE',
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
	path_info => $row->{'RealmFile.path_lc'},
    });
}

sub internal_parent_id {
    my($self, $id) = @_;
    return $self->new_other('RealmFile')->load({realm_file_id => $id})
	->get('folder_id');
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	if $row->{'RealmFile.path_lc'} eq '/';
    $row->{base_name}
	= Bivio::Type::FileName->get_tail($row->{'RealmFile.path'});
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->EQ('Email.location', $self->get_instance('Email')->DEFAULT_LOCATION);
    # /Mail is probably large so we'll ignore it
    # dot-files are uninteresting, so we'll ignore them.
    # All are available via DAV
    my($mf) = lc($self->get_instance('Forum')->MAIL_FOLDER);
    $stmt->where(@{$stmt->map_invoke(
	NOT_LIKE => ['%/.%', $mf . '/%', $mf],
	['RealmFile.path_lc'],
    )});
    return shift->SUPER::internal_prepare_statement(@_);
}

sub internal_root_parent_node_id {
    return undef;
}

1;
