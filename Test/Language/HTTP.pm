# Copyright (c) 2002-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Language::HTTP;
use strict;
use Bivio::Base 'Test.Language';
b_use('IO.Trace');
use HTTP::Request ();
use HTTP::Request::Common ();
use URI ();
use Email::MIME::Encodings ();
b_use('IO.Trace');

our($_TRACE);
my($_HTTPC) = b_use('Ext.HTTPCookies');
my($_E) = b_use('Type.Email');
my($_R) = b_use('IO.Ref');
my($_F) = b_use('IO.File');
my($_HTMLF) = b_use('TestHTMLParser.Forms');
my($_T) = b_use('IO.Trace');
my($_HTMLP) = b_use('Test.HTMLParser');
my($_HTML) = b_use('Bivio.HTML');
my($_DT) = b_use('Type.DateTime');
my($_FN) = b_use('Type.FileName');
my($_IDI) = __PACKAGE__->instance_data_index;
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    # NOTE: There is no ENV when loaded under apache
    email_user => $ENV{USER} || 'btest',
    server_startup_timeout => 0,
    home_page_uri => $_C->REQUIRED,
    local_mail_host => b_use('Bivio.BConf')->bconf_host_name,
    remote_mail_host => undef,
    mail_dir => $ENV{HOME} ? "$ENV{HOME}/btest-mail/" : '',
    mail_tries => 60,
    email_tag => '+btest_',
    deprecated_text_patterns => $_C->if_version(
        4 => sub {0},
        sub {1},
    ),
    parse_head => 1,
});
my($_VERIFY_MAIL_HEADERS) = [b_use('Mail.Common')->TEST_RECIPIENT_HDR, 'To'];

sub LOCAL_EMAIL_RE {
    # Must be synchronized with generate_local_email
    return qr{\Q$_CFG->{email_tag}\E(.+?)=(.+?\.(?:\w+))\@}i;
}

sub absolute_uri {
    my($self, $uri) = @_;
    die('invalid uri')
        unless defined($uri) && length($uri);
    my($u) = URI->new($uri = $self->internal_append_query($uri));
    return defined($u->scheme) ? $uri : $u->abs(
        $self->[$_IDI]->{uri}
        || b_die($uri, ': unable to make absolute; no prior URI')
    )->canonical->as_string;
}

sub audit_links {
    my($self, $callback) = @_;
    my($base) = $self->get_uri;
    my($notes) = {
        _has_dead => {},
    };
    my($add_link) = sub {
        my($href, $link) = @_;
        $notes->{$href} ||= {
            from => {},
            to => {},
        };
        return $notes->{$href};
    };
    my($link_x_to_y) = sub {
        my($x, $y) = @_;
        $add_link->($x)->{to}->{$y}++;
        $add_link->($y)->{from}->{$x}++;
        return;
    };
    my($dead_link) = sub {
        $notes->{shift()}->{dead}++;
        return;
    };
    my($live_link) = sub {
        $notes->{shift()}->{live}++;
        return;
    };
    my($skip) = sub {
        # only follow hrefs we haven't already checked.
        # don't follow any that logout
        # only follow local links
        my($href) = @_;
        return 1
            if exists($notes->{$href}->{dead})
                || exists($notes->{$href}->{live})
                || $href =~ m{logout|register|adm/su\?|forgot-password};
        return 1
            unless $href =~ m{^/|^$base};
        return 0;
    };
    my($links) = [$base];
    while(my $href = shift(@$links)) {
        $href =~ s/\?.*$//; #ignore query
        next if $skip->($href);
        if (Bivio::Die->catch_quietly(sub {$self->visit_uri($href)})) {
            $dead_link->($href);
            next;
        }
        $live_link->($href);
        $callback->($href, $self->get_content)
            if ref($callback) && ref($callback) eq 'CODE';
        next unless $self->get_content =~ /<html>/i;
        my($newlinks) = $self->get_html_parser->get('Links');
        my($images) = $self->get_html_parser->get('Images');
        push(@$links, map({
            my($collection, $key) = @$_;
            map({
                my($l) = $collection->get($_);
                $link_x_to_y->($href, $l->{$key});
                $l->{$key};
            } @{$collection->get_keys})
        } [$newlinks, 'href'], [$images, 'src']));
    }
    return $notes;
}

sub basic_authorization {
    my($self, $user, $password) = @_;
    return $self->delete('Authorization')
        unless $user;
    $self->clear_cookies;
    $self->put(Authorization =>
        'Basic ' . MIME::Base64::encode(
            $user . ':' . ($password || $self->default_password)));
    return;
}

sub case_tag {
    my($self, $tag) = @_;
    b_die($tag, ': invalid case tag')
        unless ($tag || '') =~ /^[-\w ]+$/;
    $self->put(case_tag => $tag);
    return;
}

sub clear_cookies {
    # Clear the cookies
    shift->[$_IDI]->{cookies}->clear();
    return;
}

sub clear_extra_query_params {
    my($self) = @_;
    $self->delete('extra_query_params');
    return;
}

sub clear_local_mail {
    unlink(_grep_mail_dir());
    return;
}

sub date_time_now {
    my($self, $now) = @_;
    $now = $_DT->set_test_now($now, _req($self));
    $self->clear_extra_query_params;
    $self->extra_query_params(
        $_DT->TEST_NOW_QUERY_KEY => $now,
    ) if $now;
    return $now;
}

sub debug_print {
    my($self, $what) = @_;
    # Prints 'Forms' or 'Links' to STDOUT.
    print(STDOUT ${$_R->to_string(
        _assert_html($self)->get($what)->get_shallow_copy)});
    return;
}

sub default_password {
    return shift->use('ShellUtil.TestUser')->DEFAULT_PASSWORD;
}

sub deprecated_text_patterns {
    my($self, $value) = @_;
    $self->put(deprecated_text_patterns => $value)
        if defined($value);
    return $self->get('deprecated_text_patterns');
}

sub do_logout {
    my($self) = @_;
    $self->basic_authorization;
    $self->visit_uri('/pub/logout')
        unless $self->unsafe_op(follow_link => qr{logout}i);
    return;
}

