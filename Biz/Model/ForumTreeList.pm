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
    return [map(
	$_->{is_parent} ? $_->{forum_id} : (),
	values(%{_forum_map($self)}),
    )];
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
    return _forum_map($self)->{$row->{'Forum.forum_id'}}->{is_parent};
}

sub internal_leaf_node_uri {
    return undef;
}

sub internal_load_rows {
    my($self) = @_;
    my($rows) = shift->SUPER::internal_load_rows(@_);
    my($map) = _forum_map($self);
    return [
	map({
	    $_->{mail_recipient} = $map->{
		$_->{'Forum.forum_id'}}->{mail_recipient};
	    $_;
	} @$rows),
    ];
}

sub internal_parent_id {
    my($self, $id) = @_;
    return _forum_map($self)->{$id}->{parent_id};
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $self->[$_IDI] = undef;
    $stmt->where($stmt->EQ('RealmUser.role', [Bivio::Auth::Role->MEMBER]));
    return shift->SUPER::internal_prepare_statement(@_);
}

sub internal_root_parent_node_id {
    return Bivio::Auth::Realm->get_general->get('id');
}

sub _forum_map {
    my($self) = @_;
    return $self->[$_IDI]
	if $self->[$_IDI];
    my($pid) =  {};
    my($map) = {
	@{(
	    $self->get_request->unsafe_get('Model.UserForumList')
		|| $self->new_other('UserForumList')->load_all
        )->map_rows(
	    sub {
		my($it) = @_;
		$pid->{$it->get('Forum.parent_realm_id')}++;
		return (
		    $it->get('RealmUser.realm_id') => {
			forum_id => $it->get('RealmUser.realm_id'),
			mail_recipient => grep(
			    $_->eq_mail_recipient,
			    @{$it->get('roles')},
			) ? 1 : 0,
			parent_id => $it->get('Forum.parent_realm_id'),
		    }
		);
	    },
	)},
    };
    while (my($k, $v) = each(%$map)) {
	$v->{is_parent} = $pid->{$k} ? 1 : 0;
    }
    return $self->[$_IDI] = $map;
}

1;
