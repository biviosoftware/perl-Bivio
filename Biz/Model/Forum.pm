# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Forum;
use strict;
use base ('Bivio::Biz::PropertyModel');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    my($self, $values) = @_;
    return $self->SUPER::create({
	want_reply_to => 1,
	is_public_email => 0,
	parent_realm_id => Bivio::Auth::Realm->get_general->get('id'),
	require_otp => 0,
	%$values,
    });
}

sub create_realm {
    my($self, $forum, $realm_owner, $admin_user_id) = @_;
    my($ro) = $self->new_other('RealmOwner')->create({
	%$realm_owner,
	realm_type => Bivio::Auth::RealmType->FORUM,
	realm_id => $self->create({
	    want_reply_to => 0,
	    is_public_email => 0,
	    %$forum,
	    parent_realm_id => $self->req('auth_id'),
	})->get('forum_id'),
    });
    $self->req->with_realm($self->get('forum_id'), sub {
        $self->new_other('RealmFile')->init_realm;
	return;
    });
    $self->new_other('ForumUserAddForm')->copy_admins(
	$self->get('forum_id'), $admin_user_id);
#TODO: remove this hack
    # Reset state after ForumUserAddForm messed it up
    $self->put_on_request;
    $ro->put_on_request;
    return ($self, $ro);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'forum_t',
	columns => {
            forum_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    # Don't link
	    parent_realm_id => ['PrimaryId', 'NOT_NULL'],
	    want_reply_to => ['Boolean', 'NOT_NULL'],
	    is_public_email => ['Boolean', 'NOT_NULL'],
	    require_otp => ['Boolean', 'NOT_NULL'],
        },
	other => [
            [qw(forum_id RealmOwner.realm_id)],
	],
	auth_id => 'forum_id',
    });
}

sub is_leaf {
    my($self) = @_;
    return @{$self->new_other('Forum')->map_iterate(
	sub {
	    return 1;
	}, 'unauth_iterate_start', 'forum_id', {
	    parent_realm_id => $self->get('forum_id'),
	})} ? 0 : 1;
}

sub is_root {
    my($self) = @_;
    return $self->get('parent_realm_id')
	== Bivio::Auth::RealmType->GENERAL->as_int ? 1 : 0;
}

sub unauth_cascade_delete {
    my($self) = @_;
    $self->req->with_realm($self->get('forum_id'), sub {
	_delete_children($self);
	$self->get_model('RealmOwner')->cascade_delete;
	return;
    });
    $self->req->set_realm(undef)
	if $self->req('auth_id') eq $self->get('forum_id');
    return;
}

sub update {
    my($self, $values) = @_;
    $values->{name_lc} = lc($values->{name})
	if defined($values->{name});
    return shift->SUPER::update(@_);
}

sub _delete_children {
    my($self) = @_;
    $self->new_other('Forum')->do_iterate(
	sub {
	    shift->unauth_cascade_delete;
	    return 1;
	},
        'unauth_iterate_start',
        'forum_id',
	{parent_realm_id => $self->get('forum_id')},
    );
    return;
}

1;