sub do_table_rows {
    my($self, $table_name, $do_rows_callback) = @_;
    return _assert_html($self)->get('Tables')
        ->do_rows(_fixup_pattern_protected($self, $table_name), $do_rows_callback);
}

sub do_test_backdoor {
    my($self, $op, $args) = @_;
    # Executes ShellUtil or FormModel based on $args.
    $self->visit_uri(
        '/t*backdoor?'
        . b_use('AgentHTTP.Query')->format(
            ref($args) eq 'HASH'
                ? {%$args, form_model => $op}
                : ref($args) eq ''
                ? {shell_util => $op, command => $args}
                : b_die($args, ': unable to parse args'),
            _req($self),
        )
    );
    return;
}

sub do_test_trace {
    my($self, $named_filter) = @_;
    $named_filter ||= '';
    my($prev) = [$_T->get_call_filter, $_T->get_package_filter];
    $_T->set_named_filters($named_filter)
        if $named_filter;
    $_T->set_filters(@$prev);
    $self->visit_uri("/t*trace/$named_filter");
    $self->go_back;
    return;
}

sub escape_html {
    my(undef, $value) = @_;
    return $_HTML->escape($value);
}

sub extra_query_params {
    my($self, $key, $value) = @_;
    # Append extra query params.
    push(
        @{$self->get_if_exists_else_put(extra_query_params => [])},
        $key,
        $value,
    );
    return;
}

sub extract_uri_from_local_mail {
    return (shift->uri_and_local_mail(@_))[0];
}

sub file_field {
    my($self, $name, $content) = @_;
    # Returns a value to be used by submit_form() with I<file_name> or I<name> as the
    # name.  Uses a temporary file which is cleaned up at program exit if I<content>
    # is supplied.
    return [$name, $name]
        unless defined($content);
    return [$_F->write($self->temp_file($name), $content), $name];
}

sub find_page_with_text {
    my($self, $pattern) = @_;
    $self->follow_link(qr{^next$}i)
        until $self->text_exists($pattern);
    return;
}

sub find_table_row {
    return _find_row(@_);
}

sub follow_frame {
    my($self, $name) = @_;
    return $self->visit_uri(
        _assert_html($self)->get('Frames')
        ->get($name)
        ->{src},
    );
}

sub follow_link {
    my($self, @links) = @_;
    my($res);
    foreach my $link (@links) {
        $res = $self->visit_uri($self->get_uri_for_link($link));
    }
    return $res;
}

sub follow_link_in_mail {
    my($self) = shift;
    $self->visit_uri($self->extract_uri_from_local_mail(@_));
    return;
}

sub follow_link_in_table {
    my($self) = shift;
    return $self->visit_uri($self->get_link_in_table(@_));
}

sub follow_menu_link {
    return shift->follow_link(map(_fixup_pattern($_, 1), @_));
}

sub generate_local_email {
    my($self, $suffix, $domain) = @_;
    if ($_E->is_valid($suffix)) {
        return $suffix
            unless $domain;
        $suffix = $_E->get_local_part($suffix);
        $suffix =~ s{.*\Q\$_CFG->{email_tag}}{};
    }
    # Returns an email address based on I<email_user> and I<suffix>.
    b_die('missing suffix')
        unless defined($suffix);
    return lc($_CFG->{email_user}
        . $_CFG->{email_tag}
        . $suffix
        # Must be synchronized with LOCAL_EMAIL_DOMAIN_RE
        . ($domain ? "=$domain" : '')
        . '@'
        . $_CFG->{local_mail_host});
}

sub generate_remote_email {
    my($self, $base, $facade_uri) = @_;
    if ($_E->is_valid($base)) {
        return $base
            unless $facade_uri;
        $base = $_E->get_local_part($base);
    }
    # Generates an email for the remote server.  Appends  @I<remote_mail_host> with
    # I<facade_uri>. prefix if it is supplied.
    return _facade($self, "$base\@$_CFG->{remote_mail_host}", $self, $facade_uri);
}

sub generate_test_name {
    my($self, $suffix) = @_;
    # return 'btest_'.I<suffix>.
    return 'btest_'.$suffix;
}

sub get_content {
    # Returns the current page content.
    return shift->get_response->content;
}

sub get_html_parser {
    my($self) = @_;
    # Returns the HTML parser for the current page.
    return _assert_html($self);
}

sub get_link_in_table {
    my($self) = shift;
    my($table_name) = @_ > 2 ? shift : $_[0];
    my($find_heading, $find_value, $link_heading, $link_name) = @_;
    $table_name = $find_heading
        unless defined($table_name);
    my($row) = _find_row($self, $table_name, $find_heading, $find_value);
    $link_heading = _key_from_hash(
        $row,
        _fixup_pattern_protected(
            $self,
            defined($link_heading) ? $link_heading : $find_heading),
    );
    b_die($link_heading, ': column empty')
        unless defined($row->{$link_heading});
    my($links) = $row->{$link_heading}->get('Links');
    my($k) = $links->get_keys;
    return (
        !defined($link_name) && @$k == 1 ? $links->get($k->[0])
            : _get_attr(
                $links,
                _fixup_pattern_protected(
                    $self,
                    defined($link_name) ? $link_name : $find_value)),
    )->{href};
}

sub get_response {
    # Returns the current page response, or dies if response not valid.
    return shift->[$_IDI]->{response} || b_die('no valid response');
}

sub get_table_row {
    my($self, $table_name, $row_index) = @_;
    $row_index ||= 0;
    my($found_row);
    $self->get_html_parser()->get('Tables')->do_rows(
        _fixup_pattern_protected($self, $table_name),
        sub {
            my($row, $index) = @_;
            return 1
                unless $index == $row_index;
            $found_row = $row;
            return 0;
        },
    );
    return $found_row
        || Bivio::Die->($row_index, ': no such row number in ', $table_name);
}

sub get_uri {
    # Returns the uri for the current page.  Blows up if no current uri.
    return shift->unsafe_get_uri || b_die('no current uri');
}

sub get_uri_for_link {
    return _html_get(shift, Links => shift)->{href};
}

sub go_back {
    my($self, $count) = @_;
    my($fields) = $self->[$_IDI];
    my($x) = reverse(map(
        pop(@{$fields->{history}}) || b_die('no page to go back to'),
        1 .. $count || 1,
    ));
    while (my($k, $v) = each(%$x)) {
        $fields->{$k} = $v;
    }
    return;
}

