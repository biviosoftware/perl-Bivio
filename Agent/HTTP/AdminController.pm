# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::AdminController;
use strict;
$Bivio::Agent::HTTP::AdminController::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::HTTP::AdminController - club administration controller

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::AdminController;
    Bivio::Agent::HTTP::AdminController->new();

=cut

=head1 EXTENDS

L<Bivio::Agent::Controller>

=cut

use Bivio::Agent::Controller;
@Bivio::Agent::HTTP::AdminController::ISA = qw(Bivio::Agent::Controller);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::AdminController>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Agent::Request;
use Bivio::Biz::Club;
use Bivio::Biz::ClubUser;
use Bivio::Biz::User;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array views, View default_view) : Bivio::Agent::HTTP::AdminController

Creates the club administration controller which handles the specified
views. If no view is requested, then the controller will use the
specified default_view.

=cut

sub new {
    my($proto, $views, $default_view) = @_;
    my($self) = &Bivio::Agent::Controller::new($proto, $views);
    $self->{$_PACKAGE} = {
	default_view => $default_view->get_name()
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="handle_request"></a>

=head2 handle_request(Request req)

Handles requests for adding and showing club users.

=cut

sub handle_request {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($ret, $club, $club_user) = &_authorize_admin($req);

    if (! $ret) {
	$req->set_state(Bivio::Agent::Request::AUTH_REQUIRED);
	return;
    }

    # set the default view if necessary
    unless ($req->get_view_name()) {
	$req->set_view_name($fields->{default_view});
    }
    my($view) = $self->get_view($req->get_view_name());

    if (defined($view)) {

	my($model) = $view->get_default_model();
	if (scalar(%{$req->get_model_args()})) {
	    $model->find($req->get_model_args());
	}
	elsif ($view->get_name() eq 'users') {
	    $model->find({'club' => $club->get('id')});
	}

	if ($req->get_action_name()) {
	    $model->get_action($req->get_action_name())->execute($model, $req);

	    if ($model->get_status()->is_OK()
		    && $req->get_action_name() eq 'add'
		    && $req->get_view_name() eq 'user') {

		# successful user add
		# need to change to the user list
		$req->set_view_name('users');
		$view = $self->get_view('users');
		$model = $view->get_default_model();
		$model->find({'club' => $club->get('id')});
	    }
	}

	$view->activate()->render($model, $req);
	$req->set_state(Bivio::Agent::Request::OK);
    }
    else {
	&_trace('couldn\'t find view '.$req->get_view_name());
    }
}

#=PRIVATE METHODS

# _authorize_admin(Request req) : (boolean, Club, ClubUser)
#
# Determines if the request is the authorized club administrator.
# Returns (1, club, club_user) if successful, (0) otherwise.

sub _authorize_admin {
    my($req) = @_;

    my($user) = $req->get_user();

    # has the user logged in?
    return (0) if ! $user;

    # do the password's match?
    unless($req->get_password()
	    && $req->get_password() eq $user->get('password')) {
	return (0);
    }

    my($club) = Bivio::Biz::Club->new();
    $club->find({name => $req->get_target_name()});

    # does the club exist?
    return (0) if ! $club->get_status()->is_OK();

    my($club_user) = Bivio::Biz::ClubUser->new();
    $club_user->find({club => $club->get('id'), user => $user->get('id')});

    # is the user a member of the club?
    return (0) if ! $club_user->get_status()->is_OK();

    # is the user an admin of the club?
    return (0) if $club_user->get('role') != 0;

    return (1, $club, $club_user);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
