# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumDeleteForm;
use strict;
use Bivio::Base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    $self->new_other('Forum')->unauth_load_or_die({
	forum_id => $self->new_other('RealmOwner')
	    ->unauth_load_or_die({name => $self->get('RealmOwner.name')})
	    ->get('realm_id'),
    })->unauth_cascade_delete;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'RealmOwner.name',
	],
    });
}

1;