sub handle_cleanup {
    my($self) = @_;
    my($req) = b_use('Test.Request')->get_current;
    $req->call_process_cleanup
        if $req;
    return shift->SUPER::handle_cleanup(@_);
}

sub handle_config {
    my(undef, $cfg) = @_;
    # email_tag : string [+btest_]
    #
    # What to include between the I<email_user> and I<suffix> in
    # L<generate_local_email|"generate_local_email">.
    #
    # email_user : string [$ENV{LOGNAME}]
    #
    # Base user name to use in email.  Emails will go to:
    #
    #     email_user+btest_suffix
    #
    # Where suffix is supplied to L<generate_local_email|"generate_local_email">.
    #
    # server_startup_timeout : int [0]
    #
    # Maximum number of attempts to connect to the server on startup.
    # Each try is about 1 second.
    #
    # home_page_uri : string (required)
    #
    # URI of home page.
    #
    # mail_dir : string [$ENV{HOME}/btest-mail]
    #
    # Directory in which mail resides.  Set up your .procmailrc to have a rule:
    #
    #     :0 H
    #     * ^TO_.*\<btest_
    #     btest-mail/.
    #
    # Make sure the permissions are 0600 on your .procmailrc.
    #
    # mail_tries : int [60]
    #
    # Maximum number of attempts to get mail.  Each try is about 1 second.
    #
    # remote_mail_host : string [host of home_page_uri]
    #
    # You can set the uri of the remote host.
    b_die($cfg->{email_user}, ': email_user must be an alphanum')
        if ($cfg->{email_user} || '') =~ /\W/;
    b_die($cfg->{mail_tries},
        ': mail_tries must be a postive integer')
        if $cfg->{mail_tries} =~ /\D/ || $cfg->{mail_tries} <= 0;
    b_die($cfg->{server_startup_timeout},
        ': server_startup_timeout must be a postive integer')
        if $cfg->{server_startup_timeout} =~ /\D/
            || $cfg->{server_startup_timeout} < 0;
    $cfg->{remote_mail_host} ||= URI->new($cfg->{home_page_uri})->host;
    $_CFG = $cfg;
    return;
}

sub handle_setup {
    my($self) = shift;
    # Clears files in I<mail_dir>.
    $self->SUPER::handle_setup(@_);
    $self->clear_local_mail;
    _wait_for_server($self, $_CFG->{server_startup_timeout})
        if $_CFG->{server_startup_timeout} && ref($self);
    return;
}

sub home_page {
    my($self) = shift;
    return $self->visit_uri($self->home_page_uri(@_));
}

sub home_page_uri {
    my($self, $facade) = @_;
    return _facade(
        $self,
        $_CFG->{home_page_uri},
        $self,
        $self->http_facade(@_ > 1 ? $facade : ()),
    );
}

sub http_facade {
    my($self, $facade) = @_;
    return undef
        unless ref($self);
    $self->put(http_facade => $facade)
        if @_ > 1;
    return $self->unsafe_get('http_facade');
}

sub internal_append_query {
    my($self, $u) = @_;
    # query should be [k1 => v1, k2 => v2, ...]
    my($q) = $self->unsafe_get('extra_query_params');
    return $u
        unless defined($q);
    my($uri) = URI->new($u);
    $q = {$uri->query_form, @$q};
    $uri->query_form(map(($_ => $q->{$_}), sort(keys(%$q))));
    return $uri->canonical->as_string;
}

sub internal_assert_no_prose {
    my($self, $content) = @_;
    my($d) = $$content;
    $d =~ s{<script.*?>.*?</script>}{}isg;
    $d =~ s{(?:javascript:|\son[a-z]+=\")[^"]+"}{}isg;
    if ($d !~ /\w+::\w+/ && $d =~ /\b((\w+)\([^\)]*\)\;)/s) {
        my($cmd, $func) = ($1, $2);
        b_die($cmd, ': Prose found in response')
            if $func =~ /(?:^[A-Z]|_)/
    }
    return $content;
}

sub is_local_email {
    my($self, $email) = @_;
    my($suffix) = $_CFG->{local_mail_host};
    return $email =~ /\@\Q$suffix\E$/ ? 1 : 0;
}

sub local_mail_host {
    return $_CFG->{local_mail_host};
}

sub login_as {
    my($self, $email, $password, $facade) = @_;
    $self->home_page($facade ? $facade : ());
    $self->visit_uri('/pub/login')
        unless $self->unsafe_op(follow_link => qr{login}i);
    $self->submit_form(Login => {
        qr{email|user}i => $email,
        qr{password}i =>
            defined($password) ? $password : $self->default_password,
    });
    return;
}

sub new {
    my($proto, $lang, $uri) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
        cookies => $_HTTPC->new,
        user_agent => b_use('Ext.LWPUserAgent')->new
            ->bivio_ssl_no_check_certificate,
        history => [],
        history_length => 5,
    };
    unless ($_CFG->{parse_head}) {
        # avoid X-Died: Illegal field name 'X-Meta-...'
        $self->[$_IDI]->{user_agent}->parse_head(0);
    }
    $self->put(
        deprecated_text_patterns => $_CFG->{deprecated_text_patterns},
        local_mail_host => $_CFG->{local_mail_host},
    );
    return $self;
}

sub poll_page {
    my($self, $method, @args) = @_;
    foreach my $x (1..$_CFG->{mail_tries}) {
        sleep(1);
        $self->reload_page;
        return
            if $self->unsafe_op($method, @args);
    }
    $self->$method(@args);
    return;
}

#TODO: Would be good to share with Test.Unit
sub random_integer {
    return shift->use('Biz.Random')->integer(@_);
}

sub random_alpha_string {
    return shift->random_string(undef, ['a' .. 'z']);
}

sub random_string {
    return shift->use('Biz.Random')->string(@_);
}

sub read_file {
    my(undef, $file) = @_;
    return $_F->read($file);
}

sub reload_page {
    my($self, $uri) = @_;
    # Reloads the current page.  Intended to be used after a deviance
    # test to clear errors so that conformance tests can be resumed.
    # If defined, uses given uri, otherwise uses get_uri()
    defined($uri) ? $self->visit_uri($uri) :
        $self->visit_uri($self->get_uri());
    return;
}

