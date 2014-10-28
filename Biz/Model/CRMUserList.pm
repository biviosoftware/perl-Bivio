# Copyright (c) 2010 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CRMUserList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_R) = b_use('Auth.Role');
my($_U) = b_use('Model.User');
my($_DEFAULT_LOCATION) = b_use('Model.Email')->DEFAULT_LOCATION;

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        can_iterate => 1,
	primary_key => [
	    [qw(
	        RealmUser.user_id
		User.user_id
		RealmOwner.realm_id
		Email.realm_id
	    )],
	],
	order_by => [qw(
	    User.last_name_sort
	    User.first_name_sort
	    User.middle_name_sort
	)],
	other => [
	    qw(
	        User.last_name
		User.first_name
		User.middle_name
		Email.email
	    ),
	    ['Email.location', [$_DEFAULT_LOCATION]],
	    {
		name => 'display_name',
		type => 'DisplayName',
		constraint => 'NOT_NULL',
	    },
	    ['RealmUser.role', [$_R->MAIL_RECIPIENT]],
        ],
	auth_id => ['RealmUser.realm_id'],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{display_name} = $_U->concat_last_first_middle(
	@$row{qw(User.last_name User.first_name User.middle_name)},
    );
    return 1;
}

1;
