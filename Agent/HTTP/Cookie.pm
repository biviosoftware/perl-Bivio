# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Cookie;
use strict;
use Bivio::Base 'Bivio::Delegator';
use Bivio::IO::ClassLoader;

# C<Bivio::Agent::HTTP::Cookie> manages the cookie in the HTTP header. It
# allows other interested classes to look at the cookie by calling
# L<register|"register"> on the class.
#
# Cookie delegates much of its implementation to an application specific
# class, defined by the ClassLoader.delegates configuration.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my(@_HANDLERS);


sub internal_notify_handlers {
    # (self, Agent.Request) : undef
    # Notify all registered handlers.
    my($self, $req) = @_;
    foreach my $h (@_HANDLERS) {
	$h->handle_cookie_in($self, $req);
    }
    return;
}

sub new {
    # (proto, Agent.Request, Apache.Request) : HTTP.Cookie
    # Creates an instance of the Cookie, and its delegate implementation
    # (handled by Bivio::Delegator). Invokes all handlers registered
    # for instance notification.
    my($proto, $req, $r) = @_;
    my($self) = shift->SUPER::new(@_);
    $self->internal_notify_handlers($req);
    return $self;
}

sub register {
    # (self, proto) : undef
    # Registers a cookie handler if not already registered.   The I<handler> must
    # support L<handle_cookie_in|"handle_cookie_in">.
    my($self, $handler) = @_;
    return if grep($_ eq $handler, @_HANDLERS);
    push(@_HANDLERS, $handler);
    return;
}

1;
