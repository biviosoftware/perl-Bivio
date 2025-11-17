# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserEscalatedAccessBaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_AMC) = b_use('Action.MFAChallenge');
my($_TSC) = b_use('Type.SecretCode');
my($_TSCS) = b_use('Type.SecretCodeStatus');

sub execute_unwind {
    my(undef, $delegator) = shift->delegated_args(@_);
    # If user takes too long and gets redirected to the escalation form again we end up back here.
    return $delegator->validate_and_execute_ok;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
        $self->field_decl(
            other => [
                [qw(passed_access_challenge Model.UserSecretCode)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my(undef, $delegator) = shift->delegated_args(@_);
    $delegator->internal_put_field(
        passed_access_challenge => $_AMC->assert_challenge($delegator->req, {
            type => $_TSC->ESCALATION_CHALLENGE,
            status => $_TSCS->PASSED,
        }),
    );
    return;
}

1;
