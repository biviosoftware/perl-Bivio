# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmEmailList;
use strict;
use Bivio::Base 'Model.RealmUserList';

my($_E) = Bivio::Biz::Model->get_instance('Email')->get_field_type('email');

sub get_recipients {
    my($self, $iterate_handler) = @_;
    my($method) = 'map_' . ($self->is_loaded ? 'rows' : 'iterate');
    my($t) = $self->get_field_type('Email.email');
    return $self->$method(sub {
        my($e) = $self->get('Email.email');
	return $t->is_ignore($e) || !$self->internal_is_subscribed
	    ? () : $iterate_handler
	    ? $iterate_handler->($self) : $e;
    });
}

sub internal_get_roles {
    return [Bivio::Auth::Role->MAIL_RECIPIENT];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info(
	$self->field_decl_exclude(
	    'RealmUser.role',
	    $self->SUPER::internal_initialize,
	),
	{
	    order_by => [qw(
		Email.email
	    )],
	    other => [
		'Email.location',
		'UserRealmSubscription.is_subscribed',
		[qw(RealmUser.user_id Email.realm_id(+))],
		[qw(RealmUser.user_id UserRealmSubscription.user_id(+))],
		[qw(RealmUser.realm_id UserRealmSubscription.realm_id(+))],
		{
		    name => 'RealmUser.role',
		    in_select => 0,
		},
	    ],
	    group_by => [qw(
		Email.email
		Email.location
		RealmOwner.display_name
		RealmOwner.name
		RealmUser.realm_id
		RealmUser.user_id
		UserRealmSubscription.is_subscribed
	    )],
	},
    );
}

sub internal_is_subscribed {
    return shift->get('UserRealmSubscription.is_subscribed');
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return $_E->is_ignore($row->{'Email.email'}) ? 0 : 1;
}

sub is_ignore {
    my($self) = @_;
    return $self->get_field_type('Email.email')
	->is_ignore($self->get('Email.email'));
}

1;
