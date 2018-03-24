# Copyright (c) 2001-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Util::HTTPLog;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Type::DateTime;
use Bivio::Type::Integer;
use IO::File ();

# C<Bivio::Util::HTTPLog> manipulates HTTP logs.

our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_CFG) = {
    error_file => (-r '/var/log/bivio-proxy/error_log'
	? '/var/log/bivio-proxy/error_log'
	: -r '/var/log/httpd/error_log'
	? '/var/log/httpd/error_log'
	: -r '/var/log/httpd/error.log'
	    ? '/var/log/httpd/error.log'
            : '/var/log/apache2/error_log'),
    email => 'root',
    pager_email => '',
    error_count_for_page => 3,
    ignore_list => Bivio::IO::Config->REQUIRED,
    error_list => Bivio::IO::Config->REQUIRED,
    critical_list => Bivio::IO::Config->REQUIRED,
    ignore_unless_count => Bivio::Type::Integer->get_max,
    ignore_unless_count_list => [],
    test_now => undef,
};
Bivio::IO::Config->register($_CFG);
my($_RECORD_PREFIX) = '^(?:\[('
    . _clean_regexp(Bivio::Type::DateTime->REGEX_CTIME)
    . ')\]|(?:\[\d+\])?('
    . _clean_regexp(Bivio::Type::DateTime->REGEX_ALERT)
    . '))';
my($_REGEXP);
my($_DT) = b_use('Type.DateTime');

sub USAGE {
    # : string
    # Returns:
    #
    #     usage: b-http-log [options] command [args...]
    #     commands:
    # 	parse_errors interval_minutes -- returns errors found in last interval
    return <<'EOF';
usage: b-http-log [options] command [args...]
commands:
    parse_errors interval_minutes -- returns errors found in last interval
EOF
}

sub error_file {
    return $_CFG->{error_file};
}

sub handle_config {
    # (proto, hash) : undef
    # Make sure regexps (error_list, etc.) are unique, e.g. have a '::' in them.
    # This avoids misidentification of messages which contain user data, but are
    # critical or errors.
    #
    #
    # critical_list : array_ref (required)
    #
    # List of regexps which will cause the to be sent to I<pager_email>.  The
    # matching value will be sent to the I<pager_email>, not the entire line
    #
    # email : string [root]
    #
    # Where to send mail to.  L<Bivio::ShellUtil|Bivio::ShellUtil> -email flag
    # overrides this value if it is defined.
    #
    # error_count_for_page : int [3]
    #
    # How many error_list messages in an interval are required before
    # the message is critical?
    #
    # error_file : string [/var/log/httpd/error.log || /var/log/httpd/error_log]
    #
    # File where errors are writted by httpd.
    #
    # error_list : array_ref (required)
    #
    # List of regexps which which will be emailed always.  Also see
    # I<error_count_for_page>.
    #
    # ignore_list : array_ref (required)
    #
    # List of regexps which will be thrown away.
    #
    # ignore_unless_count : int [9999]
    #
    # How many times should we ignore matches to I<ignore_unless_count_list>?
    #
    # ignore_unless_count_list : array_ref []
    #
    # List of regexps which will be thrown away unless they exceed
    # I<ignore_unless_count>.
    #
    # pager_email : string ['']
    #
    # Email addresses separated by commas which get pager messages.  See
    # I<critical_list> and I<error_count_for_page>.
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    $_REGEXP = {};
    foreach my $r (qw(ignore critical error ignore_unless_count)) {
	my($x) = $cfg->{"${r}_list"};
	$_REGEXP->{$r} = @$x ? qr/(@{[join('|', @$x)]})/ : undef;
    }
    return;
}

