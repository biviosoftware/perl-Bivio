# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumEditDAVList;
use strict;
use base 'Bivio::Biz::Model::EditDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CSV_COLUMNS {
    return [qw(RealmOwner.name RealmOwner.display_name RealmOwner.realm_id)];
}

sub LIST_CLASS {
    return 'ForumList';
}

sub add_row {
    my($self, $new) = @_;
    $self->new_other('ForumForm')->process({
	is_public => 0,
	%$new,
    });
    return;
}

1;
