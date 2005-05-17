# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserPasswordForm;
use strict;
$Bivio::Biz::Model::UserPasswordForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::UserPasswordForm::VERSION;

=head1 NAME

Bivio::Biz::Model::UserPasswordForm - change user password

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::UserPasswordForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::UserPasswordForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::UserPasswordForm>

=cut

#=IMPORTS
use Bivio::Biz::Model::UserLoginForm;
use Bivio::Biz::Model::UserLostPasswordForm;
use Bivio::Type::Password;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Updates the password in the database and the cookie.

=cut

sub execute_ok {
    my($self) = @_;
    my($encrypted) = Bivio::Type::Password->encrypt(
        $self->get('new_password'));
    my($lost_password_realm) = _get_lost_password_realm($self);
    ($lost_password_realm || _get_owner($self))->update({
        password => $encrypted});

    if ($lost_password_realm) {
        $self->get_instance('UserLoginForm')->execute($self->get_request, {
            realm_owner => $lost_password_realm,
        });
    }
    else {
        $self->get_request->get('cookie')->put(
            Bivio::Biz::Model::UserLoginForm->PASSWORD_FIELD => $encrypted);
    }
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 1,
	require_context => 1,
	visible => [
	    {
		name => 'old_password',
		type => 'Password',
		constraint => 'NONE',
	    },
	    {
		name => 'new_password',
		type => 'Password',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'confirm_new_password',
		type => 'Password',
		constraint => 'NOT_NULL',
	    },
	],
	other => [
	    {
		name => 'display_old_password',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'user_display_name',
		type => 'String',
		constraint => 'NOT_NULL',
	    },
	],
    };
    return $self->merge_initialize_info(
        $self->SUPER::internal_initialize, $info);
}

=for html <a name="internal_pre_execute"></a>

=head2 internal_pre_execute(string method)

Sets the 'display_old_password' field based on if the user is the
super user.

=cut

sub internal_pre_execute {
    my($self, $method) = @_;
    my($req) = $self->get_request;
    my($lost_password_realm) = _get_lost_password_realm($self);
    $self->internal_put_field(display_old_password =>
        ($lost_password_realm || $req->is_substitute_user)
        ? 0 : 1);
    $self->internal_put_field(user_display_name =>
        ($lost_password_realm || _get_owner($self))->get('display_name'));
    return;
}

=for html <a name="validate"></a>

=head2 validate()

Validates the old password for normal users.
Ensures the new password and confirm password matches.

=cut

sub validate {
    my($self) = @_;
    _validate_old_password($self)
        if $self->get('display_old_password');
    return if $self->in_error;
    $self->internal_put_error('confirm_new_password', 'CONFIRM_PASSWORD')
        unless $self->get('new_password')
            eq $self->get('confirm_new_password');
     return;
}

#=PRIVATE SUBROUTINES

# _get_lost_password_realm(self) : Bivio::Biz::Model
#
# Returns the realm of the lost password user. Returns undef if the
# user is not present in the query.
#
sub _get_lost_password_realm {
    my($self) = @_;
    my($lost_password_realm) = Bivio::Biz::Model::UserLostPasswordForm
        ->unsafe_get_realm_from_query($self->get_request);

    unless ($lost_password_realm) {
        Bivio::DieCode->NOT_FOUND->throw_die
            if $self->get_request->get('auth_realm')->get('type')
                ->equals_by_name('GENERAL');
    }
    return $lost_password_realm;
}

# _get_owner(self) : Bivio::Biz::Model::RealmOwner
#
# Returns the RealmOwner for the current realm.
#
sub _get_owner {
    my($self) = @_;
    return $self->new_other('RealmOwner')->load;
}

# _validate_old_password(self)
#
# Validate the old password.
#
sub _validate_old_password {
    my($self) = @_;
    $self->validate_not_null('old_password');
    return if $self->in_error;
    $self->internal_put_error('old_password', 'PASSWORD_MISMATCH')
        unless Bivio::Type::Password->is_equal(
            _get_owner($self)->get('password'), $self->get('old_password'));
}

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
