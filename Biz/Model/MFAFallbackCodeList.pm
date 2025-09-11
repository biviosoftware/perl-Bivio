# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::MFAFallbackCodeList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_DT) = b_use('Type.DateTime');
my($_RC) = b_use('Type.RecoveryCode');
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    new_code_count => 6,
    refill_threshold => 2,
});

sub create {
    my($self, $code_array) = @_;
    $code_array->do_iterate(sub {
        my($it) = @_;
        $self->new_other('UserRecoveryCode')->create($_RC->MFA_FALLBACK, $it);
        return 1;
    });
    return;
}

sub get_new_code_count {
    return $_CFG->{new_code_count};
}

sub get_refill_threshold {
    return $_CFG->{refill_threshold};
}

sub handle_config {
    my(undef, $cfg) = @_;
    b_die('new_code_count required')
        unless $cfg->{new_code_count};
    $_CFG = $cfg;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        can_iterate => 1,
        auth_id => ['UserRecoveryCode.user_id'],
        other => ['UserRecoveryCode.code'],
        primary_key => [qw(UserRecoveryCode.user_recovery_code_id)],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where($stmt->IS_NULL('UserRecoveryCode.expiration_date_time'));
    return;
}

1;
