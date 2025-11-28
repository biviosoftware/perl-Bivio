# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EmailVerify;
use strict;
use Bivio::Base 'Model.LocationBase';

# TODO: could change to be a UserAccessCode

my($_DT) = b_use('Type.DateTime');
my($_EVK) = b_use('Type.EmailVerifyKey');
my($_ULF) = b_use('Model.UserLoginForm');

sub EMAIL_KEY {
    return 'e';
}

sub VERIFY_KEY {
    return 'x';
}

sub check_key_and_update {
    my($self, $req_query) = @_;
    my($evk) = $_EVK->from_literal($req_query->{$self->VERIFY_KEY});
    return 0
        unless $evk && $self->unauth_load({email_verify_key => $evk});
    $self->update({email_verified_date_time => $_DT->now});
    return 1;
}

sub force_update {
    my($self, $realm_id, $location) = @_;
    $location ||= $self->DEFAULT_LOCATION;
    my($e) = $self->new_other('Email');
    $e->unauth_load({
        realm_id => $realm_id,
        location => $location,
    });
    $self->unauth_create_or_update({
        realm_id => $realm_id,
        location => $location,
        email => $e->unsafe_get('email'),
        email_verify_key => $_EVK->create,
        email_verified_date_time => $_DT->now,
    });
    return;
}

sub internal_initialize {
    return {
        version => 1,
        table_name => 'email_verify_t',
        columns => {
            realm_id => ['Email.realm_id', 'PRIMARY_KEY'],
            location => ['Email.location', 'PRIMARY_KEY'],
            email => ['Email.email', 'NOT_NULL'],
            email_verify_key => ['EmailVerifyKey', 'NOT_NULL'],
            email_verified_date_time => ['DateTime', 'NONE'],
        },
        auth_id => ['realm_id'],
    };
}

sub uri_with_new_key {
    my($self, $email) = @_;
    my($vk) = $_EVK->create;
    $self->unauth_create_or_update({
        email_verify_key => $vk,
        realm_id => $self->req('auth_id'),
        defined($email) ? (email => $email) : (),
        location => $self->DEFAULT_LOCATION,
    });
    return $self->req->format_http({
        query => {
            $self->VERIFY_KEY => $vk,
        },
    });
}

1;
