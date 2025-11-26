# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserEscalatedAccessBaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_AAC) = b_use('Action.AccessChallenge');
my($_TAC) = b_use('Type.AccessCode');
my($_TACS) = b_use('Type.AccessCodeStatus');

sub execute_unwind {
    my(undef, $delegator) = shift->delegated_args(@_);
    # If user takes too long and gets redirected to the escalation form again we end up back here.
    my($res) = $delegator->validate_and_execute_ok;
    return $res
        if $res;
    # Need server_redirect for potential mail task
    return {
        method => 'server_redirect',
        task_id => 'next',
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
        $self->field_decl(
            other => [
                [qw(passed_access_challenge Model.UserAccessCode)],
            ],
        ),
    });
}

sub internal_assert_escalation_challenge {
    my(undef, $delegator) = shift->delegated_args(@_);
    $delegator->internal_put_field(
        passed_access_challenge => $_AAC->assert_challenge($delegator->req, {
            type => $_TAC->ESCALATION_CHALLENGE,
            status => $_TACS->PASSED,
        }),
    );
    return;
}

sub internal_pre_execute {
    my(undef, $delegator) = shift->delegated_args(@_);
    $delegator->internal_assert_escalation_challenge;
    return;
}

1;
