# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::CreateUser;
use strict;
$Bivio::Biz::CreateUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::CreateUser - creates a new user

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::CreateUser::ISA = qw(Bivio::Biz::Action);

=head1 DESCRIPTION

C<Bivio::Biz::Action::CreateUser>

=cut

#=IMPORTS
use Bivio::Auth::Role;
use Bivio::Biz::PropertyModel::Club;
use Bivio::Biz::PropertyModel::ClubUser;
use Bivio::Biz::PropertyModel::RealmUser;
use Bivio::Biz::PropertyModel::UserDemographics;
use Bivio::Biz::PropertyModel::UserEmail;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my(@_USER_FIELDS) = qw(
    name
    password
    confirm_password
);
my(@_USER_DEMOGRAPHICS_FIELDS) = qw(
    first_name
    middle_name
    last_name
    age
    gender
);
my(@_USER_EMAIL_FIELDS) = qw(
    email
);

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Request req)

Creates a new user record in the database using values specified in the
request.

=cut

sub execute {
    my(undef, $req) = @_;

    # make sure password fields match
    my($user) = Bivio::Biz::PropertyModel::User->new($req);
    my($values) = $req->get_fields('form', \@_USER_FIELDS);
#TODO: Validate the list of form fields
    if ($values->{password} ne $values->{confirm_password}) {
	$values->{password} = '';
	$values->{confirm_password} = '';
	die('password fields did not match');
    }
    delete($values->{confirm_password});
    $user->create($values);
    my($user_id) = $user->get('user_id');

    my($demographics) = Bivio::Biz::PropertyModel::UserDemographics->new($req);
    $values = $req->get_fields('form', \@_USER_DEMOGRAPHICS_FIELDS);
    $values->{user_id} = $user_id;
    $demographics->create($values);

    my($email) = Bivio::Biz::PropertyModel::UserEmail->new($req);
    $values = $req->get_fields('form', \@_USER_EMAIL_FIELDS);
    $values->{user_id} = $user->get('user_id');
    $email->create($values);

    my($realm_user) = Bivio::Biz::PropertyModel::RealmUser->new($req);
    $realm_user->create({
	'realm_id' => $user_id,
	'user_id' => $user_id,
	'role' => Bivio::Auth::Role->ADMINISTRATOR->as_int,
    });
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
