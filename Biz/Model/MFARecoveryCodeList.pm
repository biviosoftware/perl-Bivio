# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::MFARecoveryCodeList;
use strict;
use Bivio::Base 'Biz.ListModel';

# TODO: should be UserMFARecoveryCodeList?

my($_DT) = b_use('Type.DateTime');
my($_SC) = b_use('Type.SecretCode');
my($_SCS) = b_use('Type.SecretCodeStatus');
my($_USC) = b_use('Model.UserSecretCode');
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    new_code_count => 6,
    refill_threshold => 2,
});

sub create {
    my($self, $code_array) = @_;
    my($usc) = $self->new_other('UserSecretCode');
    $code_array->do_iterate(sub {
        my($it) = @_;
        $usc->create({
            type => $_SC->MFA_RECOVERY,
            code => $it,
            status => $_SCS->ACTIVE,
        });
        return 1;
    });
    return;
}

sub delete {
    my($self) = @_;
    $self->do_rows(sub {
        my($it) = @_;
        $self->new_other('UserSecretCode')->set_ephemeral->load({
            user_secret_code_id => $it->get('UserSecretCode.user_secret_code_id'),
        })->delete;
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
        auth_id => ['UserSecretCode.user_id'],
        other => ['UserSecretCode.code'],
        primary_key => [qw(UserSecretCode.user_secret_code_id)],
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($rows) = shift->SUPER::internal_load_rows(@_);
    # Can't sort with order_by since the field is encrypted.
    return [sort({$a->{'UserSecretCode.code'} cmp $b->{'UserSecretCode.code'}} @$rows)];
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where(
        $stmt->EQ('UserSecretCode.type', [$_SC->MFA_RECOVERY]),
        $stmt->EQ('UserSecretCode.status', [$_SCS->ACTIVE]),
    );
    return;
}

1;
