# Copyright (c) 2002-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::HTML::Scraper;
use strict;
use Bivio::Base 'Collection.Attributes';
use Bivio::HTML;
use Bivio::IO::File;
use Bivio::IO::Trace;
use HTTP::Cookies ();
use HTTP::Request ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
# use URI ();
our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;

sub abs_uri {
    my($self, $uri) = @_;
    # Adds https://blaa, if doesn't already exist and path.
    # Only works after the first query.
    return $uri if $uri =~ /^https?:/i;
    Bivio::Die->die($uri, ': no last_uri from previous request')
	unless my $last_uri = $self->unsafe_get('last_uri');
    return URI->new_abs($uri, $last_uri)->as_string;
}

sub client_error {
    my($self, $message, $args) = @_;
    # Throws a CLIENT_ERROR exception.  Account is added automatically as entity.
    $args ||= {};
    $args->{message} = $message;
    Bivio::Die->throw_die('CLIENT_ERROR', $args);
    # DOES NOT RETURN
}

sub encode_form_as_query {
    my($self, $uri, $form) = @_;
    # Returns a query string from a list of (name, value) pairs, e.g.
    #
    #     [
    #         field1 => 'value',
    #         field2 => undef,
    #         field3 => 'value3',
    #     ],
    #
    # I<uri> should not contain a '?'.
    return $uri.'?'._format_form($form);
}

sub extract_content {
    my(undef, $http_response) = @_;
    # Returns content part of I<http_response>.
    my(undef, $res) = split(/\r?\n\r?\n/, $$http_response, 2);
    return \$res;
}

sub file_name {
    my($self, $base_name) = @_;
    # Returns the absolute file name for I<base_name>.  Used for storing raw files
    # associated with download.
    #
    # Uses I<directory> attribute of self to form name.
    return $self->get('directory') . '/' . $base_name;
}

sub html_parser_comment {
    # Does nothing.  Subclasses may override, but typically don't care about.
    return;
}

sub html_parser_end {
    # Does nothing.  Subclasses should override.
    return;
}

sub html_parser_eof {
    my($self) = @_;
    # Signals end of current parsing.
    my($fields) = $self->[$_IDI];
    $fields->{html_parser}->eof;
    return;
}

sub html_parser_start {
    # Does nothing.  Subclasses should override.
    return;
}

sub html_parser_text {
    my($self) = shift;
    # Appends to stored text.  Used by to_text().
    $self->[$_IDI]->{to_text}
	.= $self->strip_tags_and_whitespace(shift(@_)) . "\n";
    return;
}

sub http_get {
    my($self, $uri, $file_name) = @_;
    # Executes an GET and returns the result.
    #
    # Calls L<http_request|"http_request">.
    return $self->http_request(
	HTTP::Request->new(GET => $self->abs_uri($uri)), $file_name);
}

sub http_post {
    my($self, $uri, $form, $file_name) = @_;
    # Executes a POST and returns the result.  Encodes I<form>.  I<uri> is
    # already encoded.  The values will be escaped.
    #
    # I<form> is an array_ref because there are apps which depend on
    # the order(!).  The format is:
    #
    #     [
    #         field1 => 'value',
    #         field2 => undef,
    #         field3 => 'value3',
    #     ],
    #
    # If a value is C<undef>, the output will not contain an equals sign.
    #
    # Calls L<http_request|"http_request">.
    my($hreq) = HTTP::Request->new(POST => $self->abs_uri($uri));
    $hreq->content_type('application/x-www-form-urlencoded');
    $hreq->content(_format_form($form));
    return $self->http_request($hreq, $file_name);
}

sub http_request {
    my($self, $hreq, $file_name) = @_;
    my($fields) = $self->[$_IDI];
    my($u, $p) = $self->unsafe_get(qw(auth_user auth_password));
    $hreq->header(Authorization => 'Basic ' . MIME::Base64::encode("$u:$p"))
	if $u;
    my($hres) = _http_request($self, $hreq);
    my($rs) = $hres->as_string;
    # Always write the file (even on failure)
    $self->write_file($file_name, \$rs)
        if defined($file_name);
    my($hres_string) = \$rs;
    $self->client_error('request failed', {entity => $hres_string})
	unless $hres->is_success;
    $self->put(login_ok => 1)
	if $u;
    _trace($hres_string) if $_TRACE;
    return $hres_string;
}

