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
use Bivio::Die;
use Bivio::Ext::LWPUserAgent;
use Bivio::IO::Config;
use Bivio::IO::Ref;
use Bivio::IO::Trace;
use Bivio::Type::FileName;
use Bivio::Test::HTMLParser;
use File::Temp ();
use HTTP::Cookies ();
use HTTP::Request ();
use HTTP::Request::Common ();
use Sys::Hostname ();
use URI ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_IDI) = __PACKAGE__->instance_data_index;
Bivio::IO::Config->register(my $_CFG = {
    email_user => $ENV{LOGNAME},
    home_page_uri => Bivio::IO::Config->REQUIRED,
    mail_dir => "$ENV{HOME}/btest-mail/",
    mail_tries => 60,
    email_tag => '+btest_',
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

=for html <a name="clear_cookies"></a>

=head2 clear_cookies()

Clear the cookies

=cut

sub clear_cookies {
    shift->[$_IDI]->{cookies}->clear();
    return;
}

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

=for html <a name="file_field"></a>

=head2 file_field(string name, string content) : array_ref

=head2 file_field(string name, string_ref content) : array_ref

Returns a definition for the named file field value.
Uses a temporary file which is cleaned up at program exit.

=cut

sub file_field {
    my($self, $name, $content) = @_;
    my($handle, $file) = File::Temp::tempfile(UNLINK => 1,
        SUFFIX => '-' . $name);
    print($handle ref($content) ? $$content : $content);
    close($handle);
    return [$file, $name];
}

=for html <a name="find_table_row"></a>

=head2 find_table_row(string column_name, string column_value) : hash_ref

=head2 find_table_row(string table_name, string column_name, string column_value) : hash_ref

Conveniently calls
L<Bivio::Test::HTMLParser::Tables::find_row|Bivio::Test::HTMLParser::Tables/"find_row">.

=cut

sub find_table_row {
    return shift->get_html_parser()->get('Tables')->find_row(@_);
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
I<table_name> using I<_find_row>.
If I<table_name> is undef, uses I<find_heading>.

Then clicks on I<link_name> in column I<link_heading>.  I<link_heading>
defaults to I<find_heading>.  If I<link_name> is C<undef>, expects one and only
one link, and clicks on that.

=cut

sub follow_link_in_table {
    my($self) = shift;
    my($table_name) = @_ > 2 ? shift : $_[0];
    my($find_heading, $find_value, $link_heading, $link_name) = @_;
    $table_name = $find_heading
	unless defined($table_name);
    my($row) = _find_row($self, $table_name, $find_heading, $find_value);
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

=for html <a name="generate_local_email"></a>

=head2 generate_local_email(string suffix) : string

Returns an email address based on I<email_user> and I<suffix> (a random number
by default).

=cut

sub generate_local_email {
    my(undef, $suffix) = @_;
    return $_CFG->{email_user}
	. $_CFG->{email_tag}
	. ($suffix || int(rand(2_000_000_000)) + 1)
	. '@'
	. Sys::Hostname::hostname();
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

=item email_tag : string [+btest_]

What to include between the I<email_user> and I<suffix> in
L<generate_local_email|"generate_local_email">.

=item email_user : string [$ENV{LOGNAME}]

Base user name to use in email.  Emails will go to:

    email_user+btest_suffix

Where suffix is supplied to L<generate_local_email|"generate_local_email">.

=item home_page_uri : string (required)

URI of home page.

=item mail_tries : string [$ENV{HOME}/btest-mail]

Directory in which mail resides.  Set up your .procmailrc to have a rule:

    :0 H
    * ^TO_.*\+btest_
    btest-mail/.

=item mail_tries : int [60]

Maximum number of attempts to get mail.  Each try is about 1 second.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    Bivio::Die->die($cfg->{email_user}, ': email_user must be an alphanum')
        if $cfg->{email_user} =~ /\W/;
    Bivio::Die->die($cfg->{mail_tries},
	': mail_tries must be a postive integer')
        if $cfg->{mail_tries} =~ /\D/ || $cfg->{mail_tries} <= 0;
    $_CFG = $cfg;
    return;
}

=for html <a name="handle_setup"></a>

=head2 handle_setup()

Clears files in I<mail_dir>.

=cut

sub handle_setup {
    shift->SUPER::handle_setup(@_);
    _grep_mail_dir(sub {
        unlink(shift);
	return;
    });
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

=for html <a name="reload_page"></a>

=head2 reload_page()

=head2 reload_page(string uri)

Reloads the current page.  Intended to be used after a deviance
test to clear errors so that conformance tests can be resumed.
If defined, uses given uri, otherwise uses get_uri()

=cut

sub reload_page {
    my($self, $uri) = @_;
    defined($uri) ? $self->visit_uri($uri) :
	$self->visit_uri($self->get_uri());
    return;
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

=for html <a name="submit_from_table"></a>

=head2 submit_from_table(string table_name, string find_heading, string find_value, string submit_name, hashref form_values)

Finds the row identified by I<find_value> in column I<submit_heading>
of I<table_name> using I<_find_row>.

Then submits the form via I<submit_name>, passing in I<form_values>.
If I<form_values> is undef, then substitutes an empty hashref.

=cut

sub submit_from_table {
    my($self) = shift;
    my($table_name) = @_ > 2 ? shift : $_[0];
    my($find_heading, $find_value, $submit_name, $form_values) = @_;
    $table_name = $find_heading
	unless defined($table_name);
    $form_values = {}
	unless defined($form_values);
    my($row) = _find_row($self, $table_name, $find_heading, $find_value);

    _trace("row = ", $row) if $_TRACE;
    $self->submit_form($submit_name . '_' . $row->{_row_index} => $form_values);
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
    my($visibles) = _assert_html($self)->get('Forms')
	->get_by_field_names(keys(%$form_fields))->{visible};
    _trace($visibles) if $_TRACE;

    foreach my $field (keys(%$form_fields)) {
	my($control) = $visibles->{$field};
	Bivio::Die->die($control->{type}, ' ', $field,
	    ' expected != actual: "', $form_fields->{$field},
	    '" != "', $control->{value}, '"',
        ) unless
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

=for html <a name="verify_link"></a>

=head2 verify_link(string link_name, regexp_ref pattern)

Verifies that the href of the given I<link_name> matches I<pattern>

=cut

sub verify_link {
    my($self, $link_text, $pattern) = @_;
    my($href) = _assert_html($self)->get_nested('Links', $link_text, 'href');
    return;

    Bivio::Die->die('Link "', $link_text, '" does not match "', $pattern, '"')
	unless $href =~ $pattern;
    return;
}

=for html <a name="verify_mail"></a>

=head2 verify_mail(any recipient_email, any body_regex)

Get the last messages received for I<recipient_email> (see
L<generate_local_email|"generate_local_email">) and verify that
I<body_regex> matches.  Deletes the message on a match.

Polls for I<mail_tries>.  If multiple messages come in simultaneously, will
only complete if both I<recipient_email> and I<body_regex> match.

=cut

sub verify_mail {
    my($self, $email, $body_regex) = @_;
    my($seen) = {};
    Bivio::Die->die($_CFG->{mail_dir},
	': mail_dir mail directory does not exist')
        unless -d $_CFG->{mail_dir};
    my($email_match);
    $email = qr{\Q$email}
	unless ref($email);
    for (my $i = $_CFG->{mail_tries}; $i-- > 0; sleep(1)) {
	if (my(@found) = map({
	    my($msg) = Bivio::IO::File->read($_);
	    ($email_match = $$msg =~ /^(?:to|cc):.*\b$email/mi)
	        && $$msg =~ /$body_regex/
	        ? [$_, $msg] : ();
	    } _grep_mail_dir(
		sub {
		    my($file) = @_;
		    return !$seen->{$file}++ && -M $file <= 0;
		}
	    ))
	) {
	    Bivio::Die->die('too many messages matched: ', \@found)
	        if @found > 1;
	    unlink($found[0]->[0]);
	    _log($self, 'msg', $found[0]->[1]);
	    return;
	}
    }
    Bivio::Die->die(
	$email_match ? ('Found mail for "', $email,
	    '", but does not match ', qr/$body_regex/)
	    : ('No mail for "', $email, '" found in ', $_CFG->{mail_dir}),
    );
    # DOES NOT RETURN
}

=for html <a name="verify_options"></a>

=head2 verify_options(string select_field, array_ref options)

Verifies that the given I<select_field> includes the given I<options>.

=cut

sub verify_options {
    my($self, $select_field, $options) = @_;
    my($fields) = $self->[$_IDI];
    my($form) = _assert_html($self)->get('Forms')
	->get_by_field_names($select_field);
    my($f) = _assert_form_field($form, 'visible', $select_field);
    Bivio::Die->die('Select field "', $select_field, '" does not contain any options.')
	    unless $f->{options};
    foreach my $option (@$options) {
	    Bivio::Die->die('Select field "', $select_field,
		'" does not contain option "', $option, '".')
		    unless $f->{options}->{$option};
    }
    return;
}

=for html <a name="verify_table"></a>

=head2 verify_table(string table_name, array_ref expectations)

Verify that table I<table_name> contains the expected rows given in
I<expectations>.  I<expectations> should be an array_ref of array_refs -- kinda
like a table.  The first row defines the column labels whose values will be
verified.  The first column is used to uniquely identify the row.  The order of
rows is not enforced and the order of columns do not need to match the order in
the form (though the expected values do need to correspond to the expected
column labels).


=cut

sub verify_table {
    my($self, $table_name, $expect) = @_;
    my($columns) = shift(@$expect);

    foreach my $expect_row (@$expect) {
	my($row) = _find_row($self, $table_name, $columns->[0],
            $expect_row->[0]);
	my($diff) = Bivio::IO::Ref->nested_differences(
	    $expect_row,
	    [map({
                Bivio::Die->die('column not found: ', $_)
                   unless defined($row->{$_});
                $row->{$_}->get('text');
            } @$columns)]);
	Bivio::Die->die($diff) if defined($diff);
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
	unless $self->get_content =~ /$text/s;
    return;
}

=for html <a name="verify_title"></a>

=head2 verify_title(string title)

Verifies that the specified title appears on the page.

=cut

sub verify_title {
    my($self, $title) = @_;
    Bivio::Die->die($title, ': title not found in response')
	    unless $self->get_content =~ /<title>.*$title.*<\/title>/i;
    return;
}

=for html <a name="verify_uri"></a>

=head2 verify_uri(string uri)

Verifies that the current uri (not including http://.../) is the provided uri.

=cut

sub verify_uri {
    my($self, $uri) = @_;
    my($current_uri) = $self->get_uri;
#    $current_uri =~ s{http.*//[^/]*/}{};
    Bivio::Die->die('Current uri ', $current_uri, ' does not match ', $uri)
#	unless $current_uri eq $uri;
	unless $current_uri =~ $uri;
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

# _create_form_request(self, string method, string uri, array_ref form) : HTTP::Request
#
# Creates appropriate form request based on method (uc).
#
sub _create_form_request {
    my($self, $method, $uri, $form) = @_;
    if ($method eq 'GET') {
	# trim any query which might be there
	$uri =~ s/\?.*//;
        my($url) = URI->new('http:');
        $url->query_form(@$form);
	return HTTP::Request->new(GET => $uri . '?' . $url->query);
    }
    # file fields are array refs
    return scalar(grep({ref($_)} @$form))
        ? HTTP::Request::Common::POST($uri,
            Content_Type => 'form-data',
            Content => $form)
        : HTTP::Request::Common::POST($uri, $form);
}

# _find_row(string table_name, string find_heading, string find_value) : hashref
#
# Returns the hashref for row identified by I<table_name>, <I>find_heading
# and <I>find_value, using L<Bivio::Test::HTMLParser::Tables::find_row|Bivio::Test::HTMLParser::Tables/"find_row">.  
#
sub _find_row {
    my($self, $table_name, $find_heading, $find_value) = @_;
    return _assert_html($self)->get('Tables')->find_row(
	$table_name, $find_heading, $find_value);
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

# _format_form(hash_ref form, string submit,  hash_ref form_fields) : array_ref
#
# Returns URL encoded form.  Undefined fields are not submitted.
# Note the special case handling for checkboxes may need to be extended
# for other controls.
#
sub _format_form {
    my($form, $submit, $form_fields) = @_;
    my($result) = [];
    my($match) = {};
#TODO: Add hidden form field testing
    while (my($k, $v) = each(%$form_fields)) {
	my($f) = _assert_form_field($form, 'visible', $k);
	$match->{$f}++;
	my($value) = $v;
	if ($f->{options}) {
	    # Radio or Select: Allow the use of the option label instead of value
	    foreach my $o (keys(%{$f->{options}})) {
		next unless $o eq $value;
		$value = $f->{options}->{$o}->{value};
		_trace($o, ': mapped to ', $value) if $_TRACE;
		last;
	    }
  	}
        push(@$result, $f->{name}, $value);
    }
    # Fill in hidden and defaults
    foreach my $class (qw(hidden visible)) {
	foreach my $v (values(%{$form->{$class}})) {
	    next if $match->{$v};
            push(@$result, $v->{name},
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
    my($button) = _assert_form_field($form, 'submit', $submit);
    push(@$result, $button->{name}, $button->{value} || '1');
    return $result;
}

# _get_script_line(self) : string
#
# Returns the current line of the running script.
#
sub _get_script_line {
    my($self) = @_;
    my($i) = 0;

    # search for the first AUTOLOAD method in the call stack
    # (this may not always be the actual script if a script method
    #  calls another AUTOLOAD method).
    while (1) {
        my($line, $sub) = (caller($i++))[2..3];
        last unless $sub;
        return $line if $sub =~ /AUTOLOAD/;
    }
    return '?';
}

# _grep_mail_dir(code_ref op) : array
#
# Returns results of grep on mail_dir files.  Only includes valid
# mail files.
#
sub _grep_mail_dir {
    my($op) = @_;
    return grep(Bivio::Type::FileName->get_tail($_) =~ /^\d+$/ && $op->($_),
	glob("$_CFG->{mail_dir}/*"));
}

# _log(self, string type, any msg)
#
# Writes the HTTP message to a file with a nice suffix.  Preserves file
# ordering.
#
sub _log {
    my($self, $type, $msg) = @_;
    my($fields) = $self->[$_IDI];
    $self->test_log_output(
	sprintf('http-%05d.%s', $fields->{log_index}++, $type),
	UNIVERSAL::can($msg, 'as_string') ? $msg->as_string : $msg);
    return;
}

# _regexp(string_or_regexp_ref pattern) : regexp_ref
#
# Coerce the given I<pattern> into a regexp_ref if it isn't one already.
#
sub _regexp {
    my($pattern) = shift;
    return (ref($pattern) eq 'Regexp') ? $pattern : qr{\Q$pattern};
}

# _send_request(self, HTTP::Request request)
#
# Sends the specified request.  Handles redirects, because we need to add in
# cookies.
#
sub _send_request {
    my($self, $request) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{user_agent}->agent($self->get('test_script') . ':'
        . _get_script_line($self));
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
