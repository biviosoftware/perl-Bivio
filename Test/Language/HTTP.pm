# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
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
use Bivio::Mail::Address;
use Bivio::Mail::Common;
use Bivio::Type::FileName;
use Bivio::Test::HTMLParser;
use File::Temp ();
use HTTP::Cookies ();
use HTTP::Request ();
use HTTP::Request::Common ();
use Sys::Hostname ();
use URI ();

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
Bivio::IO::Config->register(my $_CFG = {
    # NOTE: There is no ENV when loaded under apache
    email_user => $ENV{LOGNAME} || $ENV{USER} || 'btest',
    server_startup_timeout => 0,
    home_page_uri => Bivio::IO::Config->REQUIRED,
    local_mail_host => Sys::Hostname::hostname(),
    remote_mail_host => undef,
    mail_dir => $ENV{HOME} ? "$ENV{HOME}/btest-mail/" : '',
    mail_tries => 60,
    email_tag => '+btest_',
});
my($_VERIFY_MAIL_HEADERS) = [Bivio::Mail::Common->TEST_RECIPIENT_HDR, 'To'];

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
	history => [],
	history_length => 3,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="absolute_uri"></a>

=head2 absolute_uri(string uri)

Clear the cookies

=cut

sub absolute_uri {
    my($self, $uri) = @_;
    die('invalid uri')
	unless defined($uri) && length($uri);
    my($u) = URI->new(_append_query($self, $uri));
    return defined($u->scheme) ? $uri : $u->abs(
	$self->[$_IDI]->{uri}
	|| Bivio::Die->die($uri, ': unable to make absolute; no prior URI')
    )->canonical->as_string;
}

=for html <a name="basic_authorization"></a>

=head2 basic_authorization(string user, string password)

=cut

sub basic_authorization {
    my($self, $user, $password) = @_;
    $self->put(Authorization =>
        'Basic ' . MIME::Base64::encode(
	    $user . ':' . ($password || $self->default_password)));
    return;
}

=for html <a name="clear_cookies"></a>

=head2 clear_cookies()

Clear the cookies

=cut

sub clear_cookies {
    shift->[$_IDI]->{cookies}->clear();
    return;
}

=for html <a name="clear_extra_query_params"></a>

=head2 clear_extra_query_params()

Clear the extra query params

=cut

