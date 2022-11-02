# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumEditDAVList;
use strict;
use Bivio::Base 'Model.EditDAVList';

my($_FM) = Bivio::Type->get_instance('FormMode');

sub CSV_COLUMNS {
    return [qw(RealmOwner.name RealmOwner.display_name Forum.forum_id)];
}

sub LIST_CLASS {
    return 'ForumList';
}

sub row_create {
    my($self, $new) = @_;
    $_FM->execute_create($self->get_request);
    $self->new_other('ForumForm')->process({
        %$new,
    });
    return;
}

sub row_update {
    my($self, $new) = @_;
    my($req) = $self->get_request;
    $_FM->execute_edit($req);
    $req->set_realm($new->{'Forum.forum_id'});
    $self->new_other('ForumForm')->process({
        %$new,
    });
    return;
}

1;
