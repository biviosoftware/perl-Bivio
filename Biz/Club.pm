# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Club;
use strict;
$Bivio::Biz::Club::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::Club - a club

=head1 SYNOPSIS

    use Bivio::Biz::Club;
    Bivio::Biz::Club->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Club::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Club>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::CreateClubAction;
use Bivio::Biz::Error;
use Bivio::Biz::FieldDescriptor;
use Bivio::Biz::SqlSupport;
use Bivio::Biz::User;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_PROPERTY_INFO) = {
    id => ['Internal ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    name => ['Club Name',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
    full_name => ['Full Name',
	    Bivio::Biz::FieldDescriptor->lookup('STRING', 128)],
    bytes_in_use => ['Space Used',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 9)],
    bytes_max => ['Space Allowed',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 9)]
    };

my($_SQL_SUPPORT) = Bivio::Biz::SqlSupport->new('club', {
    id => 'id',
    name => 'name',
    full_name => 'full_name',
    bytes_in_use => 'bytes_in_use',
    bytes_max => 'bytes_max'
    });

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Club

Creates a new Club instance. Use find() to load it with values.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::PropertyModel::new($proto, 'club',
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

    if ($new_values->{'name'} =~ /^\w\w\w\w(\w)*$/) {

	# make sure a user doesn't have the same name
	my($user) = Bivio::Biz::User->new();

	if ($user->find({'name' => $new_values->{'name'}})) {
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
		Bivio::Biz::Error->new('invalid club name'));
    }
    return $self->get_status()->is_OK();
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
	    Bivio::Biz::Error->new("Club not found"));
    return 0;
}

=for html <a name="get_action"></a>

=head2 get_action(string name) : Action

Returns the named action or undef if no action exists for that name.

=cut

sub get_action {
    my($self, $name) = @_;

    if ($name eq 'add') {
	return Bivio::Biz::CreateClubAction->new();
    }
    return undef;
}

=for html <a name="get_heading"></a>

=head2 get_heading() : string

Returns the user's full name.

=cut

sub get_heading {
    my($self) = @_;

    return 'Club Information';
}
=for html <a name="get_title"></a>

=head2 get_title() : string

Returns the user's full name.

=cut

sub get_title {
    my($self) = @_;
    return 'Club Information';
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
