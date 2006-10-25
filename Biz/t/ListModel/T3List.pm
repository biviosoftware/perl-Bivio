# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::ListModel::T3List;
use strict;
use base 'Bivio::Biz::Model::NumberedList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	parent_id => ['RealmOwner.realm_id'],
    });
}

1;