sub reset_password {
    my($self, $email, $password) = @_;
    $password ||= $self->default_password;
    $self->do_logout;
    $self->follow_link('login', 'forgot');
    $self->clear_local_mail;
    $self->submit_form({email => $email});
    $self->visit_uri($self->extract_uri_from_local_mail($email));
    $self->submit_form({
        qr{^new}i => $password,
        qr{^re-enter}i => $password,
    });
    return;
}

sub reset_user_agent {
    return shift->user_agent(undef);
}

sub save_cookies_in_history {
    my($self, $mode) = @_;
    return $self->put(save_cookies_in_history => $mode);
}

sub save_excursion {
    my($self, $op) = @_;
    my($fields) = $self->[$_IDI];
    b_die('no history to save')
        unless @{$fields->{history}};
    _save_history($self);
    my($save) = $_R->nested_copy($fields->{history});
    $self->go_back;
    $op->();
    $fields->{history} = $save;
    $self->go_back;
    return;
}

sub send_mail {
    my($self, $from_email, $to_email, $headers, $body) = @_;
    # Send a message.  Returns the object.  Sets subject and body to unique values.
    my($r) = $self->random_string();
    my($o) = b_use('Mail.Outgoing')->new;
    $o->test_language_setup;
    $o->set_recipients($to_email, _req($self));
    $o->set_header(To => ref($to_email) ? join(',', @$to_email) : $to_email);
    $headers = {
        Subject => "subj-$r",
        $headers ? %$headers : (),
    };
    foreach my $k (sort(keys(%$headers))) {
        $o->set_header($k, $headers->{$k});
    }
    $o->set_body($body || "Any unique $r body\n");
    $o->add_missing_headers(_req($self), $from_email);
    $o->send(_req($self));
    return $o;
}

sub send_request {
    my($self, $method, $uri, $header, $content) = @_;
    my($fields) = $self->[$_IDI];
    $uri = $self->absolute_uri($uri);
    $header = [%$header]
        if ref($header) eq 'HASH';
    $header ||= [];
    _send_request(
        $self,
        uc($method) eq 'POST' && ref($content) eq 'ARRAY'
            ? _create_form_post($uri, $content, $header)
            : HTTP::Request->new(
                $method => $uri,
                HTTP::Headers->new(@$header),
                $content,
            ),
    );
    return;
}

sub set_is_not_bivio_html {
    return shift->put(is_not_bivio_html => 1);
}

sub set_user_agent_to_actual_browser {
    return shift->user_agent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10.5; rv:7.0.1) Gecko/20100101 Firefox/7.0.1');
}

sub set_user_agent_to_robot_other {
    return shift->user_agent('libwww-perl/5.79');
}

sub set_user_agent_to_robot_search {
    return shift->user_agent('Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)');
}

sub submit_form {
    my($self, $submit_button, $form_fields, $expected_content_type) = @_;
    # Submits I<form_fields> using I<submit_button> (or none, if no submit
    # button). Only fields specified will be sent.  Asserts I<expected_content_type>
    # is expected_content_type (default: text/html).  If I<expected_content_type> is
    # text/html, form is checked for submission errors.  If I<expected_content_type>
    # is not text/html, won't check for submission errors.

    my($forms) = _assert_html($self)->get('Forms');
    my($form);
    if (!defined($submit_button)) {
        $form_fields = _fixup_form_fields($self, $form_fields);
        $form = $forms->get_by_field_names(keys(%$form_fields));
    }
    elsif (ref($submit_button) eq 'HASH') {
        $expected_content_type = $form_fields;
        $form_fields = _fixup_form_fields($self, $submit_button);
        $form = $forms->get_by_field_names(keys(%$form_fields));
        $submit_button = $forms->get_ok_button($form);
    }
    else {
        $form_fields = _fixup_form_fields($self, $form_fields || {});
        $submit_button = _fixup_pattern_protected($self, $submit_button);
        $form = $forms->get_by_field_names(
            keys(%$form_fields),
            $submit_button,
        );
    }
    _send_request($self,
        _create_form_request(
            $self, uc($form->{method}),
            $self->absolute_uri($form->{action} || $self->unsafe_get_uri),
            _format_form($self, $form, $submit_button, $form_fields)));
    _assert_form_response($self, $expected_content_type);
    return;
}

sub submit_from_table {
    my($self) = shift;
    # Finds the row identified by I<find_value> in column I<submit_heading>
    # of I<table_name> using I<_find_row>.
    #
    # Then submits the form via I<submit_name>, passing in I<form_values>.
    # If I<form_values> is undef, then substitutes an empty hashref.
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

sub submit_realm_file_plain_text {
    my($self, $realm, $folder, $file, $text) = @_;
    $self->visit_realm_folder($realm, $folder);
    $self->follow_link_in_table(
        'Name', 'Name', $folder ? File::Basename::basename($folder) : '/', 'Actions', 'Modify');
    $self->visit_realm_file_change_mode('TEXT_FILE');
    $self->submit_form(ok => {
        'Name:' => $file,
        _anon => $text,
        'Comments:' => 'n/a',
    });
    return;
}

sub temp_file {
    my($self, $name) = @_;
    return $_F->temp_file(_req($self), $name || ($self->test_name . '.tmp'));
}

sub text_exists {
    my($self, $pattern) = @_;
    # Returns true if I<pattern> exists in response (must be text/html),
    # else false.
    $pattern = qr/\Q$pattern/
        unless ref($pattern) && ref($pattern) eq 'Regexp';
    return $self->get_content =~ $pattern ? 1 : 0;
}

sub tmp_file {
    Bivio::IO::Alert->warn_deprecated('use temp_file()');
    return shift->temp_file(@_);
}

sub unsafe_get_uri {
    # Gets current uri or returns undef.
    return shift->[$_IDI]->{uri};
}

sub unsafe_op {
    my($self, $method, @args) = @_;
    return Bivio::Die->catch_quietly(sub {$self->$method(@args)}) ? 0 : 1;
}

sub uri_and_local_mail {
    my($m) = shift->verify_local_mail(@_);
    $m =~ qr{<html>}
        ? $m =~ qr{<a[^>]+href="(https?.+?)"}
        : $m =~ qr{(https?:\S+)};
    b_die('missing uri in mail: ', $m)
        unless $1;
    return ($1, $m);
}

sub user_agent {
    my($self, $string) = @_;
    return $self->get_or_default(
        'user_agent_string',
        sub {
            return 'Mozilla/5.0 (compatible; '
                . _test_script_location($self)
                . ')';
        },
    ) if @_ <= 1;
    return $self->delete('user_agent_string')
        unless $string;
    return $self->put(user_agent_string => $string);
}

sub user_agent_instance {
    return shift->[$_IDI]->{user_agent};
}

sub user_agent_timeout {
    my($self, $seconds) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{user_agent}->timeout($seconds);
    return;
}

sub verify_content_type {
    my($self, $mime_type) = @_;
    # Verifies the Content-Type of the reply.
    my($ct) = $self->get_response->content_type;
    b_die($ct, ': response not ', $mime_type)
        unless $ct eq $mime_type;
    return;
}

sub verify_form {
    my($self, $form_fields) = @_;
    # Verifies the state of I<form_fields>. Only fields specified will be
    # verified.
    my($fields) = $self->[$_IDI];
    $form_fields = _fixup_form_fields($self, $form_fields || {});
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
        b_die($control->{type}, ' ', $field, ' expected: ',
            $case->{expected}, ' but got: ', $case->{result})
                unless
                    (ref($case->{expected}) eq 'Regexp'
                         && $case->{result} =~ $case->{expected})
                    || ($case->{expected} || '') eq ($case->{result} || '');
    }
    return;
}

