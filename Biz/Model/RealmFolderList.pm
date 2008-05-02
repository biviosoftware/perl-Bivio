# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFolderList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	can_iterate => 1,
        primary_key => ['RealmFile.realm_file_id'],
        auth_id => ['RealmFile.realm_id'],
	order_by => [qw(
	    RealmFile.path_lc
	)],
	other => [
	    'RealmFile.path',
	    ['RealmFile.is_folder', [1]],
	],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    my($mf) = lc($self->get_instance('RealmFile')->MAIL_FOLDER);
    $stmt->where(@{$stmt->map_invoke(NOT_LIKE => [
	map((lc($_), lc($_) . '/%'), $_FP->MAIL_FOLDER, $_FP->VERSIONS_FOLDER),
    ], ['RealmFile.path_lc'])});
    return shift->SUPER::internal_prepare_statement(@_);
}


1;
