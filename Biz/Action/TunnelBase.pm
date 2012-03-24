# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::TunnelBase;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::IO::Trace;
use HTTP::Request ();
use IO::File ();
use LWP::UserAgent ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_READ_SIZE) = 100_000;

sub clear_cookie {
    my($proto, $req) = @_;
    $req->get('cookie')->delete($proto->URI_NAME);
    return;
}

sub get_request {
    my($self) = @_;
    return $self->get('request');
}

sub internal_add_reply_header {
    my($self, $name, $value) = @_;
    return unless defined($value);
    $self->req('reply')
	->get_if_defined_else_put(headers => {})->{$name} = $value;
    return;
}

sub internal_email {
    my($self) = @_;
    return $self->use('Model.Email')->new($self->req)->unauth_load_or_die({
	realm_id => $self->req('auth_user_id'),
    })->get('email');
}

sub internal_host_name {
    my($self) = @_;
#TODO: isto facades have the wrong http_host values, hack the value together
    my($host) = $self->use('Bivio::UI::Facade')
	->get_value('http_host', $self->req);
    my($port) = $host =~ /\:(\d+)$/;
    $host = $self->req('r')->hostname . ($port ? (':' . $port) : '');
    return $host;
}

sub internal_proxy_request {
    my($self, $uri) = @_;
    my($req) = $self->req;
    my($r) = $req->get('r');
    my($request) = HTTP::Request->new($r->method =>
	$self->get('site_base') . $uri
	. ($req->get('uri') =~ m,/$, ? '/' : '')
	. ($req->get('query') ? ('?' . scalar($r->args)) : ''));
    my($length) = $r->header_in('content-length');
    _trace('length: ', $length) if $_TRACE;
    if ($length && $length > $_READ_SIZE) {
	my($file) = b_use('IO.File')->temp_file($self->req);
	my($fh) = IO::File->new($file, 'w');
	$self->req->get_content($fh);
	$fh->close;
	$fh = IO::File->new($file, 'r');
	$request->content('');
	my($res);
	while (1) {
	    my($buf) = '';
	    last
		unless $res = $fh->read($buf, $_READ_SIZE);
	    $request->add_content($buf);
	}
	b_use('Bivio.Die')->throw_die(IO_ERROR => {
	    message => "$!",
	    operation => 'read',
	    entity => $file,
	}) unless defined($res);
	$fh->close;
    }
    else {
	$request->content(${$req->get_content});
    }
    my(%h) = $r->headers_in;
    foreach my $name (keys(%h)) {
	$request->header($name => $r->header_in($name));
    }
    return $request;
}

sub internal_send_http_request {
    my($self, $http_req, $die_on_failure) = @_;
    $http_req->header(Host => $self->get('host'));
    my($cookies) = _get_cookies($self);
    $http_req->header(Cookie => join('; ',
	map(join('=', $_, $cookies->{$_}), keys(%$cookies))))
	if %$cookies;
    _trace($http_req->as_string) if $_TRACE;
    my($user_agent) = LWP::UserAgent->new;
    $user_agent->requests_redirectable([]);
    my($response) = $user_agent->request($http_req,
	$self->unsafe_get('response_file') || ());

    if ($die_on_failure) {
	Bivio::Die->die('request failed: ', $response->status_line)
	    unless $response->is_success || $response->is_redirect;
    }
    _save_cookies($self, $response);
    return $response;
}

sub internal_set_reply {
    my($self, $response) = @_;

    foreach my $name (qw(Location Last-Modified)) {
	$self->internal_add_reply_header(
	    map(($_, $response->header($_)), $name));
    }
    my($reply) = $self->req('reply');
    $reply->set_http_status($response->code);
    $reply->set_output_type($response->header('Content-Type'));

    unless ($self->unsafe_get('response_file')
	&& -f $self->get('response_file')
	&& ! -z $self->get('response_file')) {
	my($res) = $response->content_ref;
	$reply->set_output($res);
	return $res;
    }
    $reply->set_output(IO::File->new($self->get('response_file'), 'r'));
    return undef;
}

sub internal_translate_location {
    my($self, $response, $transfer_uri_base) = @_;
    my($value) = $response->header('Location');
    return undef unless $value;
    my($realm_name) = $self->req(qw(auth_realm owner name));

    # pass along a transfer to a different tunnel
    return $value
	if $value =~ m,//[^/]+/$realm_name/$transfer_uri_base/,;
    _replace(\$value, '^' . $self->get('scheme'),
	$self->req->unsafe_get('is_secure') ? 'https' : 'http')
	|| Bivio::Die->die('invalid location scheme: ', $value);
    _replace(\$value, $self->get('host'), $self->internal_host_name)
	|| Bivio::Die->die('invalid location host: ', $value);
    my($uri_name) = $self->URI_NAME;
    $value =~ s,(.*?\w/),$1$realm_name/$uri_name/,
	|| Bivio::Die->die('name substitution failed: ', $value);
    return $value;
}

sub internal_username {
    my($self) = @_;
    my($name) = $self->req(qw(auth_user name));

    # fixup to test user names (adm, bunit, etc.)
    if (length($name) < 8) {
	$name .= '0' x (8 - length($name));
    }
    return $name;
}

sub _get_cookies {
    my($self) = @_;
    return $self->use('Type.Hash')->from_sql_column(
	$self->req('cookie')->unsafe_get($self->URI_NAME) || '{}');
}

sub _replace {
    my($value, $old, $new) = @_;
    return $$value =~ s,$old,$new,;
}

sub _save_cookies {
    my($self, $response) = @_;
    return unless $response->header('Set-Cookie');
    my($cookies) = _get_cookies($self);

    foreach my $cookie ($response->header('Set-Cookie')) {
	$cookie =~ s,\; Path=/\S*$,,i
	    || Bivio::Die->die('missing cookie path: ', $cookie);
	$cookie =~ s,\; Expires=.*$,,i;
	my($k, $v) = $cookie =~ /^(.*?)=(.*)$/;
	Bivio::Die->die('unparsable cookie: ', $cookie)
		unless $k;
	$cookies->{$k} = $v;
    }
    $self->req('cookie')->put($self->URI_NAME =>
	$self->use('Type.Hash')->to_sql_param($cookies));
    return;
}

1;
