# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::MFARecoveryCodeList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_DT) = b_use('Type.DateTime');
my($_SC) = b_use('Type.AccessCode');
my($_SCS) = b_use('Type.AccessCodeStatus');
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    new_code_count => 6,
    refill_threshold => 2,
});

sub create {
    my($self, $code_array) = @_;
    my($uac) = $self->new_other('UserAccessCode');
    $code_array->do_iterate(sub {
        my($it) = @_;
        $uac->create({
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
        $self->new_other('UserAccessCode')->set_ephemeral->load({
            user_access_code_id => $it->get('UserAccessCode.user_access_code_id'),
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
        auth_id => ['UserAccessCode.user_id'],
        other => ['UserAccessCode.code'],
        primary_key => [qw(UserAccessCode.user_access_code_id)],
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($rows) = shift->SUPER::internal_load_rows(@_);
    # Can't sort with order_by since the field is encrypted.
    return [sort({$a->{'UserAccessCode.code'} cmp $b->{'UserAccessCode.code'}} @$rows)];
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where(
        $stmt->EQ('UserAccessCode.type', [$_SC->MFA_RECOVERY]),
        $stmt->EQ('UserAccessCode.status', [$_SCS->ACTIVE]),
    );
    return;
}

1;
