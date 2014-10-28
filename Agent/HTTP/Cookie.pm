# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Cookie;
use strict;
use Bivio::Base 'Bivio.Delegator';

# C<Bivio::Agent::HTTP::Cookie> manages the cookie in the HTTP header. It
# allows other interested classes to look at the cookie by calling
# L<register|"register"> on the class.
#
# Cookie delegates much of its implementation to an application specific
# class, defined by the ClassLoader.delegates configuration.

#TODO: Biz.Registrar
my(@_HANDLERS);

sub internal_notify_handlers {
    my($self, $req) = @_;
    foreach my $h (@_HANDLERS) {
	$h->handle_cookie_in($self, $req);
    }
    return;
}

sub new {
    my($proto, $req, $r) = @_;
    my($self) = shift->SUPER::new(@_);
    $self->internal_notify_handlers($req);
    return $self;
}

sub register {
    my($self, $handler) = @_;
    return
	if grep($_ eq $handler, @_HANDLERS);
    push(@_HANDLERS, $handler);
    return;
}

1;
