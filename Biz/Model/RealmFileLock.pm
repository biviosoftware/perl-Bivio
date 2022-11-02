# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileLock;
use strict;
use Bivio::Base 'Biz.PropertyModel';

b_use('IO.Config')->register(my $_CFG = {
    enable => 1,
});

sub create {
    my($self, $values) = @_;
    _assert_enabled($self);
    $values->{modified_date_time} ||= $self->use('Type.DateTime')->now;
    $values->{realm_id} ||= $self->req('auth_id');
    $values->{user_id} ||= $self->req('auth_user_id');
    return shift->SUPER::create(@_);
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub if_enabled {
    return shift->if_then_else($_CFG->{enable}, @_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'realm_file_lock_t',
        columns => {
            realm_file_lock_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_file_id => ['RealmFile.realm_file_id', 'NOT_NULL'],
            realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
            # Don't cascade when User.user_id is deleted
            user_id =>  ['PrimaryId', 'NOT_NULL'],
            modified_date_time => ['DateTime', 'NOT_NULL'],
            comment => ['Text', 'NONE'],
        },
        other => [
            [qw(realm_file_id RealmFile.realm_file_id)],
            [qw(realm_id RealmOwner.realm_id)],
            [qw(user_id User.user_id)],
        ],
        auth_id => 'realm_id',
    });
}

sub is_locked {
    my($self) = @_;
    return 0
        unless $self->if_enabled;
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    return $proto->boolean(
        $model->get($model_prefix . 'modified_date_time')
        && !defined($model->get($model_prefix . 'comment')),
    );
}

sub _assert_enabled {
    my($self) = @_;
    return $self->if_enabled($self, sub {b_die('RealmFileLock not enabled')});
}

1;
