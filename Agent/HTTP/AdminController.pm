# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::AdminController;
use strict;
$Bivio::Agent::HTTP::AdminController::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::AdminController - club administration controller

=head1 EXTENDS

L<Bivio::Agent::Controller>

=cut

use Bivio::Agent::Controller;
@Bivio::Agent::HTTP::AdminController::ISA = qw(Bivio::Agent::Controller);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::AdminController>

=cut

#=IMPORTS
use Bivio::Agent::HTTP::Auth;
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
    my($self) = &Bivio::Agent::Controller::new($proto, $views, $default_view);
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

    my($club, $club_user) = Bivio::Agent::HTTP::Auth->authorize_admin($req);

    if (! $club) {
	$req->get_reply()->set_state($req->get_reply()->AUTH_REQUIRED);
	return;
    }

    # set the default view if necessary
    unless ($req->get_view_name()) {
	$req->set_view_name($self->get_default_view_name());
    }
    my($view) = $self->get_view($req->get_view_name());

    if ($view) {

	my($model) = $view->get_default_model();
	my($fp) = $req->get_model_args();
	$fp->put('club', $club->get('id'));

	if ($view->get_name eq 'users') {
	    $model->load($fp);
	}

	if ($req->get_action_name()) {
	    $model->get_action($req->get_action_name())->execute($model, $req);

	    if ($model->get_status()->is_ok()
		    && $req->get_action_name() eq 'add'
		    && $req->get_view_name() eq 'user') {

		# successful user add
		# need to change to the user list
		$req->set_view_name('users');
		$view = $self->get_view('users');
		$model = $view->get_default_model();
		$model->load(Bivio::Biz::FindParams->new(
			{'club' => $club->get('id')}));
	    }
	}

	$view->activate()->render($model, $req);

	my($reply) = $req->get_reply();
	if ($reply->get_state() == $reply->NOT_HANDLED) {
	    $reply->set_state($reply->OK);
	}
    }
    else {
	&_trace('couldn\'t find view '.$req->get_view_name());
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
