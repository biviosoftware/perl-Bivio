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
use Bivio::IO::Ref;
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

=for html <a name="debug_print"></a>

=head2 debug_print(string what)

Prints 'Forms' or 'Links' to STDOUT.

=cut

sub debug_print {
    my($self, $what) = @_;
    print(STDOUT ${Bivio::IO::Ref->to_string(
	_assert_html($self)->get($what)->get_shallow_copy)});
    return;
}

=for html <a name="do_table_rows"></a>

=head2 do_table_rows(string table_name, code_ref do_rows_callback)

Conveniently calls
L<Bivio::Test::HTMLParser::Tables::do_rows|Bivio::Test::HTMLParser::Tables/"do_rows">.

=cut

sub do_table_rows {
    return shift->get_html_parser()->get('Tables')->do_rows(@_);
}

=for html <a name="follow_link"></a>

=head2 follow_link(string link_name)

Loads the page for the L<link_name|"link_name">

=cut

sub follow_link {
    my($self, $link_text) = @_;
    $self->visit_uri(
	_assert_html($self)->get_nested('Links', $link_text, 'href'));
    return;
}

=for html <a name="follow_link_in_table"></a>

=head2 follow_link_in_table(string find_heading, string find_value)

=head2 follow_link_in_table(string table_name, string find_heading, string find_value, string link_heading, string link_name)

Finds the row identified by I<find_value> in column I<find_heading> of
I<table_name> using
L<Bivio::Test::HTMLParser::Tables::find_row|Bivio::Test::HTMLParser::Tables/"find_row">.  If I<table_name> is undef, uses I<find_heading>.

Then clicks on I<link_name> in column I<link_heading>.  I<link_heading>
defaults to I<find_heading>.  If I<link_name> is C<undef>, expects one an only
one link, and clicks on that.

=cut

sub follow_link_in_table {
    my($self) = shift;
    my($table_name) = @_ > 2 ? shift : $_[0];
    my($find_heading, $find_value, $link_heading, $link_name) = @_;
    $table_name = $find_heading
	unless defined($table_name);
    my($row) = _assert_html($self)->get('Tables')->find_row(
	$table_name, $find_heading, $find_value);
    $link_heading = $find_heading
	unless defined($link_heading);
    Bivio::Die->die(
	$link_heading, ': link column not found, or column empty',
    ) unless defined($row->{$link_heading});
    my($links) = $row->{$link_heading}->get('Links');
    return $self->visit_uri($links->get($link_name)->{href})
	if defined($link_name);
    my($k) = $links->get_keys;
    Bivio::Die->die(
	$k, ': too many or too few links found in column ', $link_heading,
    ) unless @$k == 1;
    return $self->visit_uri($links->get($k->[0])->{href});
}

=for html <a name="get_content"></a>

=head2 get_content() : string

Returns the current page content.

=cut

sub get_content {
    my($self) = @_;
    return _assert_response($self)->content;
}

=for html <a name="get_html_parser"></a>

=head2 get_html_parser() : Bivio::Test::HTMLParser

Returns the HTML parser for the current page.

=cut

sub get_html_parser {
    my($self) = @_;
    return _assert_html($self);
}

=for html <a name="get_uri"></a>

=head2 get_uri() : string

Returns the uri for the current page.  Blows up if no current uri.

=cut

