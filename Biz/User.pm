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
use Bivio::Biz::FindParams;
use Bivio::Biz::SqlSupport;
use Bivio::Biz::UserDemographics;
use Bivio::IO::Config;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
Bivio::IO::Config->register({
    model_name => Bivio::IO::Config->REQUIRED,
    property_cfg => Bivio::IO::Config->REQUIRED,

    table_name => Bivio::IO::Config->REQUIRED,
    sql_field_map => Bivio::IO::Config->REQUIRED
});
my($_CLASS_CFG);
my($_SQL_SUPPORT) = Bivio::Biz::SqlSupport->new();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::User

Creates a new user model with all properties undefined. Use find() to
load the model with values.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::PropertyModel::new($proto, $_CLASS_CFG);

    $self->{$_PACKAGE} = {
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="configure"></a>

=head2 static configure(hash cfg)

See PropertyModel->new() and SqlSupport->set_model_config() for format.

=cut

sub configure {
    my(undef, $cfg) = @_;

    $_CLASS_CFG = $cfg;
    $_SQL_SUPPORT->set_model_config($cfg);
}

=for html <a name="find"></a>

=head2 find(FindParams p) : boolean

Finds the user given the specified search parameters. Valid find parameters
are 'id' or 'name'.

=cut

sub find {
    my($self, $fp) = @_;

    $self->get_status()->clear();

    if ($fp->get_value('id')) {
	$_SQL_SUPPORT->query($self, $self->internal_get_fields(),
		'where id=?', $fp->get_value('id'));
    }
    elsif ($fp->get_value('name')) {
	$_SQL_SUPPORT->query($self, $self->internal_get_fields(),
		'where name=?',	$fp->get_value('name'));
    }
    else {
	$self->get_status()->add_error(
		Bivio::Biz::Error->new("User not found"));
    }
    return $self->get_status()->is_OK();
}

=for html <a name="get_demographics"></a>

=head2 get_demographics() : UserDemographics

Returns the UserDemographics associated with this user.

=cut

sub get_demographics {
    my($self) = @_;

    my($demo) = Bivio::Biz::UserDemographics->new();
    $demo->find(Bivio::Biz::FindParams->new({'user' => $self->get('id')}));
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

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;


use Bivio::Biz::FieldDescriptor;
use Data::Dumper;

$Data::Dumper::Indent = 1;
Bivio::IO::Config->initialize({
    'Bivio::Biz::User' => {

	# PropertyModel configuration
	model_name => 'user',
	property_cfg => {
	    id => ['Internal ID',
		    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	    name => ['User ID',
		    Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
	    password => ['Password',
		    Bivio::Biz::FieldDescriptor->lookup('STRING', 32)]
	    },

	# SQL configuration
	table_name => 'user_',
	sql_field_map => {
	    id => 'id',
	    name => 'name',
	    password => 'password'
	}
    },
    'Bivio::Biz::UserDemographics' => {

	# PropertyModel configuration
	model_name => 'demographics',
	property_cfg => {
	    user => ['Internal ID',
		    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	    first_name => ['First Name',
		    Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
	    middle_name => ['Middle Name',
		    Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
	    last_name => ['Last Name',
		    Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
	    gender => ['Gender',
		    Bivio::Biz::FieldDescriptor->lookup('GENDER', 1)],
	    age => ['Age',
		    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 3)],
	},

	# SQL configuration
	table_name => 'user_',
	sql_field_map => {
	    user => 'user',
	    first_name => 'first_name',
	    middle_name => 'middle_name',
	    last_name => 'last_name',
	    gender => 'gender',
	    age => 'age'
	}
    },
    'Bivio::Ext::DBI' => {
	ORACLE_HOME => '/usr/local/oracle/product/8.0.5',
	database => 'surf_test',
	user => 'moeller',
	password => 'bivio,ho'
        }
    });

my($user) = Bivio::Biz::User->new();
$user->find(Bivio::Biz::FindParams->new({id => 1}));
#$user->find(Bivio::Biz::FindParams->new({name => 'paul'}));
#$user->find(Bivio::Biz::FindParams->new());
#print(Dumper(Bivio::Biz::User->new()));
print(Dumper($user));
my($demo) = $user->get_demographics();
print(Dumper($demo));

