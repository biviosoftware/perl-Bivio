# Copyright (c) 2006-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::t::AscendingAuthBaseList::T1List;
use strict;
use Bivio::Base 'Model.AscendingAuthBaseList';


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
