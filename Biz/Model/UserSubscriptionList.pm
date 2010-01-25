# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserSubscriptionList;
use strict;
use Bivio::Base 'Model.AuthUserGroupList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('Auth.Role');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        order_by => [qw(
	    RealmOwner.display_name
        )],
    });
}

sub internal_qualifying_roles {
    return [map($_R->$_(), qw(MEMBER ACCOUNTANT ADMINISTRATOR))];
}

sub load_all_qualified_realms {
#TODO: this isn't quite the right task to ask for...
    return shift->load_all_for_task('FORUM_MAIL_THREAD_ROOT_LIST');
}

1;
