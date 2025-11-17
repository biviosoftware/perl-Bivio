# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserEscalationPlainForm;
use strict;
use Bivio::Base 'Model.UserLoginBaseForm';

my($_AMC) = b_use('Action.MFAChallenge');
my($_TSC) = b_use('Type.SecretCode');
my($_TSCS) = b_use('Type.SecretCodeStatus');

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(login => $self->req(qw(auth_realm owner))->format_email);
    return;
}

sub execute_ok {
    my($self) = @_;
    $_AMC->assert_challenge($self->req, {
        type => $_TSC->ESCALATION_CHALLENGE,
        status => $_TSCS->PENDING,
    })->update({status => $_TSCS->PASSED});
    return;
}

sub execute_cancel {
    # Discard context so we don't return to a form that requires escalation and get redirected here
    # again.
    return 'cancel';
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info(shift->SUPER::internal_initialize(@_), {
        version => 1,
        # Required to redirect to original task.
        require_context => 1,
        hidden => [{
            name => 'login',
            type => 'LoginName',
            constraint => 'NOT_NULL',
            form_name => 'x1',
        }],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $_AMC->assert_challenge($self->req, {
        type => $_TSC->ESCALATION_CHALLENGE,
        status => $_TSCS->PENDING,
    });
    return;
}

1;