sub verify_link {
    my($self, $link_text, $pattern) = @_;
    my($href) = _html_get($self, Links => $link_text)->{href};
    b_die($href, ': does not match pattern: ', $pattern)
        if $pattern && $href !~ $pattern;
    return;
}

sub verify_local_mail {
    my($self, $email, $body_regex, $expect_count) = @_;
    # Get the last messages received for I<recipient_email> (see
    # L<generate_local_email|"generate_local_email">) and verify that
    # I<body_regex> matches.  Deletes the message(s) on a match.
    #
    # Polls for I<mail_tries>.  If multiple messages come in simultaneously, will
    # only complete if both I<recipient_email> and I<body_regex> match.
    #
    # I<count> defaults to at least one (not if set explicitly, which is
    # exactly $count).  An exception is thrown if the number of messages found
    # is not equal to I<count>.  Returns and array with I<count> strings of the
    # messages found.
    my($body_re) = !defined($body_regex) ? qr{}
        : ref($body_regex) ? $body_regex : qr{$body_regex};
    my($count) = defined($expect_count) ? $expect_count
        : (ref($email) eq 'ARRAY' ? int(@$email) : 1);
    b_die($_CFG->{mail_dir},
        ': mail_dir mail directory does not exist')
        unless -d $_CFG->{mail_dir};
    my($match) = {};
    $email = [$email]
        unless ref($email) eq 'ARRAY';
    $email = [map(ref($_) || $_ =~ /\@/ ? $_
        : $self->generate_local_email($_), @$email)];
    my($found) = [];
    my($die) = sub {b_die(@_, "\n", $found)};
    for (my $i = $_CFG->{mail_tries}; $i-- > 0;) {
        # It takes a certain amount of time to hit, and on the same machine
        # we're going to be competing for the CPU so let b-sendmail-http win
        sleep(1);
        $found = _grep_msgs($self, $email, $body_re, $match);
        next
            if @$found < $count;
        last
            unless defined($expect_count);
        $i -= int($i/2);
    }
    my($matched_emails) = [sort(keys(%$match))];
    return undef
        if defined($expect_count) && $count == 0 && !@$matched_emails;
    $die->(%$match
        ? ('Found mail for "', $email, '", but does not match ',
           $body_re, ' matches=', $matched_emails)
        : ('No mail for "', $email, '" found in ', $_CFG->{mail_dir}),
    ) unless @$found;
    $die->(
        'incorrect number of messages.  expected != actual: ',
        $count,
        ' != ',
        int(@$found),
    ) unless !defined($expect_count) || @$found == $count;
    $die->(
        'correct number of messages, but emails expected != actual: ',
        [sort(@$email)],
        ' != ',
        $matched_emails,
    ) unless @$email == @$matched_emails;
    foreach my $f (@$found) {
        unlink($f->[0]);
        _log($self, 'eml', $f->[1])
            if ref($self);
    }
    return @$found
        ? wantarray
        ? map(${$_->[1]}, @$found)
        : ${$found->[0]->[1]}
        : wantarray
        ? ()
        : undef;
}

sub verify_no_link {
    my($self, $link_text, $pattern) = @_;
    my($link) = _unsafe_html_get($self, Links => $link_text);
    return unless defined($link);
    b_die('found link "', $link_text, '".')
        if !defined($pattern);
    my($href) = $link->{href};
    b_die($href, ': matches pattern: ', $pattern)
        if defined($href) && $href =~ $pattern;
    return;
}

sub verify_no_text {
    my($self, $text) = @_;
    # Verifies that I<text> DOES NOT appear on the page.
    b_die($text, ': text found in response')
        if $self->text_exists($text);
    return;
}

sub verify_options {
    my($self, $select_field, $options) = @_;
    # Verifies that the given I<select_field> includes the given I<options>.
    my($fields) = $self->[$_IDI];
    my($form) = _assert_html($self)->get('Forms')
        ->get_by_field_names($select_field);
    my($f) = _assert_form_field($form, $select_field);
    b_die(
        'Select field "', $select_field, '" does not contain any options.',
    ) unless $f->{options};
    foreach my $option (@$options) {
        b_die(
            'Select field "', $select_field, '" does not contain option "',
            $option, '".',
        ) unless $f->{options}->{$option};
    }
    return;
}

sub verify_pdf {
    my($self, $text) = @_;
    # Converts the current response from pdf to text (with I<pdftotext>) and
    # validates that I<text> is contained therein.  I<text> is not escaped
    # in the regular expression.
    $self->verify_content_type('application/pdf');
    my($f) = _log($self, 'pdf', $self->get_content);
    system("pdftotext '$f'") == 0
        or b_die($f, ': unable to convert pdf to text');
    $f =~ s/pdf$/txt/;
    my($pdf_text) = ${$_F->read($f)};
    b_die($text, ': text not found in response ', $f)
        unless $pdf_text =~ /$text/s;
    return $pdf_text;
}