sub login {
    my($self) = @_;
    # Calls L<attempt_login|"attempt_login"> if not already logged in.
    # If attempt_login fails, throws an exception.
    return $self
	if $self->get('login_ok');
    $self->client_error('login failure')
	unless $self->attempt_login;
    $self->put(login_ok => 1);
    return $self;
}

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->put(
	user_agent => b_use('Ext.LWPUserAgent')->new,
	cookie_jar => HTTP::Cookies->new,
	login_ok => 0,
    );
    $self->get('user_agent')->agent(
	'Mozilla/4.0 (compatible; MSIE 5.5; Windows 98)');
    $self->[$_IDI] = {};
    return $self;
}

sub parse_html {
    my($self, $content) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{html_parser} = b_use('Ext.HTMLParser')->new($self)
	unless $fields->{html_parser};
    $fields->{html_parser}->parse($$content);
    return;
}

sub read_file {
    my($self, $file_name) = @_;
    # Returns the contents of I<file_name> from the current directory.
    return Bivio::IO::File->read($self->file_name($file_name));
}

sub strip_tags_and_whitespace {
    my($proto, $value) = @_;
    # Removes extra and leading whitespace and any html tags.  If value is
    # C<undef>, returns the empty string.
    return '' unless defined($value);
    #convert <br> to a space, globally.
    $value =~ s/<br>/ /ig;
    $value =~ s/<[^>]+>//g;
    # Some sites don't always terminate with a ';'
    $value =~ s/&nbsp;?/ /ig;
    # Must be after the tag stripping
    $value = $proto->unescape_html($value);
    $value =~ s/\s+/ /g;
    $value =~ s/^ | $//g;
    return $value;
}

sub to_text {
    my($self) = shift->SUPER::new;
    # Converts I<html> to plain text.
    my($fields) = $self->[$_IDI] = {
	to_text => '',
    };
    $self->parse_html(shift(@_));
    return \$fields->{to_text};
}

sub unescape_html {
    # Calls L<Bivio::HTML::unescape|Bivio::HTML/"unescape"> and fixes up
    # ISO-88559-1 chars, e.g. \240 (non-breaking-space).
    shift;
    my($v) = Bivio::HTML->unescape(shift);
    $v =~ s/\240/ /g;
    return $v;
}

sub write_file {
    my($self, $file_name, $contents) = @_;
    # Writes I<contents> to I<file_name> in the current directory.
    return unless $self->unsafe_get('directory');
    Bivio::IO::File->write($self->file_name($file_name), $contents);
    return;
}

sub _format_form {
    my($form) = @_;
    # Returns URL encoded form.
    my($res) = '';
    my($sep) = '';
    Bivio::Die->die('expecting even number of elements') if int(@$form) % 2;
    foreach my $i (@$form) {
	$res .= $sep.Bivio::HTML->escape_query($i) if defined($i);
	# Works first time through, because we compare to '='
	$sep = $sep eq '=' ? '&' : '=';
    }
    return $res;
}

sub _http_request {
    my($self, $hreq) = @_;
    # Tries to redirect up to four times, then dies with too many redirects.
    my(@uris);
    my($uri) = $hreq->uri->as_string;
    # Only allow 5 redirects
    foreach my $iteration (1..5) {
	push(@uris, $uri);
	# We save the host
	$self->get('cookie_jar')->add_cookie_header($hreq);
	$hreq->referer($self->get('last_uri'))
	    if $self->has_keys('last_uri');
	$self->put(last_uri => $uri);
	_trace($hreq) if $_TRACE;
	my($hres) = $self->get('user_agent')->request($hreq);
	_trace($hres) if $_TRACE;
	$self->get('cookie_jar')->extract_cookies($hres);
	if ($hres->is_redirect) {
	    $uri = $hres->header('Location');
	    $self->client_error('unable to parse Locations header', {
		entity => $uri,
	    }) unless $uri;
	}
	else {
	    return $hres unless $hres->is_success;
	    # AOL uses Refresh: instead of Location:
	    my($header) = $hres->header('Refresh');
	    return $hres unless $header;
	    $self->client_error('unable to parse refresh header', {
		entity => $header,
		uri => $uri,
	    }) unless $header =~ /^\s*(\d+)\s*;\s*URL\s*=\s*(\S+)/i;
	    # Arbitrary cutoff.  If the refresh is too long, it probably isn't
	    # about redirects, let the client handle it.
	    return $hres unless $1 < 10;
	    $uri = $2;
	}
        $uri = $self->abs_uri($uri);
	_trace('redirect: ', $uri) if $_TRACE;
	$hreq = HTTP::Request->new(GET => $uri);
    }
    $self->client_error('too many redirects', {entity => \@uris,});
    # DOES NOT RETURN
}

1;
