# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::User;
use strict;
$Bivio::Biz::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

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
use Bivio::Biz::Error;
use Bivio::Biz::FieldDescriptor;
use Bivio::Biz::SqlSupport;
use Bivio::Biz::UserDemographics;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_PROPERTY_INFO) = {
    id => ['Internal ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    name => ['User ID',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
    password => ['Password',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 32)]
    };

my($_SQL_SUPPORT) = Bivio::Biz::SqlSupport->new('user_', {
    id => 'id',
    name => 'name',
    password => 'password'
    });

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::User

Creates a new user model with all properties undefined. Use find() to
load the model with values.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::PropertyModel::new($proto, 'user',
	    $_PROPERTY_INFO);

    $self->{$_PACKAGE} = {
    };

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

    return $_SQL_SUPPORT->create($self, $self->internal_get_fields(),
	    $new_values);
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

=head2 find(hash find_params) : boolean

Finds the user given the specified search parameters. Valid find keys
are 'id' or 'name'.

=cut

sub find {
    my($self, $fp) = @_;

    # clear the status from previous invocations
    $self->get_status()->clear();

    if ($fp->{'id'}) {
	return $_SQL_SUPPORT->find($self, $self->internal_get_fields(),
		'where id=?', $fp->{'id'});
    }
    if ($fp->{'name'}) {
	return $_SQL_SUPPORT->find($self, $self->internal_get_fields(),
		'where name=?',	$fp->{'name'});
    }

    $self->get_status()->add_error(
	    Bivio::Biz::Error->new("User not found"));
    return 0;
}

=for html <a name="get_demographics"></a>

=head2 get_demographics() : UserDemographics

Returns the UserDemographics associated with this user.

=cut

sub get_demographics {
    my($self) = @_;

    #TODO: model cache manager
    my($demo) = Bivio::Biz::UserDemographics->new();
    $demo->find({'user' => $self->get('id')});
    return $demo;
}

=for html <a name="get_email_addresses"></a>

=head2 get_email_addresses() : array

Returns an array of email addresses for this user.

=cut

sub get_email_addresses {
    die("not implemented");
}

=for html <a name="get_full_name"></a>

=head2 get_full_name() : string

Returns a displayable form of the user's name. This will be formatted
as "First Middle Last" or "Login-Name" depending on whether the user
has demographics.

=cut

sub get_full_name {
    die("not implemented");
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


#use Bivio::Biz::ListModel;
use Bivio::Biz::UserList;
use Bivio::Biz::SqlConnection;
use Data::Dumper;

$Data::Dumper::Indent = 1;
Bivio::IO::Config->initialize({
    'Bivio::Ext::DBI' => {
	ORACLE_HOME => '/usr/local/oracle/product/8.0.5',
	database => 'surf_test',
	user => 'moeller',
	password => 'bivio,ho'
        },

    'Bivio::IO::Trace' => {
	'package_filter' => '/Bivio/'
        },
    });

=pod

my($user) = Bivio::Biz::User->new();
$user->find({id => 1});
#$user->find({name => 'paul'});
my($demo) = $user->get_demographics();
$user->update({'password', "QWERTY"});
$user->find({id => 3});
$user->delete();
$user->create({id => 3, name => 'ted', password => 'RAZOR'});
#print(Dumper($user));

=cut

my($list) = Bivio::Biz::UserList->new();
$list->find({});
print(Dumper($list));

Bivio::Biz::SqlConnection->get_connection()->commit();
