# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumUserAddForm;
use strict;
use Bivio::Base 'Model.RealmUserAddForm';

my($_R) = b_use('Auth.Role');

sub execute_ok {
    my($self) = @_;
    $self->new_other('RealmUser')->delete_main_roles(
        $self->internal_realm_id,
        $self->internal_user_id,
    );
    my(@res) = shift->SUPER::execute_ok(@_);
    return @res
        if $self->in_error;

    if (_forum($self)->get('require_otp')) {

        unless ($self->new_other('RealmOwner')->unauth_load_or_die({
            realm_id => $self->get('User.user_id'),
        })->require_otp) {
            $self->internal_put_error('Email.email' => 'FORUM_FOR_OTP_USERS');
            return @res;
        }
    }
    $self->internal_execute_children
        if $self->unsafe_get('administrator');
    $self->internal_execute_parent;
    return @res;
}

sub internal_execute_children {
    my($self) = @_;
    if ($self->unsafe_get('administrator')) {
        foreach my $cid (@{$self->new_other('Forum')->map_iterate(
            sub {
                #TODO: Need to look at other children such as CalendarEvent
                my($child) = @_;
                return $self->new_other('RealmUser')->unauth_load({
                    realm_id => $child->get('forum_id'),
                    user_id => $self->get('User.user_id'),
                    role => $_R->ADMINISTRATOR,
                }) ? () : $child->get('forum_id');
            },
            'unauth_iterate_start',
            'forum_id',
            {
                parent_realm_id => $self->get('RealmUser.realm_id')},
        )}) {
            $self->execute($self->get_request, {
                %{$self->get_shallow_copy},
                'RealmUser.realm_id' => $cid,
            });
        }
    }
    return;
}

sub internal_execute_parent {
    my($self) = @_;
    my($f) = _forum($self);
    $self->execute($self->get_request, {
        'User.user_id' => $self->get('User.user_id'),
        # Exclude ADMINISTRATOR (see above)
        administrator => 0,
        file_writer => 0,
        'RealmUser.realm_id' => $f->get('forum_id'),
    }) if $f->unauth_load({forum_id => $f->get('parent_realm_id')})
        && !$self->new_other('RealmUser')->unauth_rows_exist({
            realm_id => $f->get('forum_id'),
            user_id => $self->get('User.user_id'),
        });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        other => [
            {
                name => 'realm',
                type => 'ForumName',
                constraint => 'NONE',
            },
        ],
    });
}

sub _forum {
    my($self) = @_;
    return $self->new_other('Forum')->unauth_load_or_die({
        forum_id => $self->get('RealmUser.realm_id'),
    });
}

1;
