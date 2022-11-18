# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumUserDeleteForm;
use strict;
use Bivio::Base 'Model.RealmUserDeleteForm';


sub execute_ok {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_ok(@_);
#TODO: Need to look at other children such as CalendarEvent
    _down($self)
        unless $self->in_error || !$self->unsafe_get('User.user_id');
    return @res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        other => [
            {
                name => 'realm',
                type => 'ForumName',
                constraint => 'NONE',
            },
        ],
    });
}

sub _down {
    my($self) = @_;
    $self->new_other('Forum')->do_iterate(
        sub {
            $self->execute($self->req, {
                'User.user_id' => $self->get('User.user_id'),
                'RealmUser.realm_id' => shift->get('forum_id'),
            });
            return 1;
        },
        'unauth_iterate_start',
        'forum_id',
        {parent_realm_id => $self->get('RealmUser.realm_id')},
    );
    return;
}

1;
