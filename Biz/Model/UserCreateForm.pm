# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserCreateForm;
use strict;
$Bivio::Biz::Model::UserCreateForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::UserCreateForm::VERSION;

=head1 NAME

Bivio::Biz::Model::UserCreateForm - create a new user

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::UserCreateForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::UserCreateForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::UserCreateForm> creates a new user.  Subclasses may want
to override this form.

=cut

#=IMPORTS
use Bivio::Auth::RealmType;
use Bivio::Type::Honorific;
use Bivio::Type::Location;
use Bivio::Type::Password;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Create the RealmOwner, User, Email, and RealmUser models.
Logs in as the new user.

=cut

sub execute_ok {
    my($self) = @_;
    Bivio::Biz::Model->get_instance('UserLoginForm')->execute(
	$self->get_request,
	{realm_owner => _create_models($self)});
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 1,
	visible => [
	    'RealmOwner.display_name',
	    'Email.email',
            'RealmOwner.password',
	    {
		name => 'confirm_password',
		type => 'Password',
		constraint => 'NOT_NULL',
	    },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="validate"></a>

=head2 validate()

Ensures the fields are valid.

=cut

sub validate {
    my($self) = @_;
    $self->internal_put_error('RealmOwner.password', 'CONFIRM_PASSWORD')
	unless $self->get_field_error('RealmOwner.password')
	    || $self->get_field_error('confirm_password')
	    || $self->get('RealmOwner.password')
		eq $self->get('confirm_password');
    return;
}

#=PRIVATE SUBROUTINES

# _create_models(self) : Model.RealmOwner
#
# Creates User, RealmOwner, Email and RealmUser models.
#
sub _create_models {
    my($self) = @_;
    my($req) = $self->get_request;

    my($user) = $self->new($req, 'User')->create({
	last_name => $self->get('RealmOwner.display_name'),
    });
    my($realm) = $self->new($req, 'RealmOwner')->create({
	realm_id => $user->get('user_id'),
	name => 'u' . $user->get('user_id'),
	realm_type => Bivio::Auth::RealmType->USER,
	password => Bivio::Type::Password->encrypt(
	    $self->get('RealmOwner.password')),
	display_name => $self->get('RealmOwner.display_name'),
    });
    $self->new($req, 'Email')->create({
	realm_id => $user->get('user_id'),
	email => $self->get('Email.email'),
	location => Bivio::Type::Location->HOME,
	want_bulletin => 0,
    });
    $self->new($req, 'RealmUser')->create({
	realm_id => $user->get('user_id'),
	user_id => $user->get('user_id'),
	honorific => Bivio::Type::Honorific->SELF,
    });
    return $realm;
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
