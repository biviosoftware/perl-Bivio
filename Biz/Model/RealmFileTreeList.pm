# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileTreeList;
use strict;
use Bivio::Base 'Model.TreeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_FP) = b_use('Type.FilePath');
my($_RF) = b_use('Model.RealmFile');
my($_RTK) = b_use('Type.RowTagKey');
my($_TLN) = b_use('Type.TreeListNode');
my($_DEFAULT_LOCATION) = b_use('Model.Email')->DEFAULT_LOCATION;
my($_MAIL_FOLDER) = lc($_FP->MAIL_FOLDER);
my($_VERSIONS_FOLDER_RE) =  qr{^$_FP->VERSIONS_FOLDER(?:/:$)}ios;

sub LOAD_ALL_SIZE {
    return 5000;
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
	order_by => [qw(
	    RealmFile.path_lc
            RealmFileLock.modified_date_time
	    RealmFile.modified_date_time
            Email_2.email
            RealmOwner_2.display_name
	    Email_3.email
	    RealmOwner_3.display_name
	)],
	other => [
	    'RealmOwner.name',
	    'RealmFile.path',
	    'RealmFile.folder_id',
	    'RealmFile.is_read_only',
            [qw(RealmFile.user_id Email_2.realm_id RealmOwner_2.realm_id)],
	    'RealmFile.is_folder',
	    'RealmFileLock.comment',
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
    return $self->get_request->format_uri({
	task_id => $self->get_request->get('task')->get_attr_as_id('next'),
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
    $row->{node_state} = $_TLN->LOCKED_LEAF_NODE
	if $row->{'RealmFileLock.modified_date_time'};
    if ($self->internal_is_parent($row) && $self->internal_is_empty($row)) {
	$row->{node_state} = $_TLN->NODE_EMPTY;
	$row->{node_uri} = undef;
    }
    $row->{base_name} = $row->{'RealmFile.path'} eq '/' ? '/'
	: Bivio::Type::FileName->get_tail($row->{'RealmFile.path'});
    $row->{content_length} = $row->{'RealmFile.is_folder'}
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
    $stmt->from($stmt->LEFT_JOIN_ON(qw(RealmFile RealmFileLock), [
	[qw(RealmFile.realm_file_id RealmFileLock.realm_file_id)],
	['RealmFileLock.comment', [undef]],
    ]));
    $stmt->from($stmt->LEFT_JOIN_ON(qw(RealmFileLock RealmOwner_3), [
	[qw(RealmFileLock.user_id RealmOwner_3.realm_id)],
    ]));
    $stmt->from($stmt->LEFT_JOIN_ON(qw(RealmFileLock Email_3), [
	[qw(RealmFileLock.user_id Email_3.realm_id)],
	['Email_3.location', [$_DEFAULT_LOCATION]],
    ]));
    # /Mail is probably large so we'll ignore it
    # dot-files are uninteresting, so we'll ignore them.
    # All are available via DAV
    $stmt->where(@{$stmt->map_invoke(
	NOT_LIKE => ['/.%', '%/.%', $_MAIL_FOLDER . '/%', $_MAIL_FOLDER],
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
    my($self) = @_;
    return $self->get('RealmFile.path') =~ $_VERSIONS_FOLDER_RE ? 1 : 0;
}

sub is_file {
    return shift->get('RealmFile.is_folder') ? 0 : 1;
}

sub is_locked {
    return shift->get('RealmFileLock.modified_date_time') ? 1 : 0;
}

sub parse_query_from_request {
    my($self) = @_;
    my($query) = shift->SUPER::parse_query_from_request(@_);
    if (my $p = $self->req->unsafe_get('path_info')) {
	$query->put(path_info => $_RF->parse_path($p));
    }
    return $query;
}

1;
