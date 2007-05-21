# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Forum;
use strict;
use base ('Bivio::Biz::PropertyModel');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    my($self, $values) = @_;
    $values->{want_reply_to} = 1
	unless defined($values->{want_reply_to});
    $values->{is_public_email} = 0
	unless defined($values->{is_public_email});
    $values->{parent_realm_id} = Bivio::Auth::Realm->get_general->get('id'),
	unless defined($values->{parent_realm_id});
    return shift->SUPER::create(@_);
}

sub create_realm {
    my($self, $forum, $realm_owner, $admin_id) = @_;
    $forum->{want_reply_to} ||= 0;
    $forum->{is_public_email} ||= 0;
    my($req) = $self->get_request;
    my($ro) = $self->new_other('RealmOwner')->create({
	%$realm_owner,
	realm_type => Bivio::Auth::RealmType->FORUM,
	realm_id => $self->create({
	    %$forum,
	    parent_realm_id => $req->get('auth_id'),
	})->get('forum_id'),
    });
    $self->get_request->with_realm($ro, sub {
        $self->new_other('RealmFile')->init_realm;
	return;
    });
    $self->new_other('ForumUserAddForm')->copy_admins(
	$ro->get('realm_id'), $admin_id);
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
        },
	auth_id => 'forum_id',
    });
}

sub is_root {
    my($self) = @_;
    return $self->get('parent_realm_id') == Bivio::Auth::RealmType->GENERAL->as_int ? 1 : 0;
}

sub unauth_cascade_delete {
    my($self) = @_;
    my($req) = $self->get_request;
    my($ro) = $self->new_other('RealmOwner')
	->unauth_load_or_die({realm_id => $self->get('forum_id')});
    $req->with_realm($self->get('forum_id'), sub {
	_delete_children($self);
        $ro->cascade_delete;
	return;
    });
    $req->set_realm(undef)
	if $req->get('auth_id') eq $self->get('forum_id');
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
