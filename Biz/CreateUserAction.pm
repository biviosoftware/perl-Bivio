# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::CreateUserAction;
use strict;
$Bivio::Biz::CreateUserAction::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::CreateUserAction - creates a new user record

=head1 SYNOPSIS

    use Bivio::Biz::CreateUserAction;
    Bivio::Biz::CreateUserAction->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::CreateUserAction::ISA = qw(Bivio::Biz::Action);

=head1 DESCRIPTION

C<Bivio::Biz::CreateUserAction>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::UserDemographics;
use Bivio::Biz::SqlConnection;
use Bivio::IO::Trace;
use Data::Dumper;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::CreateUserAction

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
		'password fields do not match'));
	return 0;
    }

    my($values) = &_create_field_map($user, $req);

    #TODO: need to have the db assign the id as a sequence
    $values->{'id'} = int(rand(9999999999999998)) + 1;
    $user->create($values);
    if ($user->get_status()->is_OK()) {

	$req->put_arg('user', $user->get('id'));
	my($demographics) = Bivio::Biz::UserDemographics->new();
	$values = &_create_field_map($demographics, $req);

	$demographics->create($values);

	# need to add errors to user, it is what is sent through the system
	foreach (@{$demographics->get_status()->get_errors()}) {
	    $user->get_status()->add_error($_);
	}
    }

    if ($user->get_status()->is_OK()) {
	Bivio::Biz::SqlConnection->get_connection()->commit();
	return 1;
    }
    else {
	Bivio::Biz::SqlConnection->get_connection()->rollback();
	return 0;
    }
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
