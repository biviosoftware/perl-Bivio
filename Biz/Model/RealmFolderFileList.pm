# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFolderFileList;
use strict;
use Bivio::Base 'Model.RealmFileTreeList';


sub PAGE_SIZE {
    return 200;
}

sub get_folder_path {
    my($self) = @_;
    return $self->new_other('RealmFile')->load({
	realm_file_id => $self->internal_root_parent_node_id,
    })->get('path');
}

sub internal_initialize {
    my($self) = @_;
    my($ii) = $self->merge_initialize_info($self->SUPER::internal_initialize, {
	parent_id => 'RealmFile.folder_id',
	other => [
	    ['RealmFile.is_folder', [0]],
	],
    });
    delete($ii->{other_query_keys});
    return $ii;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $self->new_other('RealmFileList')->prepare_statement_for_access_mode($stmt,
        b_use('Type.DocletFileName'));
    return shift->SUPER::internal_prepare_statement(@_);
}

sub internal_root_parent_node_id {
    my($self) = @_;
    return $self->get_query->get('parent_id');
}

1;
