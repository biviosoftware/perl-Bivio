# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::TestDispatcher;
use strict;
$Bivio::Agent::HTTP::TestDispatcher::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::HTTP::TestDispatcher - an example dispatcher for testing

=head1 SYNOPSIS

    PerlModule Bivio::Agent::HTTP::TestDispatcher
    <LocationMatch "^/\w{3,}($|/)">
    AuthName bivio
    AuthType Basic
    SetHandler perl-script
    PerlHandler Bivio::Agent::HTTP::TestDispatcher
    </LocationMatch>

=cut

=head1 EXTENDS

L<Bivio::Agent::HTTP::Dispatcher>

=cut

use Bivio::Agent::HTTP::Dispatcher;
@Bivio::Agent::HTTP::TestDispatcher::ISA = qw(Bivio::Agent::HTTP::Dispatcher);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::TestDispatcher>

=cut

#=IMPORTS
use Bivio::Agent::HTTP::TestController;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_INITIALIZED) = 0;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::HTTP::TestDispatcher

Creates a new test dispatcher.

=cut

sub new {
    my($self) = &Bivio::Agent::HTTP::Dispatcher::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="create_site"></a>

=head2 create_site()

Overrides the base class to create a simple test site.

=cut

sub create_site {
    my($self) = @_;

    Bivio::IO::Config->initialize();
    my($controller) = Bivio::Agent::HTTP::TestController->new();
    $self->register_controller('test', $controller);
    return;
}

=for html <a name="handler"></a>

=head2 handler(Apache::Request r) : int

The entry point from apache. On the first call this will register itself
as the default Dispatcher and initialize the site.

=cut

sub handler {
    my($r) = @_;

    if (! $_INITIALIZED) {
	Bivio::Agent::HTTP::Dispatcher->set_handler(__PACKAGE__->new());
	$_INITIALIZED = 1;
    }
    # handle the request in the base class (not -> notation)
    return Bivio::Agent::HTTP::Dispatcher::handler($r);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
