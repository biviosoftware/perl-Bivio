# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel::UserDemographics;
use strict;
$Bivio::Biz::PropertyModel::UserDemographics::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::UserDemographics - demographics

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::UserDemographics;
    Bivio::Biz::PropertyModel::UserDemographics->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::UserDemographics::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::UserDemographics> are fields describing the current user.
All of the fields are optional.
    first_name
    middle_name
    last_name
    gender
    age

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::SQL::Support;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash new_values)

Creates a new model in the database with the specified value. After creation,
this instance has the same values.

=cut

sub create {
    my($self, $new_values) = @_;
    # because user and user-demographics are kept in the same database
    # table right now, create() really justs updates the already existing
    # record
    defined($new_values->{user_id}) || die('missing primary key');
    $self->internal_get_fields()->{user_id} = $new_values->{user_id};
    $self->update($new_values);
    $self->get_request->put(ref($self), $self);
    return;
}

=for html <a name="delete"></a>

=head2 delete()

Deletes the current model from the database.

=cut

sub delete {
    my($self) = @_;
    # because user and user-demographics are kept in the same database
    # table right now, delete() just blanks demographic fields
    # PropertyModel will delete the primary key from new_values.
    return $self->update({map {($_, undef)} @{$self->get_field_names()}});
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : (array_ref, Bivio::SQL::Support)

=cut

sub internal_initialize {
    my($property_info) = {
	'user_id' => ['Internal ID',
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
    return [$property_info,
	    Bivio::SQL::Support->new('user_t', keys(%$property_info)),
	    ['user_id']];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
