# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileTreeList;
use strict;
use Bivio::Base 'Model.TreeList';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_FN) = b_use('Type.FileName');
my($_FP) = b_use('Type.FilePath');
my($_RF) = b_use('Model.RealmFile');
my($_RFL) = b_use('Model.RealmFileLock');
my($_RFVL) = b_use('Model.RealmFileVersionsList');
my($_TLN) = b_use('Type.TreeListNode');
my($_NOT_LIKE) = [
    '/.%',
    '%/.%',
    map(
        ($_, $_ . '/%'),
        lc($_FP->MAIL_FOLDER),
        lc($_FP->to_public($_FP->MAIL_FOLDER)),
    ),
];
my($_VERSIONS_FOLDER) = $_FP->VERSIONS_FOLDER;
my($_VERSIONS_FOLDER_RE) =  qr{^$_VERSIONS_FOLDER/}ios;
my($_DEFAULT_LOCATION) = b_use('Model.Email')->DEFAULT_LOCATION;
my($_LOCK) = $_RFL->if_enabled;

sub LOAD_ALL_SIZE {
    return 5000;
}

sub MAX_FILES_PER_FOLDER {
    return 200;
}

sub PARENT_NODE_ID_FIELD {
    return 'RealmFile.folder_id';
}

sub can_write {
    return shift->[$_IDI]->{can_write};
}

sub internal_default_expand {
    return [shift->new_other('RealmFile')->path_info_to_id('/')];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        primary_key => ['RealmFile.realm_file_id'],
        auth_id => ['RealmFile.realm_id', 'RealmOwner.realm_id'],
        order_by => [
            'RealmFile.path_lc',
            'RealmFile.modified_date_time',
            'Email_2.email',
            'RealmOwner_2.display_name',
            _lock(qw(
                Email_3.email
                RealmOwner_3.display_name
            )),
        ],
        other => [
            _lock('RealmFileLock.modified_date_time'),
            'RealmOwner.name',
            'RealmFile.path',
            'RealmFile.folder_id',
            'RealmFile.is_read_only',
            [qw(RealmFile.user_id Email_2.realm_id RealmOwner_2.realm_id)],
            'RealmFile.is_folder',
            # Needed for is_locked
            _lock('RealmFileLock.comment'),
            {
                name => 'is_empty',
                type => 'Boolean',
                constraint => 'NONE',
            },
            {
                name => 'base_name',
                type => 'FilePath',
                constraint => 'NONE',
            },
            {
                name => 'content_length',
                type => 'String',
                constraint => 'NONE',
            },
            {
                name => 'is_max_files_per_folder',
                type => 'Boolean',
                constraint => 'NONE',
            },
            ['Email_2.location', [$_DEFAULT_LOCATION]],
        ],
        other_query_keys => [qw(path_info)],
    });
}

sub internal_is_empty {
    my($self, $row) = @_;
    unless ($row->{'is_empty'}) {
        my($rf) = $self->new_other('RealmFile')->load({
            path => $row->{'RealmFile.path'},
        });
        $row->{'is_empty'} = $rf->is_empty;
    }
    return $row->{'is_empty'};
}

sub internal_is_parent {
    my(undef, $row) = @_;
    return $row->{'RealmFile.is_folder'};
}

sub internal_leaf_node_uri {
    my($self, $row) = @_;
    return $self->req->format_uri({
        task_id => $self->req('task')->get_attr_as_id('next'),
        path_info => $row->{'RealmFile.path'},
        query => undef,
    });
}

sub internal_parent_id {
    my($self, $id) = @_;
    return $self->new_other('RealmFile')
        ->load({realm_file_id => $id})
        ->get('folder_id');
}

sub internal_parent_node_uri_query_params {
    return {path_info => undef};
}

sub internal_parent_node_uri_uri_params {
    return {path_info => shift->get_query->unsafe_get('path_info')};
}

sub internal_post_load_row {
    my($self, $row) = @_;
    my($count_by_folder) = shift->[$_IDI]->{count_by_folder} ||= {};
    $row->{is_max_files_per_folder} = 0;

    if ($row->{'RealmFile.folder_id'} && ! $row->{'RealmFile.is_folder'}) {
        my($count) =
            ($count_by_folder->{$row->{'RealmFile.folder_id'}} ||= 0)++;

        if ($count == $self->MAX_FILES_PER_FOLDER) {
            $row->{is_max_files_per_folder} = 1;
            $row->{base_name} = undef;
            $row->{'RealmFile.modified_date_time'} = undef;
            $row->{'RealmOwner_2.display_name'} = undef;
            $row->{node_uri} = $self->req->format_uri({
                task_id => 'FORUM_FOLDER_FILE_LIST',
                query => {
                    'ListQuery.parent_id' => $row->{'RealmFile.folder_id'},
                },
            });
        }
        else {
            return 0 if $count >= $self->MAX_FILES_PER_FOLDER;
        }
    }
    $row->{node_state} = $_TLN->LOCKED_LEAF_NODE
        if $row->{'RealmFileLock.modified_date_time'};
    if ($self->internal_is_parent($row) && $self->internal_is_empty($row)) {
        $row->{node_state} = $_TLN->NODE_EMPTY;
        $row->{node_uri} = undef;
    }
    $row->{base_name} = $row->{'RealmFile.path'} eq '/' ? '/'
        : $_FN->get_tail($row->{'RealmFile.path'});
    $row->{content_length} = $row->{'RealmFile.is_folder'} || $row->{is_max_files_per_folder}
        ? undef
        : $_RF->get_content_length(undef, 'RealmFile.', $row);
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $self->[$_IDI] = {
        can_write => $self->req->can_user_execute_task(
            $self->req('task')->get_attr_as_task('write_task')),
    };
    $_RFVL->prepare_statement_for_realm_file_lock($stmt);
    $stmt->where(@{$stmt->map_invoke(
        NOT_LIKE => $_NOT_LIKE,
        ['RealmFile.path_lc'],
    )});
    return shift->SUPER::internal_prepare_statement(@_);
}

sub internal_root_parent_node_id {
    my($self) = @_;
    return undef
        unless my $p = $self->get_query->unsafe_get('path_info');
    return $self->new_other('RealmFile')->path_info_to_id($p);
}

sub is_archive {
    my($self, $path) = @_;
    return ($path || $self->get('RealmFile.path')) =~ $_VERSIONS_FOLDER_RE ? 1 : 0;
}

sub is_file {
    return shift->get('RealmFile.is_folder') ? 0 : 1;
}

sub is_locked {
    return $_RFL->is_locked(shift, 'RealmFileLock.');
}

sub parse_query_from_request {
    my($self) = @_;
    my($query) = shift->SUPER::parse_query_from_request(@_);
    if (my $p = $self->req->unsafe_get('path_info')) {
        $query->put(path_info => $_RF->parse_path($p));
    }
    return $query;
}

sub _lock {
    return $_LOCK ? @_ : ();
}

1;