sub verify_table {
    my($self, $table_name, $expect) = @_;
    # Verify that table I<table_name> contains the expected rows given in
    # I<expectations>.  I<expectations> should be an array_ref of array_refs -- kinda
    # like a table.  The first row defines the column labels whose values will be
    # verified.  The first column is used to uniquely identify the row.  The order of
    # rows is not enforced and the order of columns do not need to match the order in
    # the form (though the expected values do need to correspond to the expected
    # column labels).
    my($cols) = shift(@$expect);
    b_die('missing rows values')
        unless int(@$expect);
    my($first_col) = shift(@$cols);
    foreach my $e (@$expect) {
        my($a) = _find_row($self, $table_name, $first_col, shift(@$e));
        my($diff) = $_R->nested_differences(
            $e,
            [map($a->{_key_from_hash($a, _fixup_pattern_protected($self, $_))}
                ->get('text'),
                @$cols,
            )],
        );
        b_die($diff)
            if $diff;
    }
    return;
}

sub verify_text {
    my($self, $text) = @_;
    # Verifies I<text> appears on the page.
    b_die($text, ': text not found in response')
        unless $self->text_exists($text);
    return;
}

sub verify_title {
    my($self, $title) = @_;
    # Verifies that the specified title appears on the page.
    b_die($title, ': title not found in response')
            unless $self->get_content =~ /\<title\>.*$title.*\<\/title\>/i;
    return;
}

sub verify_uri {
    my($self, $uri) = @_;
    # Verifies that the current uri (not including http://.../) matches I<uri>.
    my($current_uri) = $self->get_uri;
    b_die('Current uri ', $current_uri, ' does not match ', $uri)
        unless $current_uri =~ $uri;
    return;
}

sub verify_zip {
    my($self, $expected) = @_;
    # Recursively unzips the current response and compares against the
    # expected zip file contents passed as an array ref in I<expected>.
    # The array contains pairs of expected member names and expected
    # member content.
    # The member name is a string or a regexp.
    # The expected content is one of:
    #
    # o A string that must be exectly equal to the entire zip member content
    #
    # o A regexp that must match the zip member content
    #
    # o A hash reference with optional keys 'present' and 'absent' whose
    #   values are regexps specifying text that must respectively be present
    #   in, and absent from, the member content.
    #
    # o An array reference specifying the content of an embedded zip file
    #
    # o undefined, meaning that the member content can be anything.
    #
    # 'expected' example:
    #  [
    #     'myfile.bin' => undef,
    #     'hello.txt' => 'Hello World',
    #     'goodbye.txt' => qr/bye/,
    #     'cake.txt' => {
    #          present => qr/flour/,
    #          absent => qr/sand/,
    #      },
    #      qr/file-\d\d\d.pdf/ => qr/^%PDF/,
    #     'a.zip' => [
    #               'a.txt' => undef,
    #               'b.zip' => [
    #                   'b1.txt' => undef,
    #               ],
    #               'c.txt' => undef,
    #      ],
    # ];
    _verify_zip($self, $self->get_content, $expected);
    return;
}


sub visit_realm_file {
    my($self, $realm, $path) = @_;
    return $self->visit_uri("/$realm/file/$path");
}

sub visit_realm_file_change_mode {
    my($self, $mode) = @_;
    return $self->visit_uri(
        join('',
             $self->get_uri(),
             '&',
             b_use('Model.FileChangeForm')->QUERY_KEY,
             '=',
             $mode,
        ),
    );
}

sub visit_realm_folder {
    my($self, $realm, $path) = @_;
    $self->visit_uri("/$realm/files");
    foreach my $folder (split(qr{/+}, defined($path) ? $path : '')) {
        next
            unless length($folder);
        $self->follow_link(qr{^\Q$folder\E$}i);
    }
    return;
}

sub visit_uri {
    my($self, $uri) = @_;
    # Loads the page using the specified URI.
    _trace($uri) if $_TRACE;
#TODO: No referer when we are visiting
    _send_request($self, HTTP::Request->new(GET => $self->absolute_uri($uri)));
    return;
}

sub _assert_form_field {
    # Returns the named field from form->class or dies.
    return $_HTMLF->get_field(@_);
}

sub _assert_form_response {
    my($self, $expected_content_type) = @_;
    # Asserts result of form is valid.
    $expected_content_type ||= 'text/html';
    my($fields) = $self->[$_IDI];
    return
        if $fields->{redirect_count} > 0;

    if ($expected_content_type eq 'text/html') {
        my($forms) = _assert_html($self)->get('Forms')->get_shallow_copy;
        while (my($k, $v) = each(%$forms)) {
            b_die('form submission errors: ', $v->{errors})
                if $v->{errors};
            b_die(
                'form error title without field errors. Visible fields: ',
                [sort(map(keys(%{$v->{$_}}), qw(visible submit)))],
            ) if $v->{error_title_seen};
        }
    }
    else {
        my($content_type) = $self->get_response->content_type;
        b_die($content_type, ': response not ',
            $expected_content_type)
                if $content_type ne $expected_content_type;
    }
    return;
}

sub _assert_html {
    my($self) = @_;
    # Asserts HTML and returns parser
    return $self->[$_IDI]->{html_parser} || b_die(
        $self->get_response->content_type, ': response not html');
}

sub _create_form_post {
    my($uri, $form, $header) = @_;
    return grep(ref($_), @$form)
        ? HTTP::Request::Common::POST(
            $uri,
            Content_Type => 'form-data',
            Content => $form,
            @$header,
        ) : HTTP::Request::Common::POST($uri, $form, @$header);
}

sub _create_form_request {
    my($self, $method, $uri, $form) = @_;
    # Creates appropriate form request based on method (uc).
    if ($method eq 'GET') {
        # trim any query which might be there
        $uri =~ s/\?.*//;
        my($url) = URI->new('http:');
        $url->query_form(@$form);
        return HTTP::Request->new(
            GET => $self->internal_append_query($uri . '?' . $url->query));
    }
    return _create_form_post($self->internal_append_query($uri), $form, []);

}

