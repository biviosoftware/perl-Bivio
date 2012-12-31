# Copyright (c) 2001-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Ext::LWPUserAgent;
use strict;
use base 'LWP::UserAgent';
use Bivio::IO::Config;
use Bivio::IO::Trace;
use LWP::Debug ();

# C<Bivio::Ext::LWPUserAgent> adds timeouts and proxy handling to LWP::UserAgent.
#
# If you trace this module, also turns on tracing in LWP::Debug.  See
# L<new|"new">.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_PKG) = __PACKAGE__;
Bivio::IO::Trace->register;
my($_HTTP_PROXY);
Bivio::IO::Config->register(my $_CFG = {
    http_proxy => undef,
    timeout => 60,
});

sub bivio_http_get {
    my($proto, $uri) = @_;
    my($response) = $proto->new(1)
	->request(
	    HTTP::Request->new('GET', $uri),
	);
    Bivio::Die->die($response)
	unless $response->is_success;
    return \($response->content);
}

sub handle_config {
    # (proto, hash) : undef
    # http_proxy : string [undef]
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub new {
    # (proto, boolean) : Ext.LWPUserAgent
    # Calls SUPER::new and sets timeout and proxy.
    #
    # If I<want_redirects> is true, L<redirect_ok|"redirect_ok"> will return true.
    #
    # Turns on LWP::Debug if $_TRACE is true for this class.
    my($proto, $want_redirects) = @_;
    my($self) = $proto->SUPER::new;
    my($fields) = $self->{$_PKG} = {
	want_redirects => $want_redirects ? 1 : 0,
    };
    # Relatively short timeout, so we don't get stuck in remote services.
    $self->timeout($_CFG->{timeout});
    # Use a proxy if configured
    if (defined($_CFG->{http_proxy})) {
        $self->proxy(['http', 'https'], $_CFG->{http_proxy});
    }
    elsif ($ENV{http_proxy}) {
        $self->proxy(['http', 'https'], $ENV{http_proxy});
    }
    LWP::Debug::level("+debug") if $_TRACE;
    return $self;
}

sub redirect_ok {
    # (self) : boolean
    # Always returns false.  Redirects need to be handled at higher level for cookies
    # and logging.
    return shift->{$_PKG}->{want_redirects};
}

1;
