# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::RecoveryCodeList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_RC) = b_use('Model.RecoveryCode');
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    new_code_count => 5,
});

sub create {
    my($self, $code_array) = @_;
    $code_array->do_iterate(sub {
        my($it) = @_;
        $_RC->new($self->req)->create($it);
        return 1;
    });
    return;
}

sub get_new_code_count {
    return $_CFG->{new_code_count};
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
        auth_id => ['RecoveryCode.user_id'],
        primary_key => [qw(RecoveryCode.user_id RecoveryCode.code)],
    });
}

1;
