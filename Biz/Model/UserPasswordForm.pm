# Copyright (c) 2003-2023 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Model::UserPasswordForm;
use strict;
use Bivio::Base 'Biz.FormModel';

# Not making this a UserEscalatedAccessBaseForm for now so as to not change existing apps.

my($_A) = b_use('Action.Acknowledgement');
my($_AMC) = b_use('Action.MFAChallenge');
my($_P) = b_use('Type.Password');
my($_TSC) = b_use('Type.SecretCode');
my($_TSCS) = b_use('Type.SecretCodeStatus');

sub PASSWORD_FIELD_LIST {
    return qw(new_password old_password confirm_new_password);
}

sub execute_ok {
    my($self) = shift;
    # Updates the password in the database and the cookie.
    $self->get_instance('UserLoginForm')->execute($self->req, {
        realm_owner => $self->get('realm_owner')
            ->update_password($self->get('new_password')),
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_context => 1,
        $self->field_decl(
            visible => [
                [qw(old_password Password NONE)],
                [qw(new_password NewPassword NOT_NULL)],
                [qw(confirm_new_password ConfirmPassword NOT_NULL)],
            ],
            other => [
                [qw(require_old_password Boolean)],
            ],
        ),
    });
}

sub internal_pre_execute {
    my($self, $method) = @_;
    shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field(
        realm_owner => $self->req(qw(auth_realm owner)),
        require_old_password => $_AMC->unsafe_get_challenge($self->req, {
            type => $_TSC->ESCALATION_CHALLENGE,
            status => $_TSCS->PASSED,
        }) || $self->req->is_substitute_user
            ? 0 : 1,
    );
    return;
}

sub internal_validate_new {
    my($self) = @_;
    if (my $err = $self->get('realm_owner')->validate_password($self->get('new_password'))) {
        $self->internal_put_error(new_password => $err);
    }
    return;
}

sub internal_validate_old {
    my($self) = @_;
    return $self->internal_put_error(qw(old_password PASSWORD_MISMATCH))
        unless $_P->is_equal(
            $self->get_nested(qw(realm_owner password)),
            $self->get('old_password'),
        );
    return 1;
}

sub validate {
    my($self) = @_;
    return
        if $self->in_error;
    if ($self->get('require_old_password')) {
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
