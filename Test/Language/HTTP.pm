# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Language::HTTP;
use strict;
$Bivio::Test::Language::HTTP::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Language::HTTP::VERSION;

=head1 NAME

Bivio::Test::Language::HTTP - support for HTTP tests

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Language::HTTP;

=cut

=head1 EXTENDS

L<Bivio::Test::Language>

=cut

use Bivio::Test::Language;
@Bivio::Test::Language::HTTP::ISA = ('Bivio::Test::Language');

=head1 DESCRIPTION

C<Bivio::Test::Language::HTTP> contains support for HTTP tests.

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::Die;
use Bivio::Ext::LWPUserAgent;
use Bivio::IO::Trace;
use Bivio::Test::HTMLParser;
use HTTP::Cookies ();
use HTTP::Request ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_IDI) = __PACKAGE__->instance_data_index;
Bivio::IO::Config->register(my $_CFG = {
    home_page_uri => Bivio::IO::Config->REQUIRED,
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Test::Language lang, string uri) : Bivio::Test::HTTP::Page

Creates a new page, loaded from the specified URI.

=cut

sub new {
    my($proto, $lang, $uri) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
	cookies => HTTP::Cookies->new,
	user_agent => Bivio::Ext::LWPUserAgent->new,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="goto_link"></a>

=head2 goto_link(string link_name)

Loads the page for the L<link_name|"link_name">

=cut

sub goto_link {
    my($self, $link_text) = @_;
    $self->goto_uri(
	_assert_html($self)->get_nested('Links', $link_text, 'href'));
    return;
}

=for html <a name="goto_uri"></a>

=head2 goto_uri(string uri)

Loads the page using the specified URI.

=cut

sub goto_uri {
    my($self, $uri) = @_;
    _trace($uri) if $_TRACE;
    _send_request($self, HTTP::Request->new(GET => _fixup_uri($self, $uri)));
    return;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item home_page_uri : string (required)

URI of home page.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

=for html <a name="home_page"></a>

=head2 home_page()

Requests the the home page.

=cut

sub home_page {
    return shift->goto_uri($_CFG->{home_page_uri});
}

=for html <a name="submit_form"></a>

=head2 submit_form(string submit_button, hash_ref form_fields)

Submits I<form_fields> using I<submit_button>. Only fields specified will be
sent.

B<File upload not supported yet.>

=cut

sub submit_form {
    my($self, $submit_button, $form_fields) = @_;
    my($fields) = $self->[$_IDI];
    my($form) = _assert_html($self)->get('Forms')
	->get_by_field_names(keys(%$form_fields), $submit_button);
    my($request) = HTTP::Request->new(uc($form->{method})
	=> _fixup_uri($self, $form->{action}));
    $request->content_type('application/x-www-form-urlencoded');
    $request->content(_format_form($form, $submit_button, $form_fields));
    _send_request($self, $request);
    _assert_form_response($self);
    return;
}

=for html <a name="verify_text"></a>

=head2 verify_text(string text)

Verifies that the specified text appears on the page.

=cut

sub verify_text {
    my($self, $text) = @_;
    Bivio::Die->die($text, ': text not found in response')
	unless _assert_response($self)->content =~ /$text/;
    return;
}

#=PRIVATE SUBROUTINES

# _assert_form_field(hash_ref form, string class, string name) : string
#
# Returns the named field from form->class or dies.
#
sub _assert_form_field {
    my($form, $class, $name) = @_;
    return $form->{$class}->{$name}
	|| Bivio::Die->die($name, ': field not found in ', $class, ' of form ',
	    $form->{label});
}

# _assert_form_response(self)
#
# Asserts result of form is valid.
#
sub _assert_form_response {
    my($self) = @_;
    my($forms) = _assert_html($self)->get('Forms')->get_shallow_copy;
    while (my($k, $v) = each(%$forms)) {
	Bivio::Die->die('form submission errors: ', $v->{errors})
            if $v->{errors};
    }
    return;
}

# _assert_html(self) : Bivio::Test::HTMLParser
#
# Asserts HTML and returns parser
#
sub _assert_html {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $fields->{html_parser}
	|| Bivio::Die->die(_assert_response
	    _assert_response($self)->content_type, ': response not html');
}

# _assert_response(self) : HTTP::Message
#
# Asserts response is valid.
#
sub _assert_response {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $fields->{response} || Bivio::Die->die('no valid response');
}

# _fixup_uri(self, string uri) : string
#
# Add in the current URI prefix if not present.
#
sub _fixup_uri {
    my($self, $uri) = @_;
    my($fields) = $self->[$_IDI];

    unless ($uri =~ m,://,) {
	Bivio::Die->die("couldn't find http prefix: ", $fields->{uri})
		unless $fields->{uri} =~ m,^([^/]+//[^/]+)/?,;
	my($prefix) = $1;
	$uri = $prefix.$uri;
    }
    return $uri;
}

# _format_field(hash_ref field, string value) : string
#
# Formats the field as $name=$value&
#
sub _format_field {
    my($field, $value) = @_;
    Bivio::Die->die($value, ': invalid value for field ', $field->{name})
	 if ref($value);
    return Bivio::HTML->escape_query($field->{name}) . '='
	   . (defined($value) ? Bivio::HTML->escape_query($value) : '') . '&';
}

# _format_form(hash_ref form, string submit,  hash_ref form_fields) : string
#
# Returns URL encoded form.
#
sub _format_form {
    my($form, $submit, $form_fields) = @_;
    my($res) = '';
    while (my($k, $v) = each(%{$form->{hidden}})) {
	$res .= _format_field($v, $v->{value});
    }
    while (my($k, $v) = each(%$form_fields)) {
	$res .= _format_field(_assert_form_field($form, 'visible', $k), $v);
    }
    $res .= _format_field(_assert_form_field($form, 'submit', $submit));
    chop($res);
    return $res;
}

# _log(self, string type, HTTP::Message msg)
#
# Writes the HTTP message to a file with a nice suffix.  Preserves file
# ordering.
#
sub _log {
    my($self, $type, $msg) = @_;
    my($fields) = $self->[$_IDI];
    $self->test_log_output(
	sprintf('http-%05d.%s', $fields->{log_index}++, $type),
	$msg->as_string);
    return;
}

# _send_request(self, HTTP::Request request)
#
# Sends the specified request.  Handles redirects, because we need to add in
# cookies.
#
sub _send_request {
    my($self, $request) = @_;
    my($fields) = $self->[$_IDI];
    my($redirect_count) = 0;
    $fields->{response} = undef;
    $fields->{html_parser} = undef;
    while () {
	$fields->{cookies}->add_cookie_header($request);
	_log($self, 'req', $request);
	$fields->{response} = $fields->{user_agent}->request($request);
	_log($self, 'res', $fields->{response});
	last unless $fields->{response}->is_redirect;
	Bivio::Die->die('too many redirects ', $request)
	    if $redirect_count++ > 5;
	$fields->{cookies}->extract_cookies($fields->{response});
	my($uri) = $fields->{response}->as_string
	    =~ /(?:^|\n)Location: (\S*)/si;
	$request = HTTP::Request->new(GET => _fixup_uri($self, $uri));
	$fields->{uri} = $fields->{response}->base;
    }
    Bivio::Die->die("uri request failed: ", $request->uri)
	unless $fields->{response}->is_success;

    $fields->{cookies}->extract_cookies($fields->{response});
    $fields->{uri} = $fields->{response}->base;
    $fields->{html_parser} =
	Bivio::Test::HTMLParser->new($fields->{response}->content_ref)
        if $fields->{response}->content_type eq 'text/html';
    return;
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
