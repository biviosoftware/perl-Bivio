# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::UserForm;
use strict;
$Bivio::Biz::Model::UserForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::UserForm - a list of User information

=head1 SYNOPSIS

    use Bivio::Biz::Model::UserForm;
    Bivio::Biz::Model::UserForm->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::UserForm::ISA = qw(Bivio::Biz::FormModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::UserForm>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Auth::RealmType;
use Bivio::Biz::Action::CopyClub;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Biz::Model::RealmUser;
use Bivio::IO::Trace;
use Bivio::SQL::Constraint;
use Bivio::Type::Email;
use Bivio::Type::Password;

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
    $values->{password} = Bivio::Type::Password->encrypt($values->{password});
    $model = $self->get_model('RealmOwner');
    $values->{realm_type} = Bivio::Auth::RealmType::USER();
    $model->create($values);

    # Only create UserEmail if an email address was given
    $values = $self->get_model_properties('UserEmail');
    if (defined($values->{email})) {
	$model = $self->get_model('UserEmail');
	$model->create($values);
    };

    # Always set user as admin of own realm
    my($req) = $self->get_request;
    $model = Bivio::Biz::Model::RealmUser->new($req);
    $model->create({
	'realm_id' => $values->{user_id},
	'user_id' => $values->{user_id},
	'role' => Bivio::Auth::Role::ADMINISTRATOR(),
    });

    # load and copy the demo club
    my($demo_realm) = Bivio::Biz::Model::RealmOwner->new($req);
    my($name) = $self->get('RealmOwner.name')."_demo_club";
    $demo_realm->unauth_load(name => 'demo')
	    || die("couldn't find demo realm");;
    $req->put(source => $demo_realm);
    $req->put(target_name => $name);
    $req->put(target_full_name => $self->get_model('User')->get('display_name')
	."'s Demo Club");
    Bivio::Biz::Action::CopyClub->get_instance()->execute($req);

    # add the user to the user's demo club
    my($new_realm) = Bivio::Biz::Model::RealmOwner->new($req);
    $new_realm->unauth_load(name => $name);
    $model = Bivio::Biz::Model::RealmUser->new($req);
    $model->create({
	'realm_id' => $new_realm->get('realm_id'),
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
	visible => [
	    'RealmOwner.name',
            'RealmOwner.password',
	    {
		name => 'confirm_password',
		type => 'Bivio::Type::Password',
		constraint => Bivio::SQL::Constraint::NOT_NULL(),
	    },
	    'User.first_name',
	    'User.middle_name',
	    'User.last_name',
	    {
		name => 'UserEmail.email',
		constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    'User.gender',
	    'User.birth_date',
	    'User.street1',
	    'User.street2',
	    'User.city',
	    'User.state',
	    'User.zip',
	    'User.country',
	    'User.phone',
	    'User.fax',
	],
	auth_id =>
	    ['User.user_id', 'RealmOwner.realm_id', 'UserEmail.user_id'],
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
    die('not implemented properly');
#TODO: fix password code
    my($realm_owner) = $self->get_model_properties('RealmOwner');
    my($values) = $self->get_model_properties('User');
    _set_display_name($values, $realm_owner);
    my($model) = $self->get_model('User');
    $model->update($values);

    $model = $self->get_model('RealmOwner');
    $model->update($realm_owner);

#TODO: Fix email
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
	    && defined($user_values->{first_name})) {
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
