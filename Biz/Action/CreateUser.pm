# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::CreateUser;
use strict;
$Bivio::Biz::CreateUserAction::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
use Bivio::Biz::Club;
use Bivio::Biz::ClubUser;
use Bivio::Biz::FindParams;
use Bivio::Biz::UserDemographics;
use Bivio::Biz::UserEmail;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Action::CreateUser

Creates an action for creating bivio users.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::Action::new($proto, 'add', 'Add User',
	   'Adds a new user to the club', '/i/new.gif');
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(User user, Request req) : boolean

Creates a new user record in the database using values specified in the
request.

=cut

sub execute {
    my($self, $user, $req) = @_;

    # make sure password fields match
    if ($req->get_arg('password') ne $req->get_arg('confirm_password')) {
	$user->get_status()->add_error(Bivio::Biz::Error->new(
		'password fields did not match'));
	$req->put_arg('password', '');
	return 0;
    }

    eval {
#TODO: need to have the db assign the id as a sequence
	$req->put_arg('id', int(rand(999999)) + 1);

	my($values) = &_create_field_map($user, $req);

	$user->create($values);
	if ($user->get_status()->is_ok()) {

	    $req->put_arg('user_', $user->get('id'));
	    my($demographics) = Bivio::Biz::UserDemographics->new();
	    $values = &_create_field_map($demographics, $req);

	    $demographics->create($values);

	    # need to add errors to user, it is what is sent through the system
	    foreach (@{$demographics->get_status()->get_errors()}) {
		$user->get_status()->add_error($_);
	    }

	    if ($user->get_status()->is_ok()) {
		# the same for email
		my($email) = Bivio::Biz::UserEmail->new();
		$values = &_create_field_map($email, $req);

		$email->create($values);

		foreach (@{$email->get_status()->get_errors()}) {
		    $user->get_status()->add_error($_);
		}
	    }

	    #HACK: ignoring for club setup
	    # add the user to the club if necessary
	    if ($user->get_status()->is_ok()
		    && $req->get_target_name() ne 'club') {

		# not checking find result, should have succeeded or
		# it wouldn't be this far
		my($club_user) = Bivio::Biz::ClubUser->new();

		$club_user->create({
		    'club' => $req->get('club')->get('id'),
		    'user_' => $user->get('id'),
		    'role' => $req->get_arg('role'),
		    'email_mode' => 1
		});

		foreach (@{$club_user->get_status()->get_errors()}) {
		    $user->get_status()->add_error($_);
		}
	    }
	}
    };

    # check for exceptions
    if ($@) {
	Bivio::SQL::Connection->rollback();
	die($@);
    }

    if ($user->get_status()->is_ok()) {
	Bivio::SQL::Connection->commit();
	return 1;
    }

    Bivio::SQL::Connection->rollback();
    return 0;
}

#=PRIVATE METHODS

# _create_field_map(PropertyModel model, Request req) : hash
#
# Creates a hash of model fields which exist in the specified request.

sub _create_field_map {
    my($model, $req) = @_;

    my($result) = {};
    my($fields) = $model->get_field_names();

    foreach (@$fields) {
	$result->{$_} = $req->get_arg($_);
    }
    return $result;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
