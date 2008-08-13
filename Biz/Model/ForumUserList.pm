# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumUserList;
use strict;
use base 'Bivio::Biz::Model::RoleBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_NUM_ROLES) = 3;
#TODO: Need to make this times number of roles
my($_PAGE_SIZE) = Bivio::Type->get_instance('PageSize')->get_default
    * $_NUM_ROLES;

sub LOAD_ALL_SIZE {
    return 1000 * $_NUM_ROLES;
}

sub PAGE_SIZE {
    return $_PAGE_SIZE;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 0,
	primary_key => [[qw(RealmUser.user_id Email.realm_id User.user_id)]],
	order_by => [
	    'Email.email',
	    'RealmUser.role',
	],
	other => [
	    $self->local_field(
		[qw(administrator mail_recipient file_writer)],
		Boolean => 'NOT_NULL',
	    ),
	    [
		'Email.location',
		[$self->get_instance('Email')->DEFAULT_LOCATION],
	    ],
	],
	auth_id => ['RealmUser.realm_id'],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    foreach my $x (qw(administrator mail_recipient file_writer)) {
	$row->{$x} = grep($_->equals_by_name($x), @{$row->{roles}}) ? 1 : 0;
    }
    return 1;
}

1;
