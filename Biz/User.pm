# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::User;
use strict;
$Bivio::Biz::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::User - a system user

=head1 SYNOPSIS

    use Bivio::Biz::User;
    Bivio::Biz::User->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::User::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::User> is the minimum set of properties for a system user. The
fields are:
    id
    name
    password
Other user related models are UserDemographics, UserEmail, and
UserPreferences.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Club;
use Bivio::Biz::Action::CreateUser;
use Bivio::Biz::Error;
use Bivio::Biz::FieldDescriptor;
use Bivio::Biz::FindParams;
use Bivio::Biz::UserDemographics;
use Bivio::IO::Trace;
use Bivio::SQL::Support;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_PROPERTY_INFO) = {
    'id' => ['Internal ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    'name' => ['Login Name',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
    'password' => ['Password',
	    Bivio::Biz::FieldDescriptor->lookup('PASSWORD', 32)]
    };

my($_SQL_SUPPORT) = Bivio::SQL::Support->new('user_t',
	keys(%$_PROPERTY_INFO));

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::User

Creates a new user model with all properties undefined. Use load() to
load the model with values.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::PropertyModel::new($proto, 'user_id',
	    $_PROPERTY_INFO);

    $self->{$_PACKAGE} = {};
    $_SQL_SUPPORT->initialize();

    return $self;
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash new_values) : boolean

Creates a new model in the database with the specified value. After creation,
this instance has the same values.

=cut

sub create {
    my($self, $new_values) = @_;
    my($fields) = $self->{$_PACKAGE};

    # clear the status from previous invocations
    $self->get_status()->clear();

#TODO: probably a better regex than this
    if ($new_values->{'name'} =~ /^\w\w\w\w(\w)*$/) {

	# make sure a club doesn't have the same name
	my($club) = Bivio::Biz::Club->new();

	if ($club->load(Bivio::Biz::FindParams->new(
		{'name' => $new_values->{'name'}}))) {
	    $self->get_status()->add_error(
		    Bivio::Biz::Error->new('already exists'));
	}
	else {
	    $_SQL_SUPPORT->create($self, $self->internal_get_fields(),
		    $new_values);
	}
    }
    else {
	$self->get_status()->add_error(
		Bivio::Biz::Error->new('invalid login name'));
    }
    return $self->get_status()->is_ok();
}

=for html <a name="delete"></a>

=head2 delete() : boolean

Deletes the current model from the database. Returns 1 if successful,
0 otherwise.

=cut

sub delete {
    my($self) = @_;

    return $_SQL_SUPPORT->delete($self, 'where id=?', $self->get('id'));
}

=for html <a name="find"></a>

=head2 load(FindParams fp) : boolean

Finds the user given the specified search parameters. Valid find keys
are 'id' or 'name'.

=cut

sub load {
    my($self, $fp) = @_;

    # clear the status from previous invocations
    $self->get_status()->clear();

    if ($fp->get('id')) {
	return $_SQL_SUPPORT->load($self, $self->internal_get_fields(),
		'where id=?', $fp->get('id'));
    }
    if ($fp->get('name')) {
	return $_SQL_SUPPORT->load($self, $self->internal_get_fields(),
		'where name=?',	$fp->get('name'));
    }

    $self->get_status()->add_error(
	    Bivio::Biz::Error->new("User not found"));
    return 0;
}

=for html <a name="get_action"></a>

=head2 get_action(string name) : Action

Returns the named action or undef if no action exists for
that name.

=cut

sub get_action {
    my($self, $name) = @_;

    if ($name eq 'add') {
	return Bivio::Biz::Action::CreateUser->new();
    }
    die("no action $name");
}

=for html <a name="get_demographics"></a>

=head2 get_demographics() : UserDemographics

Returns the UserDemographics associated with this user.

=cut

sub get_demographics {
    my($self) = @_;

#TODO: model cache manager
    my($demo) = Bivio::Biz::UserDemographics->new();
    $demo->load(Bivio::Biz::FindParams->new({'user_id' => $self->get('id')}));
    return $demo;
}

=for html <a name="get_email_addresses"></a>

=head2 get_email_addresses() : array

Returns an array of email addresses for this user.

=cut

sub get_email_addresses {
    my($self) = @_;
    my($conn) = Bivio::SQL::Connection->get_connection();

    # a 4 table join
    my($statement) = $conn->prepare_cached(
	    'select user_email_t.email '
	    .'from user_email_t, user_t '
	    .'where user_t.id=? '
	    .'and user_t.id=user_email_t.user_id');

    Bivio::SQL::Connection->execute($statement, $self, $self->get('id'));

    my($result);

    if ($self->get_status()->is_ok()) {
	$result = [];
	my($row);

	while($row = $statement->fetchrow_arrayref()) {
	    push(@$result, $row->[0]);
	}
    }
    $statement->finish();
    return $result;
}

=for html <a name="get_full_name"></a>

=head2 get_full_name() : string

Returns a displayable form of the user's name. This will be formatted
as "First Middle Last" or "Login-Name" depending on whether the user
has demographics.

=cut

sub get_full_name {
    my($self) = @_;

    if ($self->get('id')) {
#TODO: create this from demograhics data
	return 'Full Name'
    }
    else {
	return 'Add User';
    }
}

=for html <a name="get_heading"></a>

=head2 get_heading() : string

Returns the user's full name.

=cut

sub get_heading {
    my($self) = @_;
    return $self->get_full_name();
}

=for html <a name="get_preferences"></a>

=head2 get_preferences() : UserPreferences

Returns the UserPreferences associated with this user.

=cut

sub get_preferences {
    die("not implemented");
}

=for html <a name="get_title"></a>

=head2 get_title() : string

Returns the user's full name.

=cut

sub get_title {
    my($self) = @_;
    return $self->get_full_name();
}

=for html <a name="update"></a>

=head2 update(hash new_values) : boolean

Updates the current model's values.
NOTE: find should be called prior to an update.

=cut

sub update {
    my($self, $new_values) = @_;

#TODO: if 'id' is in new_values, make sure it is the same

    return $_SQL_SUPPORT->update($self, $self->internal_get_fields(),
	    $new_values, 'where id=?', $self->get('id'));
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