sub parse_errors {
    # (self, int) : string_ref
    # Check Apache error logs for unknown messages during the last interval.
    # You enter this in a crontab as:
    #
    #    0,15,30,45  * * * * /usr/local/bin/b-http-log parse_errors 15
    #
    # I<interval_minutes> must match the execute time in cron.
    my($self, $interval_minutes) = @_;
    return ($self->lock_action(sub {
	$self->get_request;
	#TODO: dies later unless this is here
	return _parse_errors_complete($self)
	    unless $interval_minutes = _parse_errors_init(
		$self, $interval_minutes);
	my($fields) = $self->[$_IDI];
	my($start) = Bivio::Type::DateTime->add_seconds(
	    $_CFG->{test_now} || Bivio::Type::DateTime->now,
	    -$interval_minutes * 60,
	);
	my($error_countdown) = $_CFG->{error_count_for_page};
	my($date, $record, $in_interval);
	my($last_error) = Bivio::Type::DateTime->get_min;
	my($ignored) = {};
	my(%error_times);
     RECORD: while (_parse_record($self, \$record, \$date)) {
	    unless ($in_interval) {
		next RECORD
			if Bivio::Type::DateTime->compare($start, $date) >= 0;
		$in_interval = 1;
	    }
	    _trace('record: ', $record) if $_TRACE;
	    if ($_REGEXP->{ignore} && $record =~ $_REGEXP->{ignore}) {
		_trace('ignoring: ', $1) if $_TRACE;
		next RECORD;
	    }
	    if ($_REGEXP->{ignore_unless_count}
		&& $record =~ $_REGEXP->{ignore_unless_count}) {
		$ignored->{$1}++;
		_trace('ignore_unless_count: ', $1) if $_TRACE;
		next RECORD;
	    }
	    # Critical already avoids dups, so put before time check after.
	    if ($_REGEXP->{critical} && $record =~ $_REGEXP->{critical}) {
		my($e) = $1;
		_trace('critical: ', $e) if $_TRACE;
		$e =~ s/^Bivio::DieCode:://g;
		$e =~ s/ class=>\S+//g;
		$e =~ s/\w+=>//g;
		_pager_report($self, $e);
		$record =~ s/^/***CRITICAL*** /;
	    }
	    if ($_REGEXP->{error} && $record =~ $_REGEXP->{error}) {
		_trace('error: ', $1) if $_TRACE;
		# Certain error messages don't pass the $_REGEXP->{error} on
		# the first output.  die message comes out first and it's what
		# we want in the email.  However, we need to count the error
		# regexp on the second message.  This code does this correctly.
		# We don't recount error REGEXPs output at the same time.
		_pager_report($self, $1)
		    if !$error_times{$date}++ && --$error_countdown == 0;
	    }
	    # Avoid duplicate error messages by checking $last_error
	    if (Bivio::Type::DateTime->compare($last_error, $date) == 0
		&& $record !~ /JOB_ERROR/) {
		_trace('same time: ', $record) if $_TRACE;
		next RECORD;
	    }
	    $last_error = $date;
	    # Never send more than 256 bytes (three lines) in a record via email
	    _report($self, substr($record, 0, 256));
	}
	foreach my $k (sort(keys(%$ignored))) {
	    _report($self, "[repeated $ignored->{$k} times] ", $k)
		if $ignored->{$k} >= $_CFG->{ignore_unless_count};
	}
	return _parse_errors_complete($self);
    }, __PACKAGE__ . 'parse_errors' . $_CFG->{error_file}))[0];
}

sub _clean_regexp {
    # (string) : string
    # Makes sure parethesizes regexes don't match anything
    my($value) = @_;
    $value =~ s/\(([^?])/\(?:$1/g;
    return $value;
}

sub _pager_report {
    # (self, arg, ....) : undef
    # Reports the error to the pager and puts at top of $fields->{res}.
    my($self, @args) = @_;
    my($fields) = $self->[$_IDI];
    my($msg) = Bivio::IO::Alert->format_args(@args);
    $fields->{res} = "CRITICAL ERRORS\n$fields->{res}"
	unless $fields->{res} =~ /^CRITICAL ERRORS/;
    my($last) = $fields->{pager_res}->[$#{$fields->{pager_res}}];
    push(@{$fields->{pager_res}}, $msg)
	if !$last || $last ne $msg;
    return;
}

sub _parse_errors_complete {
    # (self) : string_ref
    # Returns $fields->{res}.  Sends email to pager if pager_res and pager_email
    # are non-null.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{fh}->close
	if $fields->{fh} && !$fields->{fh}->eof;
    my($pr) = substr(join('', @{$fields->{pager_res}}), 0, 100);
    $self->send_mail(
	$_CFG->{pager_email},
	_subject(),
	\$pr,
    ) if $pr && $_CFG->{pager_email};
    return \$fields->{res};
}

sub _parse_errors_init {
    # (self, int) : array
    # Returns its arguments, but first checks validity.  Sets up email
    # and result_name.  Failure is returned as interval_minutes being 0.
    my($self, $interval_minutes) = @_;
    # Initializes the request (timezone)
    $self->usage('interval_minutes must be supplied')
	if $interval_minutes <= 0;
    $self->put(email => $_CFG->{email})
	unless defined($self->unsafe_get('email'));
    $self->put(result_subject => _subject($_CFG->{error_file}));
    my($fields) = $self->[$_IDI] = {
	res => '',
	pager_res => [],
	fh => IO::File->new,
    };
    my($err);

    if ($self->req->is_production && ! -s $_CFG->{error_file}) {
	if (abs($_DT->diff_seconds(
	    $_DT->now,
	    $_DT->set_local_beginning_of_day($_DT->now),
	)) < 300) {
	    # log file may be rotating
	    return 0;
	}
	$err = "$_CFG->{error_file}: error file missing or empty";
    }
    elsif (! $fields->{fh}->open($_CFG->{error_file})) {
	$err = "$_CFG->{error_file}: $!";
    }
    return $interval_minutes unless $err;
    _pager_report($self, $err);
    _report($self, $err);
    return 0;
}

sub _parse_line {
    # (hash_ref) : boolean
    # Returns 0 at eof.  Fills in $fields->{line}.
    my($fields) = @_;
    return 1 if defined($fields->{line});
    $fields->{line} = $fields->{fh}->getline;
    return defined($fields->{line}) ? 1 : 0;
}

sub _parse_record {
    # (self, string_ref, string_ref) : boolean
    # Parses a record (the entire text) from the file.  There's a lookahead
    # buffer.
    my($self, $record, $date) = @_;
    my($fields) = $self->[$_IDI];
    $$record = undef;
    while (_parse_line($fields)) {
	last if $$record && $fields->{line} =~ /$_RECORD_PREFIX/o;
	$$record .= $fields->{line};
	$fields->{line} = undef;
    }
    return 0 unless defined($$record);
    my($err);
    my($d1, $d2) = $$record =~ /$_RECORD_PREFIX/o;
    my($m) = $_CFG->{test_now} ? 'from_literal' : 'from_local_literal';
    ($$date, $err) = Bivio::Type::DateTime->$m($d1 || $d2);
    unless ($$date) {
	_report($self, "can't parse date: ", $err, ": ", $$record);
	$$record = '';
	return 1;
    }
    return 1;
}

sub _report {
    # (self, arg, ...) : undef
    # Adds errors (safely) to $fields->{res}
    my($self, @args) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{res} .= Bivio::IO::Alert->format_args(@args);
    return;
}

sub _subject {
    my($subject) = @_;
    return (b_use('Bivio.BConf')->bconf_host_name =~ /^([^\.]+)/)[0]
	. ($subject ? (' ' . $subject) : '')
;
}

1;
