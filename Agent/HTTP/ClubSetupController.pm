# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::ClubSetupController;
use strict;
$Bivio::Agent::HTTP::ClubSetupController::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::HTTP::ClubSetupController - club setup controller

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::ClubSetupController;
    Bivio::Agent::HTTP::ClubSetupController->new();

=cut

=head1 EXTENDS

L<Bivio::Agent::Controller>

=cut

use Bivio::Agent::Controller;
@Bivio::Agent::HTTP::ClubSetupController::ISA = qw(Bivio::Agent::Controller);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::ClubSetupController>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array views, View default_view) : Bivio::Agent::HTTP::ClubSetupController

Creates a club setup controller.

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

Handles requests for setting up a club and administrator.

=cut

sub handle_request {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    if ($req->get_target_name() ne 'club') {
	return;
    }

    # set the default view if necessary
    unless ($req->get_view_name()) {
	$req->set_view_name($fields->{default_view});
    }
    my($view) = $self->get_view($req->get_view_name());

    if (defined($view)) {

	my($model) = $view->get_default_model();
	if (! $req->get_model_args()->is_empty()) {
	    $model->find($req->get_model_args());
	}
	if ($req->get_action_name()) {
	    $model->get_action($req->get_action_name())->execute($model, $req);
	    if ($model->get_status()->is_OK()
		    && $req->get_action_name() eq 'add'
		    && $req->get_view_name() eq 'admin') {

		# successful admin add
		# need to change to the club info view
		$req->set_view_name('info');
		$req->set_args({'admin' => $model->get('id')});
		$view = $self->get_view('info');
		$model = $view->get_default_model();
	    }
	    elsif ($model->get_status()->is_OK()
		    && $req->get_action_name() eq 'add'
		    && $req->get_view_name() eq 'info') {

		# successful club add
		# need to change to the final club view
		$req->set_view_name('finish');
		$req->set_args({'club' => $model->get('name')});
		$view = $self->get_view('finish');
		$model = $view->get_default_model();
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

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
