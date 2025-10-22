# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::MFARecoveryCodeListRefillForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_UPQ) = b_use('Action.UserPasswordQuery');

sub execute_ok {
    my($self) = @_;
    if ($self->get('password_reset_code')) {
        $_UPQ->new({
            password_reset_code => $self->get('password_reset_code'),
        })->put_on_request($self->req, 1);
        return {
            method => 'server_redirect',
            task_id => 'password_task',
            no_context => 1,
        };
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        $self->field_decl(
            hidden => [
                [qw(password_reset_code SecretLine None)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field(
        password_reset_code => $self->ureq(qw(Action.UserPasswordQuery password_reset_code))
        || $self->get('password_reset_code'),
    );
    return @res;
}

1;
