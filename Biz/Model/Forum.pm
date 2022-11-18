# Copyright (c) 2005-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Forum;
use strict;
use Bivio::Base 'Model.RealmOwnerBase';

my($_PI) = b_use('Type.PrimaryId');
my($_ROOT_ID);

sub ROOT_FORUM_PARENT_ID {
    return $_ROOT_ID ||= b_use('Auth.Realm')->get_general->get('id');
}

sub create {
    my($self, $values) = @_;
    return $self->SUPER::create({
        parent_realm_id => $self->ROOT_FORUM_PARENT_ID,
        require_otp => 0,
        %$values,
    });
}

sub create_realm {
    my($self, $forum, $realm_owner, $admin_id) = @_;
    my(@res) = $self->create({
        %$forum,
        parent_realm_id => $self->req('auth_id'),
    })->SUPER::create_realm($realm_owner);
    $self->req->with_realm($self->get('forum_id'), sub {
        $self->new_other('RealmFile')->init_realm;
        return;
    });
    $self->new_other('ForumUserAddForm')->copy_admins(
        $self->get('forum_id'),
        $self->get('require_otp')
            ? $self->get_request->get('auth_user_id')
            : $admin_id);
#TODO: remove this hack
    # Reset state after ForumUserAddForm messed it up
    return map($_->put_on_request, @res);
}

sub get_parent_id {
    my($self) = @_;
    $self->load
        unless $self->is_loaded;
    return $self->get('parent_realm_id');
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
    return $_PI->is_equal($self->get('parent_realm_id'), $self->ROOT_FORUM_PARENT_ID);
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

    # don't allow non OTP people to be in an OTP forum (su excepted)
    if ($values->{require_otp}
        && Bivio::Type->compare($values->{require_otp},
            $self->get('require_otp')) != 0) {
        Bivio::Biz::ListModel->new_anonymous({
            primary_key => [qw(
                RealmUser.user_id
                RealmUser.realm_id
                RealmUser.role
            )],
            other => [
                ['RealmUser.realm_id', [$self->get('forum_id')]],
                [qw(RealmUser.user_id RealmOwner.realm_id)],
                'RealmOwner.password',
            ],
        }, $self->req)->do_iterate(
            sub {
                my($list) = @_;
                return 1 if Bivio::Type->get_instance('Password')->is_otp(
                    $list->get('RealmOwner.password'))
                    || $self->req->is_super_user(
                        $list->get('RealmUser.user_id'));
                $list->get_model('RealmUser')->delete;
                return 1;
            });
    }
    return shift->SUPER::update(@_);
}

sub _delete_children {
    my($self) = @_;
    my($urs) = $self->new_other('UserRealmSubscription');
    $self->new_other('Forum')->do_iterate(
        sub {
            my($f) = @_;
            _delete_subscriptions($self, $urs, $f->get('forum_id'));
            $f->unauth_cascade_delete;
            return 1;
        },
        'unauth_iterate_start',
        'forum_id',
        {parent_realm_id => $self->get('forum_id')},
    );
    _delete_subscriptions($self, $urs, $self->get('forum_id'));
    return;
}

sub _delete_subscriptions {
    my($self, $model, $realm_id) = @_;
    $model->unauth_delete_by_realm_id('realm_id', $realm_id);
    return;
}

1;
