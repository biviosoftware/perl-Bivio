# Copyright (c) 2002 bivio Inc.  All rights reserved.
# $Id$
package Bivio::HTML::Scraper;
use strict;
$Bivio::HTML::Scraper::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::HTML::Scraper::VERSION;

=head1 NAME

Bivio::HTML::Scraper - abstracts HTML scraping

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::HTML::Scraper;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::HTML::Scraper::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::HTML::Scraper> abstracts some of the API for HTML
scraping.

=head1 ATTRIBUTES

=over 4

=item cookie_jar : HTTP::Cookies

Cookie holder between requests.

=item directory : string

The directory where the intermediate files are stored.

=item last_uri : string

URI used in last request.  Used to create Referer.

=item login_ok : boolean

Was the login successful?

=item user_agent : Bivio::Ext::LWPUserAgent

The user agent being used for requests.

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::Ext::HTMLParser;
use Bivio::Ext::LWPUserAgent;
use Bivio::HTML;
use Bivio::IO::File;
use Bivio::IO::Trace;
use HTTP::Cookies ();
use HTTP::Request ();
# use URI ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attrs) : Bivio::HTML::Scraper

Creates a new instance of self.

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->put(
	user_agent => Bivio::Ext::LWPUserAgent->new,
	cookie_jar => HTTP::Cookies->new,
	login_ok => 0,
    );
    $self->get('user_agent')->agent(
	'Mozilla/4.0 (compatible; MSIE 5.5; Windows 98)');
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="aa"></a>

=head2 abs_uri(self, string uri) : string

Adds https://blaa, if doesn't already exist and path.
Only works after the first query.

=cut

sub abs_uri {
    my($self, $uri) = @_;
    return $uri if $uri =~ /^https?:/i;
    Bivio::Die->die($uri, ': no last_uri from previous request')
	unless my $last_uri = $self->unsafe_get('last_uri');
    return URI->new_abs($uri, $last_uri)->as_string;
}

=for html <a name="attempt_login"></a>

=head2 abstract attempt_login() : boolean

Logs into the account.

B<Subclasses must implement.>

=cut

$_ = <<'}'; # emacs
sub attempt_login {
}

=for html <a name="client_error"></a>

=head2 client_error(string message, hash_ref args)

Throws a CLIENT_ERROR exception.  Account is added automatically as entity.

=cut

sub client_error {
    my($self, $message, $args) = @_;
    $args ||= {};
    $args->{message} = $message;
    Bivio::Die->throw_die('CLIENT_ERROR', $args);
    # DOES NOT RETURN
}

=for html <a name="encode_form_as_query"></a>

=head2 encode_form_as_query(string uri, array_ref form) : string

Returns a query string from a list of (name, value) pairs, e.g.

    [
        field1 => 'value',
        field2 => undef,
        field3 => 'value3',
    ],

I<uri> should not contain a '?'.

=cut

sub encode_form_as_query {
    my($self, $uri, $form) = @_;
    return $uri.'?'._format_form($form);
}

=for html <a name="extract_content"></a>

=head2 static extract_content(string_ref http_response) : string_ref

Returns content part of I<http_response>.

=cut

sub extract_content {
    my(undef, $http_response) = @_;
    my(undef, $res) = split(/\r?\n\r?\n/, $$http_response, 2);
    return \$res;
}

=for html <a name="file_name"></a>

=head2 file_name(string base_name) : string

Returns the absolute file name for I<base_name>.  Used for storing raw files
associated with download.

Uses I<directory> attribute of self to form name.

=cut

sub file_name {
    my($self, $base_name) = @_;
    return $self->get('directory') . '/' . $base_name;
}

=for html <a name="html_parser_comment"></a>

=head2 html_parser_comment(string comment)

Does nothing.  Subclasses may override, but typically don't care about.

=cut

sub html_parser_comment {
    return;
}

=for html <a name="html_parser_eof"></a>

=head2 html_parser_eof()

Signals end of current parsing.

=cut

sub html_parser_eof {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{html_parser}->eof;
    return;
}

=for html <a name="http_get"></a>

=head2 http_get(string uri, string file_name) : string_ref

Executes an GET and returns the result.

Calls L<http_request|"http_request">.

=cut

sub http_get {
    my($self, $uri, $file_name) = @_;
    return $self->http_request(
	HTTP::Request->new(GET => $self->abs_uri($uri)), $file_name);
}

=for html <a name="http_post"></a>

=head2 http_post(string uri, array_ref form, string file_name) : string_ref

