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
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Biz::Model::Club;
use Bivio::Biz::Model::RealmUser;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Biz::Model::RealmUser;
use Bivio::Biz::Model::User;
use Bivio::Biz::Model::UserEmail;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
use Bivio::Type::Gender;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my(@_REALM_OWNER_FIELDS) = qw(
    name
    password
    confirm_password
);
my(@_USER_FIELDS) = qw(
    first_name
    middle_name
    last_name
    age
    gender
    display_name
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

    # Create user first to get user_id, so can create realm_owner
    my($user) = Bivio::Biz::Model::User->new($req);
    my($values) = $req->get_fields('form', \@_USER_FIELDS);
    my($gender) = $values->{gender};
    $values->{gender} = Bivio::Type::Gender->$gender();
    $values->{display_name} = _generate_default_display_name($req)
	    unless defined($values->{display_name});
    $user->create($values);
    my($user_id) = $user->get('user_id');

    # make sure password fields match
    my($realm_owner) = Bivio::Biz::Model::RealmOwner->new($req);
    $values = $req->get_fields('form', \@_REALM_OWNER_FIELDS);
#TODO: Validate the list of form fields
    die('password fields must be filled in')
	    unless defined($values->{password})
		    && defined($values->{confirm_password});
    if ($values->{password} ne $values->{confirm_password}) {
	$values->{password} = '';
	$values->{confirm_password} = '';
	die('password fields did not match');
    }
    delete($values->{confirm_password});
    $values->{realm_id} = $user_id;
    $values->{realm_type} = Bivio::Auth::RealmType::USER();
    $realm_owner->create($values);

    my($email) = Bivio::Biz::Model::UserEmail->new($req);
    $values = $req->get_fields('form', \@_USER_EMAIL_FIELDS);
    $values->{user_id} = $user->get('user_id');
    $email->create($values);

    my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);
    $realm_user->create({
	'realm_id' => $user_id,
	'user_id' => $user_id,
	'role' => Bivio::Auth::Role->ADMINISTRATOR->as_int,
    });
    return;
}

#=PRIVATE METHODS

# _generate_default_display_name(hash values)
#
# Formats name in precedence: (NOT)
#   last, first middle
#   last, first
#   last
#   first
#   login

sub _generate_default_display_name {
    my($req) = @_;

    my($values) = $req->get_fields('form',
	    ['first_name', 'middle_name', 'last_name', 'name']);
    my($first, $middle, $last, $login) = ($values->{first_name},
	    $values->{middle_name}, $values->{last_name},
	    $values->{name});

=begin

    if ($last) {
	if ($first) {
	    if ($middle) {
		return $last.', '.$first.' '.$middle;
	    }
	    return $last.', '.$first;
	}
	return $last;
    }
    return $first ? $first : $login;

=cut

    if ($last) {
	if ($first) {
	    return $first.' '.$last;
	}
	return $last;
    }
    return $login;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
