# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel::User;
use strict;
$Bivio::Biz::PropertyModel::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::User - a system user

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::User;
    Bivio::Biz::PropertyModel::User->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::User::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::User> is the minimum set of properties for a system user. The
fields are:
    id
    name
    password
Other user related models are UserDemographics, UserEmail, and
UserPreferences.

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::Biz::PropertyModel::UserDemographics;
use Bivio::SQL::Support;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_demographics"></a>

=head2 get_demographics() : UserDemographics

Returns the UserDemographics associated with this user.

=cut

sub get_demographics {
    my($self) = @_;
    my($demo) = Bivio::Biz::PropertyModel::UserDemographics->new(
	    $self->get_request);
    $demo->unauth_load(user_id => $self->get('user_id'))
	    || die('integrity constraint failed: missing user demographics');
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
	    .'where user_t.user_id=? '
	    .'and user_t.user_id=user_email_t.user_id');

    Bivio::SQL::Connection->execute($statement, $self, $self->get('user_id'));
    my($result) = [];
    my($row);
    while($row = $statement->fetchrow_arrayref()) {
	push(@$result, $row->[0]);
    }
#TODO: Do we need statement->finish here?
#    $statement->finish();
    return $result;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

=cut

sub internal_initialize {
    my($property_info) = {
	'user_id' => ['Internal ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'name' => ['Login Name',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
	'password' => ['Password',
		Bivio::Biz::FieldDescriptor->lookup('PASSWORD', 32)]
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
