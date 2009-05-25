# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::WikiList;
use strict;
use Bivio::Base 'Model.RealmFileList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WN) = b_use('Type.WikiName');
my($_UNSPECIFIED) = b_use('Type.PrimaryId')->UNSPECIFIED_VALUE;

sub internal_pre_load {
    return '';
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    # {path_info => $type->to_absolute(undef, $public)},
    my($rf) = $self->new_other('RealmFile');
    my($in) = [map(
	$rf->unauth_load({
	    path => $_WN->to_absolute(undef, $_),
	    realm_id => $query->unsafe_get('auth_id'),
	}) ? $rf->get('realm_file_id') : (),
	0, 1,
    )];
    $stmt->where(
	$stmt->IN('RealmFile.folder_id', @$in ? $in : [$_UNSPECIFIED]),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
