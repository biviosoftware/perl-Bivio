# Copyright (c) 2005 bivio Software.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Forum;
use strict;
use base ('Bivio::Biz::PropertyModel');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    my($self, $values) = @_;
    $values->{name_lc} = lc($values->{name});
    return shift->SUPER::create(@_);
}

sub create_realm {
    my($self, $forum, $display_name, $admin_id) = @_;
    my($req) = $self->get_request;
    $self->new_other('RealmOwner')->create({
	display_name => $display_name,
	realm_type => Bivio::Auth::RealmType->FORUM,
	realm_id => $self->create({
	    realm_id => $req->get('auth_id'),
	    %$forum,
	})->get('forum_id'),
    })->get('realm_id');
    $self->new_other('RealmUser')->create({
	realm_id => $self->get('forum_id'),
	user_id => $admin_id,
	role => Bivio::Auth::Role->ADMINISTRATOR,
    });
    return $self;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'forum_t',
	columns => {
            forum_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    realm_id => ['RealmOwner.realm_id', 'NONE'],
            parent_forum_id => ['RealmOwner.realm_id', 'NONE'],
	    name => ['Name', 'NOT_NULL'],
	    name_lc => ['Name', 'NOT_NULL'],
        },
	auth_id => 'forum_id',
    });
}

sub update {
    my($self, $values) = @_;
    $values->{name_lc} = lc($values->{name})
	if defined($values->{name});
    return shift->SUPER::update(@_);
}

1;
