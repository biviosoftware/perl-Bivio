# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::MessageController;
use strict;
$Bivio::Agent::HTTP::MessageController::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::MessageController - a message board controller

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::MessageController;
    Bivio::Agent::HTTP::MessageController->new();

=cut

=head1 EXTENDS

L<Bivio::Agent::Controller>

=cut

use Bivio::Agent::Controller;
@Bivio::Agent::HTTP::MessageController::ISA = qw(Bivio::Agent::Controller);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::MessageController>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Agent::Request;
use Bivio::Biz::Club;
use Bivio::Biz::ClubUser;
use Bivio::Biz::FindParams;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array views, View default_view) : Bivio::Agent::HTTP::MessageController

Creates a message and message list controller.

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

    my($club, $club_user) =
	    Bivio::Agent::HTTP::Auth->authorize_club_user($req);

    if (! $club) {
	$req->set_state(Bivio::Agent::Request::AUTH_REQUIRED);
	return;
    }

    # set the default view if necessary
    unless ($req->get_view_name()) {
	$req->set_view_name($fields->{default_view});
    }
    my($view) = $self->get_view($req->get_view_name());

    # get a model from the view,
    # load it with data from the request,
    # show the view of it

    if ($view) {
	my($model) = $view->get_default_model();
	my($fp) = $req->get_model_args();
	$fp->put('club', $club->get('id'));
	$model->find($fp); # error handling done by view
	$view->activate()->render($model, $req);
	$req->set_state(Bivio::Agent::Request::OK);
    }
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
