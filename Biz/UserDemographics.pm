# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::UserDemographics;
use strict;
$Bivio::Biz::UserDemographics::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::UserDemographics - demographics

=head1 SYNOPSIS

    use Bivio::Biz::UserDemographics;
    Bivio::Biz::UserDemographics->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::UserDemographics::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::UserDemographics> are fields describing the current user.
All of the fields are optional.
    first_name
    middle_name
    last_name
    gender
    age

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Error;
use Bivio::Biz::FieldDescriptor;
use Bivio::Biz::SqlSupport;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_PROPERTY_INFO) = {
    'id' => ['Internal ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    'first_name' => ['First Name',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
    'middle_name' => ['Middle Name',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
    'last_name' => ['Last Name',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 64)],
    'gender' => ['Gender',
	    Bivio::Biz::FieldDescriptor->lookup('GENDER', 1)],
    'age' => ['Age',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 3)],
    };

my($_SQL_SUPPORT) = Bivio::Biz::SqlSupport->new('user_',
	keys(%$_PROPERTY_INFO));

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::UserDemographics

Creates an uninitialized UserDemographics model. Use find() to load
the model with values.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::PropertyModel::new($proto, 'demographics',
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

    # clear the status from previous invocations
    $self->get_status()->clear();

    # because user and user-demographics are kept in the same database
    # table right now, create() really justs updates the already existing
    # record
    defined($new_values->{id}) || die('missing primary key');
    $self->internal_get_fields()->{id} = $new_values->{id};
    return $self->update($new_values);
}

=for html <a name="delete"></a>

=head2 delete() : boolean

Deletes the current model from the database. Returns 1 if successful,
0 otherwise.

=cut

sub delete {
    my($self) = @_;

    # because user and user-demogrpahics are kept in the same database
    # table right now, delete() just blanks demographic fields

    return $self->update({
	'first_name' => undef,
	'middle_name' => undef,
	'last_name' => undef,
	'gender' => undef,
	'age' => undef
	});
}

=for html <a name="find"></a>

=head2 find(FindParams fp) : boolean

Finds demographics given the specified search parameters. Valid parameters
are 'id'.

=cut

sub find {
    my($self, $fp) = @_;

    # clear the status from previous invocations
    $self->get_status()->clear();

    if ($fp->get('id')) {
	$_SQL_SUPPORT->find($self, $self->internal_get_fields(),
		'where id=?', $fp->get('id'));
    }
    else {
	$self->get_status()->add_error(
		Bivio::Biz::Error->new("User not found"));
    }
    return $self->get_status()->is_ok();
}

=for html <a name="update"></a>

=head2 update(hash new_values) : boolean

Updates the current model's values.
NOTE: find should be called prior to an update.

=cut

sub update {
    my($self, $new_values) = @_;

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