sub clear_extra_query_params {
    my($self) = @_;
    delete($self->internal_get->{extra_query_params});
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

=for html <a name="default_password"></a>

=head2 default_password() : string

Returns the default password.

=cut

sub default_password {
    return shift->use('Bivio::Util::SQL')->TEST_PASSWORD;
}

=for html <a name="do_table_rows"></a>

=head2 do_table_rows(string table_name, code_ref do_rows_callback)

Conveniently calls
L<Bivio::Test::HTMLParser::Tables::do_rows|Bivio::Test::HTMLParser::Tables/"do_rows">.

=cut

sub do_table_rows {
    return shift->get_html_parser()->get('Tables')->do_rows(@_);
}

=for html <a name="do_xxx"></a>

=head2 do_test_backdoor(string form_model, hash_ref form_fields)

=head2 do_test_backdoor(string shell_util, string command)

Executes ShellUtil or FormModel based on $args.

=cut

sub do_test_backdoor {
    my($self, $op, $args) = @_;
    $self->visit_uri(
	'/_test_backdoor?'
	. $self->use('Bivio::Agent::HTTP::Query')->format(
	    ref($args) eq 'HASH' ? {%$args, form_model => $op}
	        : ref($args) eq '' ? {shell_util => $op, command => $args}
		: Bivio::Die->die($args, ': unable to parse args'),
	)
    );
    return;
}

=for html <a name="extra_query_params"></a>

=head2 extra_query_params(string key, string value)

Append extra query params.

=cut

sub extra_query_params {
    my($self, $key, $value) = @_;
    push(@{($self->internal_get->{extra_query_params} ||= [])}, $key, $value);
    return;
}

=for html <a name="file_field"></a>

=head2 file_field(string file_name) : array_ref

=head2 file_field(string name, string content) : array_ref

=head2 file_field(string name, string_ref content) : array_ref

Returns a value to be used by submit_form() with I<file_name> or I<name> as the
name.  Uses a temporary file which is cleaned up at program exit if I<content>
is supplied.

=cut

sub file_field {
    my($self, $name, $content) = @_;
    return [$name, $name]
	unless defined($content);
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

sub follow_frame {
    my($self, $name) = @_;
    return $self->visit_uri(
	_assert_html($self)->get('Frames')
	->get($name)
	->{src},
    );
}

=for html <a name="follow_link"></a>

=head2 follow_link(any link_name)

Loads the page for the L<link_name|"link_name">, which may be a regular
expression.

=cut

sub follow_link {
    my($self, $link_text) = @_;
    my($m) = ref($link_text) ? 'get_by_regexp' : 'get';
    return $self->visit_uri(
	_assert_html($self)->get('Links')
	->$m($link_text)
	->{href},
    );
}

=for html <a name="follow_link_in_table"></a>

=head2 follow_link_in_table(string table_name, string find_heading, string find_value)

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
    # link_name may be '0', so use defined() for comparison
    return $self->visit_uri($links->get(
        defined($link_name) ? $link_name : $find_value)->{href})
	if defined($link_name) || $links->has_keys($find_value);
    my($k) = $links->get_keys;
    Bivio::Die->die(
	$k, ': too many or too few links found in column ', $link_heading,
    ) unless @$k == 1;
    return $self->visit_uri($links->get($k->[0])->{href});
}

=for html <a name="generate_local_email"></a>

=head2 generate_local_email(string suffix) : string

Returns an email address based on I<email_user> and I<suffix>.

=cut

sub generate_local_email {
    my($self, $suffix) = @_;
    Bivio::Die->die('missing suffix') unless defined($suffix);
    return lc($_CFG->{email_user}
	. $_CFG->{email_tag}
	. $suffix
	. '@'
	. $_CFG->{local_mail_host});
}

=for html <a name="generate_remote_email"></a>

=head2 generate_remote_email(string base, string facade_uri) : string

Generates an email for the remote server.  Appends  @I<remote_mail_host> with
I<facade_uri>. prefix if it is supplied.

=cut

sub generate_remote_email {
    my($self, $base, $facade_uri) = @_;
    return _facade("$base\@$_CFG->{remote_mail_host}", $self, $facade_uri);
}

=for html <a name="generate_test_name"></a>

=head2 generate_test_name(string suffix) : string

return 'btest_'.I<suffix>.

=cut

sub generate_test_name {
    my($self, $suffix) = @_;
    return 'btest_'.$suffix;
}

=for html <a name="get_content"></a>

=head2 get_content() : string

Returns the current page content.

=cut

sub get_content {
    return shift->get_response->content;
}

=for html <a name="get_html_parser"></a>

=head2 get_html_parser() : Bivio::Test::HTMLParser

Returns the HTML parser for the current page.

=cut

sub get_html_parser {
    my($self) = @_;
    return _assert_html($self);
}

=for html <a name="get_response"></a>

=head2 get_response() : string

Returns the current page response, or dies if response not valid.

=cut

sub get_response {
    return shift->[$_IDI]->{response} || Bivio::Die->die('no valid response');
}

=for html <a name="get_table_row"></a>

=head2 get_table_row(string table_name) : hash_ref

=head2 get_table_row(string table_name, string row_index) : hash_ref

Return table row specified by column_index.

=cut

sub get_table_row {
    my($self, $table_name, $row_index) = @_;
    $row_index ||= 0;
    my($found_row);
    $self->get_html_parser()->get('Tables')->do_rows($table_name, sub {
        my($row, $index) = @_;
	if ($index == $row_index) {
	    $found_row = $row;
	    return 0;
	}
	else {
	    return 1;
	}
    });
    Bivio::Die->($row_index, ': no such row number')
        unless $found_row;
    return $found_row;
}

=for html <a name="get_uri"></a>

=head2 get_uri() : string

Returns the uri for the current page.  Blows up if no current uri.

=cut

sub get_uri {
    return shift->unsafe_get_uri || Bivio::Die->die('no current uri');
}

=for html <a name="go_back"></a>

=head2 go_back()

Goes back one element in the history.  If there is no history, blows
up.

=cut

sub go_back {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    my($x) = pop(@{$fields->{history}})
	|| Bivio::Die->die('no page to go back to');
    while (my($k, $v) = each(%$x)) {
	$fields->{$k} = $v;
    }
    return;
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

=item server_startup_timeout : int [0]

Maximum number of attempts to connect to the server on startup.
Each try is about 1 second.

=item home_page_uri : string (required)

URI of home page.

=item mail_dir : string [$ENV{HOME}/btest-mail]

Directory in which mail resides.  Set up your .procmailrc to have a rule:

    :0 H
    * ^TO_.*\<btest_
    btest-mail/.

Make sure the permissions are 0600 on your .procmailrc.

=item mail_tries : int [60]

Maximum number of attempts to get mail.  Each try is about 1 second.

=item remote_mail_host : string [host of home_page_uri]

You can set the uri of the remote host.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    Bivio::Die->die($cfg->{email_user}, ': email_user must be an alphanum')
        if ($cfg->{email_user} || '') =~ /\W/;
    Bivio::Die->die($cfg->{mail_tries},
	': mail_tries must be a postive integer')
        if $cfg->{mail_tries} =~ /\D/ || $cfg->{mail_tries} <= 0;
    Bivio::Die->die($cfg->{server_startup_timeout},
	': server_startup_timeout must be a postive integer')
        if $cfg->{server_startup_timeout} =~ /\D/
	    || $cfg->{server_startup_timeout} < 0;
    $cfg->{remote_mail_host} ||= URI->new($cfg->{home_page_uri})->host;
    $_CFG = $cfg;
    return;
}

=for html <a name="handle_setup"></a>

=head2 handle_setup()

Clears files in I<mail_dir>.

=cut

sub handle_setup {
    my($self) = shift;
    $self->SUPER::handle_setup(@_);
    _map_mail_dir(sub {
        unlink(shift);
	return;
    });
    _wait_for_server($self, $_CFG->{server_startup_timeout})
	if $_CFG->{server_startup_timeout} && ref($self);
    return;
}

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
    return _facade($_CFG->{home_page_uri}, @_)
}

