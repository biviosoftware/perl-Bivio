# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Controller;
use strict;

$Bivio::Agent::Controller::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::Controller - Base class for all controllers.

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::Controller::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Agent::Controller> is an abstract class for processing requests.
It is the controllers responsibility to handle requests, invoke actions,
and select a view for output.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array views) : Bivio::Agent::Controller

Creates a new controller which controls the specified views. The views
are available later using the L<"get_view"> method.

=cut

sub new {
    my($proto, $views) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);

    my($view_hash) = {};
    my($view);
    foreach $view (@$views) {
	$view_hash->{$view->get_name()} = $view;
    }

    $self->{$_PACKAGE} = {
	views => $view_hash
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_view"></a>

=head2 get_view(string name) : View

Returns the named view or undef if a view by the name was never added.

=cut

sub get_view {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{views}->{$name};
}

=for html <a name="handle_request"></a>

=head2 abstract handle_request(Request r)

Acts on a request and performs actions on a model, then renders
the result.

=cut

sub handle_request {
    die("abstract method");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
