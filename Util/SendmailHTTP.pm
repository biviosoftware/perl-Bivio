# Copyright (c) 2014-2017 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Util::SendmailHTTP;
use strict;
use HTTP::Request::Common ();
use LWP::UserAgent ();

my($_MAP_REPLY) = {
    200 => ['EX_OK'],
    204 => ['EX_OK'],
    302 => ['EX_OK'],
    400 => [EX_DATAERR => 'Bad Request'],
    401 => [EX_NOPERM => 'Unauthorized Access'],
    403 => [EX_NOPERM => 'Access Forbidden'],
    404 => [EX_NOUSER => 'User Not Found'],
    409 => [EX_TEMPFAIL => 'Resource Conflict'],
    500 => [EX_SOFTWARE => 'Internal Server Error'],
    502 => [EX_TEMPFAIL => 'Gateway not reachable'],
    503 => [EX_TEMPFAIL => 'Gateway not reachable'],
};
my($_SYSEXIT) = {
    EX_OK => 0,
    EX_DATAERR => 65,
    EX_NOUSER => 67,
    EX_SOFTWARE => 70,
    EX_TEMPFAIL => 75,
    EX_NOPERM => 77,
    EX_CONFIG => 78,
};
my $_CFG = {
    lwp_timeout_seconds => 1800,
};

sub create_http_request {
    my($proto, $client_addr, $recipient, $url, $msg) = @_;
    return HTTP::Request::Common::POST(
	'http://' . $url,
	Content_Type => 'form-data',
	Content => [
	    v => 2,
	    client_addr => $client_addr,
	    recipient => $recipient,
	    message => [
		undef, undef,
		Content => $$msg,
		'Content-Type' => 'message/rfc822',
	    ],
	],
	Via => $client_addr,
    );
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub main {
    # Usage: b-sendmail-http client-addr recipient host:port/url
    # /usr/bin/b-sendmail-http ${client_address} ${recipient} localhost.localdomain:80/_mail_receive/%s
    my($proto) = shift;
    my($res, $client_addr, $recipient, $url) = $proto->validate_main_args(@_);
    return $res
	unless _is_ok($res);
    return $recipient =~ /^ignore-/is
	? $res
	: _map_http_reply(
	    $proto,
	    _send_http_request(
		$proto,
		$proto->create_http_request(
		    $client_addr, $recipient, $url, _read_stdin(),
		),
	    ),
	);
}

sub validate_main_args {
    my($proto, $client_addr, $recipient, $http_server, @local_agent) = @_;

    unless ($http_server) {
	return _fail_with_error(
	    'EX_TEMPFAIL',
	    "Error: too few arguments\n",
	    "Usage: b-sendmail-http client-addr recipient host:port/url local_agent local_agent_args...",
	);
    }
    my($res, $url) = _parse_url($proto, $http_server, $recipient);
    return $res
	unless _is_ok($res);

    if (length($recipient) > 255) {
	return _fail_with_error(
	    'EX_DATAERR',
	    'recipient name (len=', length($recipient), ") too long",
	);
    }
    if ($local_agent[0] !~ m{\bfalse\b} && _is_local_user($proto, $recipient)) {
	exec(@local_agent);
    }
    return ($res, $client_addr || '127.0.0.1', $recipient, $url);
}

sub _fail_with_error {
    my($err, @msg) = @_;
    print(STDERR @msg, "\n");
    return $_SYSEXIT->{$err};
}

sub _is_local_user {
    my($proto, $recipient) = @_;
    $recipient =~ s/^(.*?)\@.*$/$1/;
    $recipient =~ s/^(.*?)\+.*$/$1/;
    return getpwnam($recipient) ? 1 : 0;
}

sub _is_ok {
    my($res) = @_;
    return $res == $_SYSEXIT->{EX_OK} ? 1 : 0;
}

sub _map_http_reply {
    my($proto, $code) = @_;
#TODO: save off 500 error messages, return fatal error
    my($reply) = $_MAP_REPLY->{$code};
    return _fail_with_error(
	'EX_TEMPFAIL',
	'Unknown server reply code: ', $code,
    ) unless $reply;
    my($res, $err) = @$reply;
    return $err
	? _fail_with_error($res, $err)
	: $_SYSEXIT->{$res};
}

sub _parse_url {
    my($proto, $http_server, $recipient) = @_;
    my($host, $url) = $http_server =~ m,^(.*?)(/.*)$,;
    unless ($host && $url) {
	return _fail_with_error(
	    'EX_CONFIG',
	    $http_server . " not in host:port/url format",
	);
    }
    unless ($url =~ /\%s/) {
	return _fail_with_error(
	    'EX_CONFIG',
	    'url missing %s: ', $url,
	);
    }
    return (
	$_SYSEXIT->{EX_OK},
	$host . sprintf($url, $recipient),
    );
}

sub _read_stdin {
    my($file) = IO::File->new('<-') or die("open stdin: $!");
    binmode($file);
    my($offset, $read, $buf) = (0, 0, '');
    $offset += $read
	while $read = CORE::read($file, $buf, 0x1000, $offset);
    defined($read)
	or die("read stdin: $!");
    close($file)
	or die("close(stdin): $!");
    return \$buf;
}

sub _send_http_request {
    my($proto, $http_req) = @_;
    my($agent) = LWP::UserAgent->new;
    $agent->timeout($_CFG->{lwp_timeout_seconds});
    $agent->requests_redirectable([]);
    $agent->agent('b-sendmail-http');
    my($response) = $agent->request($http_req);
    # if response has no headers, it has a status "200 Assumed OK"
    return $response->status_line =~ /assumed ok/i
	? 500
	: $response->code;
}

1;
