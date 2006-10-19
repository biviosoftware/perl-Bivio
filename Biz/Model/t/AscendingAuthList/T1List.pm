# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::t::AscendingAuthList::T1List;
use strict;
use base 'Bivio::Biz::Model::AscendingAuthList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub AUTH_ID_FIELD {
    return 'RealmOwner.realm_id';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        order_by => [
	    'RealmOwner.name',
	],
    });
}

1;