sub get_uri {
    return shift->[$_IDI]->{uri}
	|| Bivio::Die->die('no current uri');
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

=head2 home_page(string facade_uri)

Requests the the home page.  See L<home_page_uri|"home_page_uri"> for
arguments.

=cut

sub home_page {
    my($self) = shift;
    return $self->visit_uri($self->home_page_uri(@_));
}

=for html <a name="home_page_uri"></a>

=head2 home_page_uri(string facade_uri) : string

Returns configured home page uri.  Used by other tests.  If I<facade_uri> is
supplied, will modify configured URI to download from facade.  Doesn't validate
I<facade_uri> is a valid facade.

=cut

sub home_page_uri {
    my(undef, $facade_uri) = @_;
    my($res) = $_CFG->{home_page_uri};
    $res =~ s{(?<=://)}{$facade_uri.}
	|| Bivio::Die->die($res, ': unable to create facade URI')
	if $facade_uri;
    return $res;
}

=for html <a name="submit_form"></a>

=head2 submit_form(string submit_button, hash_ref form_fields)

Submits I<form_fields> using I<submit_button>. Only fields specified will be
sent.

B<File upload not supported yet.>

=cut

sub submit_form {
    my($self, $submit_button, $form_fields) = @_;
    $form_fields ||= {};
    my($fields) = $self->[$_IDI];
    my($form) = _assert_html($self)->get('Forms')
	->get_by_field_names(keys(%$form_fields), $submit_button);
    _send_request($self,
	_create_form_request(
	    $self, uc($form->{method}),
	    _fixup_uri($self, $form->{action}),
	_format_form($form, $submit_button, $form_fields)));
    _assert_form_response($self);
    return;
}

=for html <a name="verify_form"></a>

=head2 verify_form(hash_ref form_fields)

Verifies the state of I<form_fields>. Only fields specified will be
verified.

=cut

sub verify_form {
    my($self, $form_fields) = @_;
    my($fields) = $self->[$_IDI];
    my($field);
    my($visibles) = _assert_html($self)->get('Forms')
	->get_by_field_names(keys(%$form_fields))->{visible};
    _trace($visibles) if $_TRACE;

    foreach $field (keys(%$form_fields)) {
	my($control) = $visibles->{$field};
	Bivio::Die->die($control->{type}, " ", $field,
	    ' unexpected setting from ', $form_fields->{$field}) unless
		$control->{type} eq 'checkbox'
		    ? ($control->{checked}
			? defined($control->{value})
			    ? $control->{value} : 1 : 0)
			== (defined($form_fields->{$field})
			    ? $form_fields->{$field} : 0)
		    : $form_fields->{$field} eq $control->{value};
    }
    return;
}

=for html <a name="verify_text"></a>

=head2 verify_text(string text)

Verifies that the specified text appears on the page.

=cut

sub verify_text {
    my($self, $text) = @_;
    Bivio::Die->die($text, ': text not found in response')
	unless $self->get_content =~ /$text/;
    return;
}

=for html <a name="visit_uri"></a>

=head2 visit_uri(string uri)

Loads the page using the specified URI.

=cut

sub visit_uri {
    my($self, $uri) = @_;
    _trace($uri) if $_TRACE;
    _send_request($self, HTTP::Request->new(GET => _fixup_uri($self, $uri)));
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
	|| Bivio::Die->die(
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

# _create_form_request(self, string method, string uri, string form) : HTTP::Request
#
# Creates appropriate form request based on method (uc).
#
sub _create_form_request {
    my($self, $method, $uri, $form) = @_;
    if ($method eq 'GET') {
	# trim any query which might be there
	$uri =~ s/\?.*//;
	return HTTP::Request->new(GET => "$uri?$form");
    }
    my($request) = HTTP::Request->new($method => $uri);
    $request->content_type('application/x-www-form-urlencoded');
    $request->content($form);
    return $request;
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
# Formats the field as $name=$value&.  If not defined($value), then
# returns empty string.
#
sub _format_field {
    my($field, $value) = @_;
    Bivio::Die->die($value, ': invalid value for field ', $field->{name})
	if ref($value);
    return ''
	unless defined($value);
    if ($field->{options}) {
	# Radio or Select: Allows the user to set value directly instead
	# of matching label
	foreach my $k (keys(%{$field->{options}})) {
	    next unless $k eq $value;
	    $value = $field->{options}->{$k}->{value};
	    _trace($k, ': mapped to ', $value) if $_TRACE;
	    last;
	}
    }
    return defined($field->{name}) && length($field->{name})
	? Bivio::HTML->escape_query($field->{name}) . '='
	   . Bivio::HTML->escape_query($value) . '&'
        : '';
}

# _format_form(hash_ref form, string submit,  hash_ref form_fields) : string
#
# Returns URL encoded form.  Undefined fields are not submitted.
#
sub _format_form {
    my($form, $submit, $form_fields) = @_;
    my($res) = '';
    my($match) = {};
#TODO: Add hidden form field testing
    while (my($k, $v) = each(%$form_fields)) {
	my($f) = _assert_form_field($form, 'visible', $k);
	$match->{$f}++;
 	$res .= _format_field($f, $v);
    }
    # Fill in hidden and defaults
    foreach my $class (qw(hidden visible)) {
	foreach my $v (values(%{$form->{$class}})) {
	    next if $match->{$v};
	    $res .= _format_field($v,
		$v->{type} eq 'checkbox'
		    ? $v->{checked}
		        ? defined($v->{value})
		            ? $v->{value}
		            : 1
		        : next
		    : $v->{value});
	}
    }
    # Needs to be some "true" value for our forms
    $res .= _format_field(_assert_form_field($form, 'submit', $submit), '1');
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
	$fields->{uri} = $request->uri->as_string;
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
    }
    Bivio::Die->die("uri request failed: ", $request->uri)
	unless $fields->{response}->is_success;

    $fields->{cookies}->extract_cookies($fields->{response});
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
