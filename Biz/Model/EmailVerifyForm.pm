# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EmailVerifyForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_ULF) = b_use('Model.UserLoginForm');
my($_A) = b_use('Biz.Action');
my($_EV) = b_use('Model.EmailVerify');

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    my($q) = $req->unsafe_get('query');
    if ($q && $q->{$_EV->VERIFY_KEY}) {
        $req->put(query => {});
        my($ev) = $self->new_other('EmailVerify');
        if ($ev->check_key_and_update($q)) {
            $_A->get_instance('Acknowledgement')->save_label(
                email_verified => $req,
            );
            $self->internal_update_email($ev->get('email'));
            return {
                task_id => 'ok_task',
                no_context => 1,
                query => $self->req('query'),
            };
        }
        $self->internal_put_error('Email.email' => 'EMAIL_VERIFY_KEY');
    }
    $self->internal_put_field('Email.email'
        => $q && $q->{$_EV->EMAIL_KEY}
            ? $q->{$_EV->EMAIL_KEY}
            : $self->internal_get_email);
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->internal_put_field(
        uri => $self->new_other('EmailVerify')
            ->uri_with_new_key($self->get('Email.email')));
    $self->put_on_request(1);
    return;
}

sub internal_get_email {
    return shift->new_other('Email')->load->get('email');
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
            'Email.email',
        ],
        other => [
            {
                name => 'uri',
                type => 'HTTPURI',
                constraint => 'NONE',
            },
        ],
        auth_id => 'Email.realm_id',
    });
}

sub internal_update_email {
    my($self, $email) = @_;
    $self->new_other('Email')->load->update({
        email => $email,
    });
    return;
}

1;