Executes a POST and returns the result.  Encodes I<form>.  I<uri> is
already encoded.  The values will be escaped.

I<form> is an array_ref because there are apps which depend on
the order(!).  The format is:

    [
        field1 => 'value',
        field2 => undef,
        field3 => 'value3',
    ],

If a value is C<undef>, the output will not contain an equals sign.

Calls L<http_request|"http_request">.

=cut

sub http_post {
    my($self, $uri, $form, $file_name) = @_;
    my($hreq) = HTTP::Request->new(POST => $self->abs_uri($uri));
    $hreq->content_type('application/x-www-form-urlencoded');
    $hreq->content(_format_form($form));
    return $self->http_request($hreq, $file_name);
}

=for html <a name="http_request"></a>

=head2 http_request(HTTP::Request hreq, string file_name) : string_ref

Execute I<hreq> and return the response (including headers).  Writes the
result to I<file_name>.

If not successful, throws an exception.

Handles up to four redirects, but then blows up.

=cut

sub http_request {
    my($self, $hreq, $file_name) = @_;
    my($fields) = $self->[$_IDI];
    my($hres) = _http_request($self, $hreq);
    my($rs) = $hres->as_string;
    # Always write the file (even on failure)
    $self->write_file($file_name, \$rs);
    my($hres_string) = \$rs;
    $self->client_error('request failed', {entity => $hres_string})
	    unless $hres->is_success;
    _trace($hres_string) if $_TRACE;
    return $hres_string;
}

=for html <a name="login"></a>

=head2 login()

Calls L<attempt_login|"attempt_login"> if not already logged in.
If attempt_login fails, throws an exception.

=cut

sub login {
    my($self) = @_;
    return $self if $self->get('login_ok');
    $self->client_error('login failure') unless $self->attempt_login;
    $self->put(login_ok => 1);
    return $self;
}

=for html <a name="parse_html"></a>

=head2 parse_html(string_ref content)

Instantiates an L<Bivio::Ext::HTMLParser|Bivio::Ext::HTMLParser>
and initiates parsing.

=cut

sub parse_html {
    my($self, $content) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{html_parser} = Bivio::Ext::HTMLParser->new($self)
	    unless $fields->{html_parser};
    $fields->{html_parser}->parse($$content);
    return;
}

=for html <a name="read_file"></a>

=head2 read_file(string file_name) : string_ref

Returns the contents of I<file_name> from the current directory. Prepends
the name of the institution to the file name.

=cut

sub read_file {
    my($self, $file_name) = @_;
    return Bivio::IO::File->read($self->file_name($file_name));
}

=for html <a name="strip_tags_and_whitespace"></a>

=head2 static strip_tags_and_whitespace(string value) : string

Removes extra and leading whitespace and any html tags.  If value is
C<undef>, returns the empty string.

=cut

sub strip_tags_and_whitespace {
    my($proto, $value) = @_;
    return '' unless defined($value);
    $value =~ s/<[^>]+>//g;
    # Some sites don't always terminate with a ';'
    $value =~ s/&nbsp;?/ /ig;
    # Must be after the tag stripping
    $value = $proto->unescape_html($value);
    $value =~ s/\s+/ /g;
    $value =~ s/^ | $//g;
    return $value;
}

=for html <a name="unescape_html"></a>

=head2 static unescape_html(string value) : string

Calls L<Bivio::HTML::unescape|Bivio::HTML/"unescape"> and fixes up
ISO-88559-1 chars, e.g. \240 (non-breaking-space).

=cut

sub unescape_html {
    shift;
    my($v) = Bivio::HTML->unescape(shift);
    $v =~ s/\240/ /g;
    return $v;
}

=for html <a name="write_file"></a>

=head2 write_file(string file_name, string_ref contents)

Writes I<contents> to I<file_name> in the current directory. Prepends
the name of the institution to the file name.

=cut

sub write_file {
    my($self, $file_name, $contents) = @_;
    return unless $self->unsafe_get('directory');
    Bivio::IO::File->write($self->file_name($file_name), $contents);
    return;
}

#=PRIVATE METHODS

# _format_form(array_ref form) : string
#
# Returns URL encoded form.
#
sub _format_form {
    my($form) = @_;
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

# _http_request(self, HTTP::Request hreq) : HTTP::Response
#
# Tries to redirect up to four times, then dies with too many redirects.
#
sub _http_request {
    my($self, $hreq) = @_;
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
	my($uri);
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

=head1 COPYRIGHT

Copyright (c) 2002 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
