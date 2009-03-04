# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileMD5List;
use strict;
use Bivio::Base 'Biz.ListModel';
use Digest::MD5 ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RF) = b_use('Model.RealmFile');
my($_FP) = b_use('Type.FilePath');
my($_IDI) = __PACKAGE__->instance_data_index;

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        auth_id => 'RealmFile.realm_id',
        primary_key => ['RealmFile.realm_file_id'],
	order_by => [qw(
	    RealmFile.path
	)],
	$self->field_decl(other => [[qw(md5 Name)]]),
	other_query_keys => [qw(path_info)],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    my($md5) = Digest::MD5->new;
    $md5->addfile($_RF->get_handle($self, 'RealmFile.', $row));
    $row->{md5} = $md5->b64digest;
    substr($row->{'RealmFile.path'}, 0, $self->[$_IDI]) = '';
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($p) = $_RF->parse_path($query->unsafe_get('path_info'), $self);
    $p = $_FP->join(lc($p), '%');
    $self->[$_IDI] = length($p) - 1;
    $stmt->where(
	['RealmFile.is_folder', [0]],
	$p eq '/' ? $stmt->NOT_LIKE(
	    'RealmFile.path_lc', $_FP->join(lc($_FP->VERSIONS_FOLDER), '%'),
	) : $stmt->LIKE('RealmFile.path_lc', $p),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
