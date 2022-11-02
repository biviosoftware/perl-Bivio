# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumTreeList;
use strict;
use Bivio::Base 'Model.TreeList';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_R) = b_use('Auth.Role');
my($_GENERAL_ID);

sub PARENT_NODE_ID_FIELD {
    return 'Forum.parent_realm_id';
}

sub internal_default_expand {
    my($self) = @_;
    return [map(
        $_->{is_parent} ? $_->{forum_id} : (),
        values(%{$self->parent_map}),
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
            $self->field_decl(
                [qw(mail_recipient is_subscribed)],
                {
                    type => 'Boolean',
                    constraint => 'NOT_NULL',
                },
            ),
        ],
    });
}

sub internal_is_parent {
    my($self, $row) = @_;
    return $self->parent_map->{$row->{'Forum.forum_id'}}->{is_parent};
}

sub internal_leaf_node_uri {
    return undef;
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($rows) = shift->SUPER::internal_load_rows(@_);
    my($map) = $self->parent_map;
    my($rfid) = $query->unsafe_get('root_forum_id');
    my($ok) = {map(($_ => 1), @{$self->parent_and_children($rfid)})}
        if $rfid;
    return [
        map({
            $_->{mail_recipient}
                = $map->{$_->{'Forum.forum_id'}}->{mail_recipient};
            $_->{is_subscribed} = _is_subscribed($self, $_);
            $_;
        } $ok ? grep($ok->{$_->{'Forum.forum_id'}}, @$rows) : @$rows),
    ];
}

sub internal_parent_id {
    my($self, $id) = @_;
    return $self->parent_map->{$id}->{parent_id};
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $self->[$_IDI] = undef;
    $stmt->where(
        ['RealmUser.role', $_R->get_category_role_group('all_members')],
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

sub internal_root_parent_node_id {
    return $_GENERAL_ID ||= b_use('Auth.Realm')->get_general->get('id');
}

sub parent_and_children {
    my($self, $parent_id) = @_;
    my($map) = $self->parent_map;
    return [
        $map->{$parent_id} ? $parent_id : (),
        map(@{$self->parent_and_children($_)},
            @{$map->{$parent_id}->{children}}),
    ];
}

sub parent_map {
    my($self) = @_;
    # Shares data so don't modify
    return $self->[$_IDI]
        if $self->[$_IDI];
    my($pid_map) =  {};
    my($map) = {
        @{(
            $self->get_request->unsafe_get('Model.UserForumList')
                || $self->new_other('UserForumList')->load_all
        )->map_rows(
            sub {
                my($it) = @_;
                my($id, $pid) = $it->get(
                    qw(RealmUser.realm_id Forum.parent_realm_id));
                push(@{$pid_map->{$pid} ||= []}, $id);
                return ($it->get('RealmUser.realm_id') => {
                    forum_id => $id,
                    roles => $it->get('roles'),
                    mail_recipient => grep(
                        $_->eq_mail_recipient,
                        @{$it->get('roles')},
                    ) ? 1 : 0,
                    parent_id => $pid,
                    name => $it->get('RealmOwner.name'),
                    display_name => $it->get('RealmOwner.display_name'),
                });
            },
        )},
    };
    while (my($k, $v) = each(%$map)) {
        $v->{is_parent} = $pid_map->{$k} ? 1 : 0;
        $v->{children} = $pid_map->{$k} || [];
    }
    return $self->[$_IDI] = $map;
}

sub _is_subscribed {
    my($self, $row) = @_;
    return $self->new_other('UserRealmSubscription')->unauth_load({
        user_id => $row->{'RealmUser.user_id'},
        realm_id => $row->{'Forum.forum_id'},
        is_subscribed => 1,
    });
}

1;
