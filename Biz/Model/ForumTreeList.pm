# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumTreeList;
use strict;
use base 'Bivio::Biz::Model::TreeList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub PARENT_NODE_ID_FIELD {
    return 'Forum.parent_realm_id';
}

sub internal_default_expand {
    my($self) = @_;
    return _map_user_forums(
	$self,
	sub {return shift->get('RealmUser.realm_id')},
    );
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
        primary_key =>
	    [[qw(Forum.forum_id RealmOwner.realm_id RealmUser.realm_id)]],
        auth_id => 'RealmUser.user_id',
	order_by => [qw(
	    RealmOwner.display_name
	)],
	other => [
	    qw(
	       RealmOwner.name
	       RealmUser.role
	       Forum.parent_realm_id
	    ),
	    {
		name => 'mail_recipient',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_is_parent {
    my($self, $row) = @_;
    return grep($_ eq $row->{'Forum.forum_id'}, @{$self->[$_IDI]}) ? 1 : 0;
}

sub internal_leaf_node_uri {
    return undef;
}

sub internal_load_rows {
    my($self) = @_;
    $self->[$_IDI] = _map_user_forums(
	$self,
	sub {shift->get('Forum.parent_realm_id')},
    );
    my($rows) = shift->SUPER::internal_load_rows(@_);
    my($mr) = _map_user_forums(
	$self,
	sub {
	    my($it) = @_;
	    return grep($_->eq_mail_recipient, @{$it->get('roles')})
		? $it->get('RealmUser.realm_id') : ();
	},
    );
    return [
	map({
	    my($fid) = $_->{'Forum.forum_id'};
	    $_->{mail_recipient} = grep($_ eq $fid, @$mr) ? 1 : 0;
	    $_;
	} grep($_->{'RealmUser.role'}->eq_member, @$rows)),
    ];
}

sub internal_parent_id {
    my($self, $id) = @_;
    return $self->new_other('Forum')->load({forum_id => $id})
	->get('parent_realm_id');
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where($stmt->EQ('RealmUser.role', [Bivio::Auth::Role->MEMBER]));
    return shift->SUPER::internal_prepare_statement(@_);
}

sub internal_root_parent_node_id {
    return Bivio::Auth::Realm->get_general->get('id');
}

sub _map_user_forums {
    my($self) = shift;
    return (
	$self->get_request->unsafe_get('Model.UserForumList')
	    || $self->new_other('UserForumList')->load_all
    )->map_rows(@_);
}

1;
