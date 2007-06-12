# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::PublicRealmDAVList;
use strict;
use Bivio::Base 'Model.RealmDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	other => [
	    ['RealmOwner.realm_id', 'RealmFile.realm_id'],
	    ['RealmFile.path_lc',
	        [lc($self->use('Type.FilePath')->PUBLIC_FOLDER_ROOT)]],
	],
    });
}

1;
