# Copyright (c) 2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmDAG;
use strict;
use Bivio::Base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'realm_dag_t',
        columns => {
            parent_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            child_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
        },
        other => [
            [qw(parent_id RealmOwner.realm_id)],
            [qw(child_id RealmOwner_2.realm_id)],
        ],
    });
}

1;
