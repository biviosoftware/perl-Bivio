# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumEditDAVList;
use strict;
use base 'Bivio::Biz::Model::EditDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FM) = Bivio::Type->get_instance('FormMode');

sub CSV_COLUMNS {
    return [qw(RealmOwner.name RealmOwner.display_name Forum.want_reply_to admin_only_forum_email system_user_forum_email public_forum_email Forum.require_otp Forum.forum_id)];
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
