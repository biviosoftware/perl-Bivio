# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::Biz::Model::UserEscalationPlainForm;
use strict;
use Bivio::Base 'Model.UserLoginBaseForm';

my($_AAC) = b_use('Action.AccessChallenge');
my($_TAC) = b_use('Type.AccessCode');
my($_TACS) = b_use('Type.AccessCodeStatus');

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(login => $self->req(qw(auth_realm owner))->format_email);
    return;
}

sub execute_ok {
    my($self) = @_;
    $_AAC->assert_challenge($self->req, {
        type => $_TAC->ESCALATION_CHALLENGE,
        status => $_TACS->PENDING,
    })->update({status => $_TACS->PASSED});
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
    $_AAC->assert_challenge($self->req, {
        type => $_TAC->ESCALATION_CHALLENGE,
        status => $_TACS->PENDING,
    });
    return;
}

1;
