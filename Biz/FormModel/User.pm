# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::FormModel::User;
use strict;
$Bivio::Biz::FormModel::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::FormModel::User - a list of User information

=head1 SYNOPSIS

    use Bivio::Biz::FormModel::User;
    Bivio::Biz::FormModel::User->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::FormModel::User::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::Biz::FormModel::User>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Type::Password;
use Bivio::SQL::Constraint;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create()

Processes the form's values and creates models.
Any errors are "put" on the form and the operation is aborted.

=cut

sub create {
    my($self) = @_;
    my($properties) = $self->internal_get;
    my($realm_owner) = $self->get_model_properties('RealmOwner');
    my($values) = $self->get_model_properties('User');
    _set_display_name($values, $realm_owner);
    my($model) = $self->get_model('User');
    $model->create($values);
    $properties->{'User.user_id'} = $model->get('user_id');

    # Get again, so we have user id included
    $values = $self->get_model_properties('RealmOwner');
    $model = $self->get_model('RealmOwner');
    $values->{realm_type} = Bivio::Auth::RealmType::USER();
    $model->create($values);

    $values = $self->get_model_properties('UserEmail');
    $model = $self->get_model('UserEmail');
    $model->create($values);

    $model = Bivio::Biz::PropertyModel::RealmUser->new($self->get_request);
    $model->create({
	'realm_id' => $values->{user_id},
	'user_id' => $values->{user_id},
	'role' => Bivio::Auth::Role::ADMINISTRATOR(),
    });
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	visible => [qw(
	    RealmOwner.name
            RealmOwner.password
	    User.first_name
	    User.middle_name
	    User.last_name
	    UserEmail.email
	    User.gender
	    User.age
	),
	    {
		name => 'confirm_password',
		type => 'Bivio::Type::Password',
		constraint => Bivio::SQL::Constraint::NOT_NULL(),
	    },
	],
	auth_id =>
	    [qw(User.user_id RealmOwner.realm_id UserEmail.user_id)],
	primary_key => [
	    'User.user_id',
	],
    };
}

=for html <a name="update"></a>

=head2 update()

Processes the form's values and updates models.
Any errors are "put" on the form and the operation is aborted.


=cut

sub update {
    my($self) = @_;
    my($properties) = $self->internal_get;
    my($realm_owner) = $self->get_model_properties('RealmOwner');
    my($values) = $self->get_model_properties('User');
    _set_display_name($values, $realm_owner);
    my($model) = $self->get_model('User');
    $model->update($values);

    $model = $self->get_model('RealmOwner');
    $model->update($realm_owner);

    $values = $self->get_model_properties('UserEmail');
    $model = $self->get_model('UserEmail');
    $model->update($values);
    return;
}

=for html <a name="validate"></a>

=head2 validate(boolean is_create)

Checks the form property values.  Puts errors on the fields
if there are any.

=cut

sub validate {
    my($self) = @_;
    my($password) = $self->get_model_properties('RealmOwner')->{password};
    my($confirm_password) = $self->get('confirm_password');
    $self->internal_put_error('confirm_password',
	    Bivio::TypeError::CONFIRM_PASSWORD())
	    unless $password eq $confirm_password;
    return;
}

#=PRIVATE METHODS

# _set_display_name(hash_ref user_values, hash_ref realm_values)
#
# Sets display_name from ether realm_values.name or user_values.
# first_name and last_name.
#
sub _set_display_name {
    my($user_values, $realm_values) = @_;
    # If supplying both last and first names, then use both as
    # display name.
    if (defined($user_values->{last_name})
	    && defined($user_values->{middle_name})) {
	$user_values->{display_name}
		= $user_values->{first_name}.' '.$user_values->{last_name};
    }
    else {
	$user_values->{display_name} = $realm_values->{name};
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
