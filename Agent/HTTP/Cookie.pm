# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Cookie;
use strict;
$Bivio::Agent::HTTP::Cookie::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::HTTP::Cookie::VERSION;

=head1 NAME

Bivio::Agent::HTTP::Cookie - manage HTTP cookies

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::Cookie;
    my($cookie) = Bivio::Agent::HTTP::Cookie->new($req, $r);
    $cookie->header_out($req, $r);

=head1 EXTENDS

L<Bivio::Delegator>

=cut

use Bivio::Delegator;
@Bivio::Agent::HTTP::Cookie::ISA = ('Bivio::Delegator');

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Cookie> manages the cookie in the HTTP header. It
allows other interested classes to look at the cookie by calling
L<register|"register"> on the class.

Cookie delegates much of its implementation to an application specific
class, defined by the ClassLoader.delegates configuration.

=cut

#=IMPORTS
use Bivio::IO::ClassLoader;

#=VARIABLES
my(@_HANDLERS);


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req, Apache::Request r) : Bivio::Agent::HTTP::Cookie

Creates an instance of the Cookie, and its delegate implementation
(handled by Bivio::Delegator). Invokes all handlers registered
for instance notification.

=cut

sub new {
    my($proto, $req, $r) = @_;
    my($self) = shift->SUPER::new(@_);
    $self->internal_notify_handlers($req);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="handle_cookie_in"></a>

=head2 static abstract handle_cookie_in(Bivio::Agent::HTTP::Cookie cookie, Bivio::Agent::Request req)

Processes one or more cookie fields.  Objects/classes should call
L<register|"register"> in their initialization bodies to get upcalled
when a cookie comes in.

This is an interface specification.  This is not a super-class of
cookie handlers.

There may be a I<handle_cookie_out> someday, hence the name of this routine.

=cut

$_ = <<'}'; #emacs
sub handle_cookie_in {
}

=for html <a name="internal_notify_handlers"></a>

=head2 internal_notify_handlers(Bivio::Agent::Request req)

Notify all registered handlers.

=cut

sub internal_notify_handlers {
    my($self, $req) = @_;
    foreach my $h (@_HANDLERS) {
	$h->handle_cookie_in($self, $req);
    }
    return;
}

=for html <a name="register"></a>

=head2 register(proto handler)

Registers a cookie handler if not already registered.   The I<handler> must
support L<handle_cookie_in|"handle_cookie_in">.

=cut

sub register {
    my($self, $handler) = @_;
    return if grep($_ eq $handler, @_HANDLERS);
    push(@_HANDLERS, $handler);
    return;
}

#=PRIVATE METHODS

=head1 SEE ALSO

RFC2616 (HTTP/1.1), RFC1945 (HTTP/1.0), RFC1867 (multipart/form-data),
RFC2109 (Cookies), RFC1806 (Content-Disposition), RFC1521 (MIME)

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
