# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumTreeListForm;
use strict;
use Bivio::Base 'Biz.ListFormModel';


sub execute_empty_row {
    my($self) = @_;
    $self->internal_put_field(is_subscribed => _is_subscribed($self));
    return;
}

sub execute_ok_row {
    my($self) = @_;
    return if _is_subscribed($self) eq $self->get('is_subscribed');
    $self->new_other('UserRealmSubscription')->unauth_create_or_update({
        realm_id => $self->get_list_model->get('Forum.forum_id'),
        user_id => $self->get_list_model->get_query->get('auth_id'),
        is_subscribed => $self->get('is_subscribed'),
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'ForumTreeList',
        visible => [
            {
                name => 'is_subscribed',
                type => 'Boolean',
                constraint => 'NONE',
                in_list => 1,
            },
        ],
    });
}

sub _is_subscribed {
    return shift->get_list_model->get('is_subscribed');
}

1;
