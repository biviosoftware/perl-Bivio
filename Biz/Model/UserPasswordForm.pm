# Copyright (c) 2003-2023 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserPasswordForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_P) = b_use('Type.Password');
my($_RCT) = b_use('Type.RecoveryCodeType');

sub PASSWORD_FIELD_LIST {
    return qw(new_password old_password confirm_new_password);
}

sub execute_ok {
    my($self) = @_;
    # Updates the password in the database and the cookie.
    my($res) = shift->SUPER::execute_ok(@_);
    my($req) = $self->get_request;
    $self->get_instance('UserLoginForm')->execute($req, {
        realm_owner => $req->get_nested(qw(auth_realm owner))
            ->update_password($self->get('new_password')),
    });
    $self->req('Model.RecoveryCode')->delete
        if $self->ureq('Model.RecoveryCode');
    return $res;
}

sub internal_initialize {
    my($self) = @_;
    # Return config.
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
        $self->field_decl(
            visible => [
                [qw(old_password Password NONE)],
                [qw(new_password NewPassword NOT_NULL)],
                [qw(confirm_new_password ConfirmPassword NOT_NULL)],
            ],
            hidden => [
                [qw(display_old_password Boolean)],
                [qw(display_totp Boolean)],
                [qw(password_query_recovery_code RecoveryCode NONE)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self, $method) = @_;
    # Sets the 'display_old_password' field based on if the user is the
    # super user.
    my($req) = $self->get_request;
    my($pqrc) = $req->unsafe_get_nested(qw(Action.UserPasswordQuery password_query_recovery_code));
    $self->internal_put_field(password_query_recovery_code => $pqrc)
        if $pqrc;
    $self->internal_put_field(
        display_old_password => $pqrc || $req->is_substitute_user ? 0 : 1);
    return;
}

sub internal_validate_new {
    my($self) = @_;
    if (my $err = $self->req(qw(auth_realm owner))->validate_password($self->get('new_password'))) {
        $self->internal_put_error(new_password => $err);
    }
    return;
}

sub internal_validate_old {
    my($self) = @_;
    return $self->internal_put_error(qw(old_password PASSWORD_MISMATCH))
        unless $_P->is_equal(
            $self->req(qw(auth_realm owner password)),
            $self->get('old_password'),
        );
    return 1;
}

sub validate {
    my($self) = @_;
    return if $self->in_error;
    my($rc) = $self->new_other('RecoveryCode')->load_by_code_and_type(
        $self->get('password_query_recovery_code'), $_RCT->PASSWORD_QUERY)
        if $self->unsafe_get('password_query_recovery_code');
    unless ($self->req->is_substitute_user || $rc) {
        return
            unless $self->validate_not_null('old_password')
            && $self->internal_validate_old;
    }
    return $self->internal_put_error(qw(confirm_new_password CONFIRM_PASSWORD))
        unless $self->get('new_password') eq $self->get('confirm_new_password');
    $self->internal_validate_new;
    return;
}

1;
