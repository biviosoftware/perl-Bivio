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

our($_TRACE);
Bivio::IO::Trace->register;
Bivio::IO::Config->register(my $_CFG = {
    http_proxy => undef,
    timeout => 60,
});

sub bivio_http_get {
    my($proto, $uri) = @_;
    my($response) = $proto->new
	->bivio_redirect_automatically
	->request(
	    HTTP::Request->new('GET', $uri),
	);
    Bivio::Die->die($response)
	unless $response->is_success;
    return \($response->content);
}

sub bivio_ssl_no_check_certificate {
    my($self) = @_;
    return $self
	unless $self->can('ssl_opts');
    $self->ssl_opts(verify_hostname => 0);
    return $self;
}

sub bivio_redirect_automatically {
    my($self) = @_;
    $self->max_redirect(10);
    $self->requests_redirectable([qw(GET HEAD POST)]);
    return $self;
}

sub handle_config {
    # (proto, hash) : undef
    # http_proxy : string [undef]
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub new {
    my($proto, $want_redirects) = @_;
    my($self) = $proto->SUPER::new;
    $self->timeout($_CFG->{timeout});
    # Use a proxy if configured
    if (defined($_CFG->{http_proxy})) {
        $self->proxy(['http', 'https'], $_CFG->{http_proxy});
    }
    elsif ($ENV{http_proxy}) {
        $self->proxy(['http', 'https'], $ENV{http_proxy});
    }
    if ($want_redirects) {
	Bivio::IO::Alert->warn_deprecated('use bivio_redirect_automatically, instead of passing param to new');
	$self->bivio_redirect_automatically;
    }
    else {
	# Get: Client-Warning: Redirect loop detected (max_redirect = 0)
	# when set to zero, which isn't right, because manually handling redirects
	$self->max_redirect(1);
	$self->requests_redirectable([]);
    }
    $self->bivio_ssl_no_check_certificate
	if Bivio::IO::Config->is_test;
    LWP::Debug::level("+debug") if $_TRACE;
    return $self;
}

1;