sub _facade {
    my($self, $to_fix, undef, $facade_uri) = @_;
    return $to_fix
        unless $facade_uri;
    my($req) = b_use('TestUnit.Request')->get_instance;
    my($default) = (
        $req->unsafe_get('Bivio::UI::Facade')
            || $req->initialize_fully->get('Bivio::UI::Facade')
    )->get_default->get('uri');
    $to_fix =~ s{^(.*?)\b$default\b}{$1$facade_uri}ix
        || $to_fix =~ s{(?<=\://)|(?<=\@)}{$facade_uri.}ix
        || b_die($to_fix, ': unable to fixup uri with ', $facade_uri)
        unless $default eq $facade_uri;
    return $to_fix
}

sub _find_row {
    my($self, $table_name, $find_heading, $find_value) = @_;
    # Returns the hashref for row identified by I<table_name>, <I>find_heading
    # and <I>find_value, using L<Bivio::Test::HTMLParser::Tables::find_row|Bivio::Test::HTMLParser::Tables/"find_row">.
    return _assert_html($self)->get('Tables')->find_row(
        _fixup_pattern_protected($self, $table_name),
        _fixup_pattern_protected($self, $find_heading),
        _fixup_pattern_protected($self, $find_value),
    );
}

sub _fixup_form_fields {
    my($self, $form_fields) = @_;
    return {map(
        (_fixup_pattern($_) => $form_fields->{$_}),
        keys(%$form_fields),
    )};
}

sub _fixup_pattern {
    my($v, $want_absolute) = @_;
    return $v
        if !$want_absolute
        && (ref($v) || $v =~ /^\(\?/s || $v !~ /^[a-z0-9_]+$|\.[\*\+]|^\^|\$$/);
    $v =~ s/(.)_/$1./g;
    if ($want_absolute) {
        $v =~ s/(?<!\$)$/\$/;
        $v =~ s/^(?!=\^)/^/;
    }
    return qr{$v}i;
}

sub _fixup_pattern_protected {
    my($self, $v) = @_;
    return $self->deprecated_text_patterns || !defined($v) ? $v
        : _fixup_pattern($v);
}

sub _format_form {
    my($self, $form, $submit, $form_fields) = @_;
    # Returns URL encoded form.  Undefined fields are not submitted.
    # Note the special case handling for checkboxes may need to be extended
    # for other controls.
    my($result) = [];
    my($match) = {};
#TODO: Add hidden form field testing
    while (my($k, $v) = each(%$form_fields)) {
        my($f) = _assert_form_field($form, $k);
        $match->{$f}++;
        # Radio or Select: Allow the use of the option label instead of value
        my($value) = $f->{options}
            ? _lookup_option_value(
                $f->{options}, _fixup_pattern_protected($self, $v))
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

sub _get_attr {
    my($attrs, $key) = @_;
    return ref($key) ? $attrs->get_by_regexp($key) : $attrs->get($key);
}

sub _get_script_line {
    my($self) = @_;
    # Returns the current line of the running script.
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

sub _grep_mail_dir {
    my($op) = @_;
    # Returns results of grep on mail_dir files.  Only includes valid
    # mail files.
    return grep(
        $_FN->get_tail($_) =~ /^\d+$/,
        glob("$_CFG->{mail_dir}/*"),
    );
}

sub _grep_msgs {
    my($self, $emails, $msg_re, $matched_emails) = @_;
    # Returns results of grep on mail_dir files.  Only includes valid
    # mail files.
    my($res) = [];
 _MSG:
    foreach my $file (_grep_mail_dir()) {
        next _MSG
            unless -M $file <= 0;
        my($msg) = $_F->read($file);
        $$msg = MIME::QuotedPrint::decode($$msg)
            if $$msg =~ qr{Content-Transfer-Encoding:\s+quoted-printable};
        my($hdr) = split(/^$/m, $$msg, 2);
        foreach my $k (@$_VERIFY_MAIL_HEADERS) {
            next
                unless $hdr =~ /^$k:\s*(.*)/mi;
            my($e) = b_use('Mail.Address')->parse_list($1);
            die("$hdr: malformed-header")
                unless $e && ($e = lc($e->[0]));
            my($m) = grep(ref($_) ? $hdr =~ $_ : lc($_) eq $e, @$emails);
            if ($m) {
                $matched_emails->{$m}++;
                if ($$msg =~ $msg_re) {
                    push(@$res, [$file, $self->internal_assert_no_prose($msg)]);
                    next _MSG;
                }
                _trace('body_re=', $msg_re, ' no-match msg=', $msg) if $_TRACE;
            }
            else {
                _trace('emails=', $emails, ' no-match msg=', $msg) if $_TRACE;
            }
            last;
        }
    }
    return $res;
}

sub _html_get {
    my($self, $what, $key) = @_;
    $key = _fixup_pattern_protected($self, $key);
    my($m) = ref($key) ? 'get_by_regexp' : 'get';
    return _assert_html($self)->get($what)->$m($key);
}

sub _html_parser {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $_HTMLP->new(
        $self->internal_assert_no_prose($fields->{response}->content_ref),
        {is_not_bivio_html => $self->unsafe_get('is_not_bivio_html') ? 1 : 0},
    );
}

sub _key_from_hash {
    my($hash, $key) = @_;
    if (ref($key)) {
        my(@match) = sort(grep($_ =~ $key, keys(%$hash)));
        return $match[0]
            if @match == 1;
        b_die($key, ': name matches too many ', \@match)
            if @match > 1;
    }
    else {
        return $key
            if exists($hash->{$key});
    }
    b_die($key, ': name not found in ', [sort(keys(%$hash))]);
    # DOES NOT RETURN
}

sub _log {
    my($self, $type, $msg, $case_tag) = @_;
    # Writes the HTTP message to a file with a nice suffix.  Preserves file
    # ordering, returns the file.
    my($fields) = $self->[$_IDI];
    return $self->test_log_output(
        sprintf('http-%05d.%s', $fields->{log_index}++, $type)
            . ($case_tag ? "-$case_tag" : ''),
        UNIVERSAL::can($msg, 'as_string') ? $msg->as_string : $msg);
}

sub _lookup_option_value {
    my($options, $value) = @_;
    # Lookup an option (select or radio) submit value
    # from the label or value. I<value> may be a regular expression.

    # Radio or Select: Allow the use of the option label
    # instead of value
    foreach my $o (_option_value_list($options)) {
        next unless ref($value) ? $o =~ $value : $o eq $value;
        _trace($o, ': mapped to ', $options->{$o}->{value}) if $_TRACE;
        return $options->{$o}->{value};
    }

    # otherwise verify that it is a valid submit value
    foreach my $o (_option_value_list($options)) {
        my($v) = $options->{$o}->{value};
        next unless ref($value) ? $v =~ $value : $v eq $value;
        _trace($v, ': mapped by value to label ', $o)
            if $_TRACE;
        return $v;
    }
    b_die('option value not found: ', $value);
}

sub _option_value_list {
    my($options) = @_;
    # For pattern matching, must use shortest value first
    return sort({length($a) <=> length($b) || $a cmp $b} keys(%$options));
}

sub _req {
    my($self) = @_;
    return b_use('Test.Request')->get_current_or_new;
}

sub _save_history {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    push(
        @{$fields->{history}},
        $_R->nested_copy({
            map(
                ($_ => $fields->{$_}),
                qw(uri response html_parser),
                $self->unsafe_get('save_cookies_in_history') ? 'cookies' : (),
            ),
        }),
    ) if $fields->{response};
    shift(@{$fields->{history}})
        while @{$fields->{history}} > $fields->{history_length};
    return;
}

sub _send_request {
    my($self, $request) = @_;
    # Sends the specified request.  Handles redirects, because we need to add in
    # cookies.
    my($fields) = $self->[$_IDI];
    $fields->{user_agent}->agent($self->user_agent);
    my($redirect_count) = 0;
    my($prev_uri) = $self->get_or_default('referer', $fields->{uri});
    $self->delete('referer');
    my($case_tag) = $self->unsafe_get_and_delete('case_tag');
    _save_history($self);
    while () {
        $request->header(Authorization => $self->get('Authorization'))
            if $self->has_keys('Authorization');
        $request->header(Referer => $self->absolute_uri($prev_uri))
            if $prev_uri;
        $fields->{uri} = $request->uri->canonical->as_string;
        $fields->{cookies}->add_cookie_header($request);
        _log($self, 'req', '# ' . _test_script_location($self) . "\n"
                 . $request->as_string, $case_tag);
        $fields->{response} = $fields->{user_agent}->request($request);
        _log($self, 'res', $fields->{response}, $case_tag);
        last
            unless $fields->{response}->is_redirect;
        b_die('too many redirects ', $request)
            if $redirect_count++ > 5;
        $fields->{cookies}->extract_cookies($fields->{response});
        my($uri) = $fields->{response}->as_string
            =~ /(?:^|\n)Location: (\S*)/si;
        $request = HTTP::Request->new(GET => $prev_uri = $self->absolute_uri($uri));
    }
    $fields->{cookies}->extract_cookies($fields->{response});
    $fields->{html_parser} = _html_parser($self)
        if $fields->{response}->content_type eq 'text/html';
    $fields->{redirect_count} = $redirect_count;
    b_die(
        $request->uri,
        ': uri request failed: ',
        $fields->{response}->code,
        ' ',
        $fields->{response}->message,
    ) unless $fields->{response}->is_success;
    return;
}

sub _test_script_location {
    my($self) = @_;
    return $self->get('test_script')
        . ':'
        . _get_script_line($self);
}

sub _unsafe_html_get {
    my($self, $what, $key) = @_;
    my($w) = _assert_html($self)->unsafe_get($what);
    return undef unless defined($w);
    $key = _fixup_pattern_protected($self, $key);
    my($m) = ref($key) ? 'unsafe_get_by_regexp' : 'unsafe_get';
    return $w->$m($key);
}

sub _validate_text_field {
    my($field, $value) = @_;
    # Dies if the text field has multiple lines.
    b_die('text input must be a single line: ', $field->{label})
        if $field->{type} eq 'text' && ($value || '') =~ /\n/;
    return;
}

sub _verify_form_field {
    my($self, $control, $case) = @_;
    # Find value of the form field.
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

sub _verify_form_option {
    my($control, $value) = @_;
    # Return the state of option.
    foreach my $o (_option_value_list($control->{options})) {
        return $o
            if $control->{options}->{$o}->{selected};
    }
    return undef;
}

sub _verify_zip {
    my($self, $compressed, $expected) = @_;
    _req($self);
    my($zip) = b_use('IO.Zip')->new;
    $zip->read_zip_from_string($compressed);
    my($values) = b_use('Collection.Attributes')->new({});
    $zip->iterate_members(sub {
        my($name, $value) = @_;
        $values->put($name => $value);
        return 1;
    });
    my($present) = {};
    $self->do_by_two(sub {
        my($name, $value) = @_;
        my($v);
        if (ref($name) eq 'Regexp') {
            $v = $values->get_by_regexp($name);
        }
        else {
            $v = $values->get($name);
        }
        return 1 unless defined($value);
        if (ref($value) eq 'ARRAY') {
            _verify_zip($self, $v, $value);
        }
        elsif (ref($value) eq 'Regexp') {
            b_die($value, ': did not match contents of member: ',
                $name, ' ', $v)
                unless $$v =~ $value;
        }
        elsif (ref($value) eq 'HASH') {
            b_die($value->{absent}, ': matches absent value: ', $name, ' ', $v)
                if $value->{absent} && $$v =~ $value->{absent};
            my($p) = $value->{present};
            if ($p) {
                $present->{$p} ||= 1;
                $present->{$p} = 2
                    if $$v =~ $p;
            }
        }
        else {
            b_die($value, ': is not equal to contents of member: ',
                $name, ' ', $v)
                unless $$v eq $value;
        }
        return 1;
    }, $expected);
    my($remaining) = [map($present->{$_} eq 1 ? $_ : (), keys(%$present))];
    b_die('unmatched present: ', $remaining)
        if @$remaining;
    return;
}

sub _wait_for_server {
    my($self, $timeout) = @_;
    # Wait for server to respond.  DOES NOT DIE.
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

1;