=for html <a name="random_string"></a>

=head2 random_string(int chars) : string

Returns a random lower case alphanumeric string I<chars> length (default: 8).

=cut

sub random_string {
    return shift->use('Bivio::Biz::Random')
	->string(shift || 8, [0..9, 'a'..'z']);
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

=for html <a name="send_mail"></a>

=head2 send_mail(string from_email, string to_email) : Bivio::Mail::Outgoing

Send a message.  Returns the object.  Sets subject and body to unique values.

=cut

sub send_mail {
    my($self, $from_email, $to_email) = @_;
    my($r) = $self->random_string();
    my($req) = Bivio::IO::ClassLoader->simple_require('Bivio::Test::Request')
	->get_current_or_new;
    my($o) = Bivio::IO::ClassLoader ->simple_require('Bivio::Mail::Outgoing')
	->new;
    $o->set_recipients($to_email, $req);
    $o->set_header(To => $to_email);
    $o->set_header(Subject => "subj-$r");
    $o->set_body("Any unique $r body\n");
    $o->add_missing_headers($req, $from_email);
    $o->send($req);
    return $o;
}

=for html <a name="send_request"></a>

=head2 send_request(string method, string uri, array_ref header, $content)

Wraps HTTP::Request

=cut

sub send_request {
    my($self, $method, $uri, $header, $content) = @_;
    _send_request(
	$self, HTTP::Request->new(
	    $method => $self->absolute_uri($uri),
	    $header
                ? HTTP::Headers->new(@{
                    ref($header) eq 'ARRAY' ? $header : [%$header]
                })
                : undef,
	    $content,
	),
    );
    return;
}

=for html <a name="submit_form"></a>

=head2 submit_form(string submit_button, hash_ref form_fields, string expected_content_type)

=head2 submit_form(hash_ref form_fields, string expected_content_type)

Submits I<form_fields> using I<submit_button> (or none, if no submit
button). Only fields specified will be sent.  Asserts I<expected_content_type>
is expected_content_type (default: text/html).  If I<expected_content_type> is
text/html, form is checked for submission errors.  If I<expected_content_type>
is not text/html, won't check for submission errors.

=cut

sub submit_form {
    my($self, $submit_button, $form_fields, $expected_content_type) = @_;

    my($forms) = _assert_html($self)->get('Forms');
    my($form);

    if (!defined($submit_button)) {
        $form = $forms->get_by_field_names(keys(%$form_fields));
    }
    elsif (ref($submit_button) eq 'HASH') {
	$expected_content_type = $form_fields;
	$form_fields = $submit_button;
        $form = $forms->get_by_field_names(keys(%$form_fields));
	$submit_button = $forms->get_ok_button($form);
    }
    else {
	$form_fields ||= {};
	$form = $forms->get_by_field_names(
	    keys(%$form_fields),
	    $submit_button,
	);
    }
    _send_request($self,
	_create_form_request(
	    $self, uc($form->{method}),
	    $self->absolute_uri($form->{action} || $self->unsafe_get_uri),
            _format_form($form, $submit_button, $form_fields)));
    _assert_form_response($self, $expected_content_type);
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

=for html <a name="text_exists"></a>

=head2 text_exists(any pattern) : boolean

Returns true if I<pattern> exists in response (must be text/html),
else false.

=cut

sub text_exists {
    my($self, $pattern) = @_;
    unless (ref($pattern) && ref($pattern) eq 'Regexp') {
	$pattern = qr/\Q$pattern/;
    }
    return $self->get_content =~ $pattern ? 1 : 0;
}

=for html <a name="unsafe_get_uri"></a>

=head2 unsafe_get_uri() : string

Gets current uri or returns undef.

=cut

sub unsafe_get_uri {
    return shift->[$_IDI]->{uri};
}

=head2 unsafe_op(string method, any args...) : boolean

Calls method, and if it dies, returns false.  Otherwise, true.

=cut

sub unsafe_op {
    my($self, $method, @args) = @_;
    return Bivio::Die->catch(sub {$self->$method(@args)}) ? 0 : 1;
}

sub user_agent {
    my($self) = @_;
    return 'Mozilla/4.0 (compatible; '
	. $self->get('test_script')
        . ':'
	. _get_script_line($self);
}

=for html <a name="verify_content_type"></a>

=head2 verify_content_type(string mime_type)

Verifies the Content-Type of the reply.

=cut

sub verify_content_type {
    my($self, $mime_type) = @_;
    my($ct) = $self->get_response->content_type;
    Bivio::Die->die($ct, ': response not ', $mime_type)
	unless $ct eq $mime_type;
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
    my($form) = _assert_html($self)->get('Forms')
	->get_by_field_names(keys(%$form_fields));
    _trace($form->{visible}) if $_TRACE;
    foreach my $field (sort(keys(%$form_fields))) {
	my($control) = _assert_form_field($form, $field);
	my($case) = {
	    expected => $form_fields->{$field},
	    result => '',
	};
	_verify_form_field($self, $control, $case);
	Bivio::Die->die($control->{type}, ' ', $field, ' expected: ',
	    $case->{expected}, ' but got: ', $case->{result})
		unless
		    (ref($case->{expected}) eq 'Regexp'
			 && $case->{result} =~ $case->{expected})
		    || $case->{expected} eq $case->{result};
    }
    return;
}

=for html <a name="verify_link"></a>

=head2 verify_link(string link_name)

=head2 verify_link(string link_name, regexp_ref pattern)

Verifies that named link exists and matches the specified pattern.

=cut

sub verify_link {
    my($self, $link_text, $pattern) = @_;
    my($href) = _assert_html($self)->get_nested('Links', $link_text, 'href');
    return unless $pattern;
    Bivio::Die->die('Link "', $link_text, '" does not match "', $pattern, '"')
	unless $href =~ $pattern;
    return;
}

=for html <a name="verify_local_mail"></a>

=head2 verify_local_mail(any recipient_email, any body_regex) : string

=head2 verify_local_mail(any recipient_email, any body_regex, int count) : array or string

Get the last messages received for I<recipient_email> (see
L<generate_local_email|"generate_local_email">) and verify that
I<body_regex> matches.  Deletes the message(s) on a match.

Polls for I<mail_tries>.  If multiple messages come in simultaneously, will
only complete if both I<recipient_email> and I<body_regex> match.

I<count> defaults to 1.  An exception is thrown if the number of messages found
is not equal to I<count>.  Returns and array with I<count> strings of the
messages found.

=cut

sub verify_local_mail {
    my($self, $email, $body_regex, $count) = @_;
    my($body_re) = !defined($body_regex) ? qr{}
	: ref($body_regex) ? $body_regex : qr{$body_regex};
    $count ||= ref($email) eq 'ARRAY' ? int(@$email) : 1;
    Bivio::Die->die($_CFG->{mail_dir},
	': mail_dir mail directory does not exist')
        unless -d $_CFG->{mail_dir};
    my($match) = {};
    $email = [$email]
	unless ref($email) eq 'ARRAY';
    my($found) = [];
    my($die) = sub {Bivio::Die->die(@_, "\n", $found)};
    for (my $i = $_CFG->{mail_tries}; $i-- > 0;) {
	# It takes a certain amount of time to hit, and on the same machine
	# we're going to be competing for the CPU so let b-sendmail-http win
	sleep(1);
	$found = _grep_msgs($email, $body_re, $match);
	next if @$found < $count;
	last unless @$found == $count && @$email == keys(%$match);
	foreach my $f (@$found) {
	    unlink($f->[0]);
	    _log($self, 'msg', $f->[1])
		if ref($self);
	}
	return wantarray ? map(${$_->[1]}, @$found) : ${$found->[0]->[1]};
    }
    $die->(%$match
        ? ('Found mail for "', $email, '", but does not match ',
	   $body_re, ' matches=', $match)
	: ('No mail for "', $email, '" found in ', $_CFG->{mail_dir}),
    ) unless @$found;
    $die->('incorrect number of messages.  expected != actual: ',
	$count, ' != ', int(@$found)
    ) if @$found != $count;
    $die->('correct number of messages, but emails expected != actual: ',
	[sort(@$email)], ' != ', $match,
    );
    # DOES NOT RETURN
}

=for html <a name="verify_no_link"></a>

=head2 verify_no_link(string link_name)

Verifies that none of the links on the page match I<link_name>.

=cut

sub verify_no_link {
    my($self, $link_text) = @_;
    Bivio::Die->die('found link "', $link_text, '".')
	    if _assert_html($self)->get('Links')->unsafe_get($link_text);
    return;
}

=for html <a name="verify_no_text"></a>

=head2 verify_no_text(any text)

Verifies that I<text> DOES NOT appear on the page.

=cut

sub verify_no_text {
    my($self, $text) = @_;
    Bivio::Die->die($text, ': text found in response')
	if $self->text_exists($text);
    return;
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
    my($f) = _assert_form_field($form, $select_field);
    Bivio::Die->die(
	'Select field "', $select_field, '" does not contain any options.',
    ) unless $f->{options};
    foreach my $option (@$options) {
	Bivio::Die->die(
	    'Select field "', $select_field, '" does not contain option "',
	    $option, '".',
	) unless $f->{options}->{$option};
    }
    return;
}

=for html <a name="verify_pdf"></a>

=head2 verify_pdf(string text)

Converts the current response from pdf to text (with I<pdftotext>) and
validates that I<text> is contained therein.  I<text> is not escaped
in the regular expression.

=cut

sub verify_pdf {
    my($self, $text) = @_;
    $self->verify_content_type('application/pdf');
    my($f) = _log($self, 'pdf', $self->get_content);
    system("pdftotext '$f'") == 0
	or Bivio::Die->die($f, ': unable to convert pdf to text');
    $f =~ s/pdf$/txt/;
    Bivio::Die->die($text, ': text not found in response ', $f)
	unless ${Bivio::IO::File->read($f)} =~ /$text/s;
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
    my($cols) = shift(@$expect);
    Bivio::Die->die('missing rows values')
        unless int(@$expect);
    my($first_col) = shift(@$cols);
    foreach my $e (@$expect) {
	my($a) = _find_row($self, $table_name, $first_col, shift(@$e));
	my($diff) = Bivio::IO::Ref->nested_differences(
	    $e,
	    [map({
		$self->test_ok(
		    exists($a->{$_}), $_, ': column not found in row: ', $a);
		$a->{$_}->get('text');
	    }
		@$cols,
	    )]
	);
	Bivio::Die->die($diff)
	    if $diff;
    }
    return;
}

=for html <a name="verify_text"></a>

=head2 verify_text(string text)

Verifies I<text> appears on the page.

=cut

sub verify_text {
    my($self, $text) = @_;
    Bivio::Die->die($text, ': text not found in response')
	unless $self->text_exists($text);
    return;
}

=for html <a name="verify_title"></a>

=head2 verify_title(string title)

Verifies that the specified title appears on the page.

=cut

sub verify_title {
    my($self, $title) = @_;
    Bivio::Die->die($title, ': title not found in response')
	    unless $self->get_content =~ /\<title\>.*$title.*\<\/title\>/i;
    return;
}

=for html <a name="verify_uri"></a>

=head2 verify_uri(regexp uri)

Verifies that the current uri (not including http://.../) matches I<uri>.

=cut

sub verify_uri {
    my($self, $uri) = @_;
    my($current_uri) = $self->get_uri;
    Bivio::Die->die('Current uri ', $current_uri, ' does not match ', $uri)
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
    _send_request($self, HTTP::Request->new(GET => $self->absolute_uri($uri)));
    return;
}

#=PRIVATE SUBROUTINES

# _append_query(string uri, array_ref query) : string
# query should be [k1 => v1, k2 => v2, ...]
sub _append_query {
    my($self, $u) = @_;
    my($q) = $self->internal_get->{extra_query_params};
    return $u
	unless defined($q);
    my($uri) = URI->new($u);
    $uri->query_form($uri->query_form, @$q);  # XXX
    return $uri->canonical->as_string;
}

# _assert_form_field(hash_ref form, any name) : hash_ref
#
# Returns the named field from form->class or dies.
#
sub _assert_form_field {
    return Bivio::Test::HTMLParser::Forms->get_field(@_);
}

# _assert_form_response(self, string expected_content_type)
#
# Asserts result of form is valid.
#
sub _assert_form_response {
    my($self, $expected_content_type) = @_;
    $expected_content_type ||= 'text/html';
    my($fields) = $self->[$_IDI];
    return
	if $fields->{redirect_count} > 0;

    if ($expected_content_type eq 'text/html') {
	my($forms) = _assert_html($self)->get('Forms')->get_shallow_copy;
	while (my($k, $v) = each(%$forms)) {
	    Bivio::Die->die('form submission errors: ', $v->{errors})
	        if $v->{errors};
	}
    }
    else {
	my($content_type) = $self->get_response->content_type;
	Bivio::Die->die($content_type, ': response not ',
	    $expected_content_type)
		if $content_type ne $expected_content_type;
    }
    return;
}

# _assert_html(self) : Bivio::Test::HTMLParser
#
# Asserts HTML and returns parser
#
sub _assert_html {
    my($self) = @_;
    return $self->[$_IDI]->{html_parser} || Bivio::Die->die(
	$self->get_response->content_type, ': response not html');
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
	return HTTP::Request->new(
	    GET => _append_query($self, $uri . '?' . $url->query));
    }
    $uri = _append_query($self, $uri);
    # file fields are array refs
    return scalar(grep({ref($_)} @$form))
        ? HTTP::Request::Common::POST($uri,
            Content_Type => 'form-data',
            Content => $form)
        : HTTP::Request::Common::POST($uri, $form);
}

# _facade(string, to_fix, self, facade) : string
sub _facade {
    my($to_fix, undef, $facade_uri) = @_;
    return $to_fix
	unless $facade_uri;
    my($default) = Bivio::IO::ClassLoader->simple_require(
	'Bivio::Test::Request')
	->initialize_fully
	->get('Bivio::UI::Facade')
	->get('uri');
    $to_fix =~ s{^(.*?)\b$default\b}{$1$facade_uri}ix
	|| $to_fix =~ s{(?<=\://)|(?<=\@)}{$facade_uri.}ix
	|| Bivio::Die->die($to_fix, ': unable to fixup uri with ', $facade_uri);
    return $to_fix
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
	my($f) = _assert_form_field($form, $k);
	$match->{$f}++;
        # Radio or Select: Allow the use of the option label instead of value
	my($value) = $f->{options}
            ? _lookup_option_value($f->{options}, $v)
            : $v;
        _validate_text_field($f, $v)
            if $f->{type} eq 'text';
        push(@$result, $f->{name}, $value);
    }
    # Fill in hidden and defaults
    foreach my $class (qw(hidden visible)) {
	foreach my $v (values(%{$form->{$class}})) {
	    next if $match->{$v};
            _validate_text_field($v, $v->{value})
                if $v->{type} eq 'text';
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
    return $result
	unless defined($submit);
    my($button) = _assert_form_field($form, $submit);
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

# _map_mail_dir(code_ref op) : array
#
# Returns results of grep on mail_dir files.  Only includes valid
# mail files.
#
sub _map_mail_dir {
    my($op) = @_;
    return map(
	Bivio::Type::FileName->get_tail($_) =~ /^\d+$/ ? $op->($_) : (),
	glob("$_CFG->{mail_dir}/*"),
    );
}

# _grep_msgs(hash_ref regexes, hash_ref match) : array_ref
#
# Returns results of grep on mail_dir files.  Only includes valid
# mail files.
#
sub _grep_msgs {
    my($emails, $msg_re, $matched_emails) = @_;
    return [_map_mail_dir(sub {
        my($file) = @_;
	return unless -M $file <= 0;
	my($msg) = Bivio::IO::File->read($file);
	my($hdr) = split(/^$/m, $$msg, 2);
	my($res);
	foreach my $k (@$_VERIFY_MAIL_HEADERS) {
	    next unless $hdr =~ /^$k:\s*(.*)/mi;
	    my($e) = Bivio::Mail::Address->parse_list($1);
	    die("$hdr: malformed-header")
		unless $e && ($e = lc($e->[0]));
	    my($m) = grep(ref($_) ? $hdr =~ $_ : lc($_) eq $e, @$emails);
	    if ($m) {
		$matched_emails->{$m}++;
		return [$file, $msg]
		    if $$msg =~ $msg_re;
	    }
	    last;
	}
	return;
    })];
}

# _log(self, string type, any msg) : string
#
# Writes the HTTP message to a file with a nice suffix.  Preserves file
# ordering, returns the file.
#
sub _log {
    my($self, $type, $msg) = @_;
    my($fields) = $self->[$_IDI];
    return $self->test_log_output(
	sprintf('http-%05d.%s', $fields->{log_index}++, $type),
	UNIVERSAL::can($msg, 'as_string') ? $msg->as_string : $msg);
}

# _lookup_option_value(hash_ref options, any value) : string
#
# Lookup an option (select or radio) submit value
# from the label or value. I<value> may be a regular expression.
#
sub _lookup_option_value {
    my($options, $value) = @_;

    # Radio or Select: Allow the use of the option label
    # instead of value
    foreach my $o (keys(%$options)) {
        next unless ref($value) ? $o =~ $value : $o eq $value;
        _trace($o, ': mapped to ', $options->{$o}->{value}) if $_TRACE;
        return $options->{$o}->{value};
    }

    # otherwise verify that it is a valid submit value
    foreach my $o (keys(%$options)) {
        my($v) = $options->{$o}->{value};
        next unless ref($value) ? $v =~ $value : $v eq $value;
        _trace($v, ': mapped by value to label ', $o)
            if $_TRACE;
        return $v;
    }
    Bivio::Die->die('option value not found: ', $value);
}

# _send_request(self, HTTP::Request request)
#
# Sends the specified request.  Handles redirects, because we need to add in
# cookies.
#
sub _send_request {
    my($self, $request) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{user_agent}->agent($self->user_agent);
    my($redirect_count) = 0;
    my($prev_uri) = $self->absolute_uri($fields->{uri})
	if $fields->{uri};
    push(@{$fields->{history}}, {
	map({
	    my($x) = $fields->{$_};
	    $fields->{$_} = undef;
	    ($_ => $x);
	} qw(uri response html_parser)),
    }) if $fields->{response};
    shift(@{$fields->{history}})
	while @{$fields->{history}} > $fields->{history_length};
    while () {
	$request->header(Authorization => $self->get('Authorization'))
	    if $self->has_keys('Authorization');
	$request->header(Referer => $prev_uri)
	    if $prev_uri;
	$fields->{uri} = $request->uri->canonical->as_string;
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
	$request = HTTP::Request->new(GET => $prev_uri = $self->absolute_uri($uri));
    }
    Bivio::Die->die(
	$request->uri,
	': uri request failed: ',
	$fields->{response}->code,
	' ',
	$fields->{response}->message,
    ) unless $fields->{response}->is_success;

    $fields->{cookies}->extract_cookies($fields->{response});
    $fields->{html_parser} =
	Bivio::Test::HTMLParser->new($fields->{response}->content_ref)
        if $fields->{response}->content_type eq 'text/html';
    $fields->{redirect_count} = $redirect_count;
    return;
}

# _validate_text_field(hash_ref field, string value)
#
# Dies if the text field has multipel lines.
#
sub _validate_text_field {
    my($field, $value) = @_;
    Bivio::Die->die('text input must be a single line: ', $field->{label})
        if $field->{type} eq 'text' && ($value || '') =~ /\n/;
    return;
}

# _verify_form_field(self, hash_ref control, hash_ref case)
#
# Find value of the form field.
#
sub _verify_form_field {
    my($self, $control, $case) = @_;
    if ($control->{type} eq 'checkbox') {
	$case->{expected} = 0
	    unless defined($case->{expected});
	$case->{result} = $control->{checked}
	    ? defined($control->{value}) ? $control->{value} : 1
	    : 0;
    }
    elsif ($control->{options}) {
	$case->{result} = _verify_form_option($control);
    }
    else {
	$case->{result} = $control->{value};
    }
    return;
}

# _verify_form_option(hash_ref control, string value) : string
#
# Return the state of option.
#
sub _verify_form_option {
    my($control, $value) = @_;
    foreach my $o (keys(%{$control->{options}})) {
	return $o
	    if $control->{options}->{$o}->{selected};
    }
    return undef;
}

# _wait_for_server(self, int timeout)
#
# Wait for server to respond.  DOES NOT DIE.
#
sub _wait_for_server {
    my($self, $timeout) = @_;
    my($fields) = $self->[$_IDI];

    # Try to be smart about error message. 500 isn't unique to
    # a down server and we don't want to wait around on a server
    # that is live, but is dying on an Internal Server Error

    my($request) = HTTP::Request->new(GET => $self->home_page_uri());
    foreach my $i (1..$timeout) {
	my($response) = $fields->{user_agent}->request($request);
	last
	    unless $response->code() == 500
		&& $response->message() =~ /^Can't connect to/;
	sleep(1);
    }

    return;
}

=head1 COPYRIGHT

Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
