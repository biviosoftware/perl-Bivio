# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Util::HTTPLog;
use strict;
$Bivio::Util::HTTPLog::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::HTTPLog::VERSION;

=head1 NAME

Bivio::Util::HTTPLog - manipulates HTTP logs

=head1 SYNOPSIS

    use Bivio::Util::HTTPLog;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::HTTPLog::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::HTTPLog> manipulates HTTP logs.

=cut

=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:

    usage: b-http-log [options] command [args...]
    commands:
	parse_errors interval_minutes -- returns errors found in last interval

=cut

sub USAGE {
    return <<'EOF';
usage: b-http-log [options] command [args...]
commands:
    parse_errors interval_minutes -- returns errors found in last interval
EOF
}

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::IO::Config;
use IO::File ();
use Sys::Hostname ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_CFG) = {
    error_file => '/var/log/httpd/error.log',
    email => 'root',
    pager_email => '',
    error_count_for_page => 3,
};
Bivio::IO::Config->register($_CFG);
my($_RECORD_PREFIX) = '^(?:\[('
	._clean_regex(Bivio::Type::DateTime->REGEX_CTIME)
        .')\]|(?:\[\d+\])?('
	._clean_regex(Bivio::Type::DateTime->REGEX_ALERT)
	.'))';
my($_IGNORE_REGEX);
my($_ERROR_REGEX);
my($_CRITICAL_REGEX);
_initialize();

=head1 METHODS

=cut

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item email : string [root]

Where to send mail to.  ShellUtil -email flag overrides this value
if it is defined.

=item error_count_for_page : int [3]

How many $_ERROR_REGEX messages in an interval are required before
a pager message is sent?

=item error_file : string [/var/log/httpd/error.log]

File where errors are writted by httpd.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

=for html <a name="parse_errors"></a>

=head2 parse_errors(int interval_minutes) : string_ref

Check Apache error logs for unknown messages during the last interval.
You enter this in a crontab as:

   0,15,30,45  * * * * /usr/local/bin/b-http-log parse_errors 15

I<interval_minutes> must match the execute time in cron.

=cut

sub parse_errors {
    my($self, $interval_minutes) = _parse_errors_init(@_);
    return _parse_errors_complete($self) unless $interval_minutes;
    my($fields) = $self->{$_PACKAGE};
    my($start) = Bivio::Type::DateTime->add_seconds(
	    Bivio::Type::DateTime->now, -$interval_minutes * 60);
    my($error_countdown) = $_CFG->{error_count_for_page};
    my($date, $record, $in_interval);
    my($last_error) = Bivio::Type::DateTime->get_min;
    my(%error_times);
 RECORD: while (_parse_record($self, \$record, \$date)) {
	unless ($in_interval) {
	    next RECORD
		    if Bivio::Type::DateTime->compare($start, $date) >= 0;
	    $in_interval = 1;
	}
	if ($record =~ /($_IGNORE_REGEX)/o) {
	    _trace('ignoring: ', $1) if $_TRACE;
	    next RECORD;
	}
	# Critical already avoids dups, so put before time check after.
	if ($record =~ /($_CRITICAL_REGEX)/o) {
	    _pager_report($self, $1);
	    $record =~ s/^/***CRITICAL*** /;
	}
	if ($record =~ /($_ERROR_REGEX)/o) {
	    # Certain error messages don't pass the $_ERROR_REGEX on the first
	    # output.  die message comes out first and it's what we want in the
	    # email.  However, we need to count the error regex on the second
	    # message.  This code does this correctly.  We don't recount
	    # ERROR_REGEXs output at the same time.
	    _pager_report($self, $1)
		    if !$error_times{$date}++ && --$error_countdown == 0;
	}
	# Avoid duplicate error messages by checking $last_error
	if (Bivio::Type::DateTime->compare($last_error, $date) == 0) {
	    _trace('same time: ', $record) if $_TRACE;
	    next RECORD;
	}
	$last_error = $date;
	# Never send more than 256 bytes (three lines) in a record via email
	_report($self, substr($record, 0, 256));
    }
    return _parse_errors_complete($self);
}

#=PRIVATE METHODS

# _clean_regex(string regex) : string
#
# Makes sure parethesizes regexes don't match anything
#
sub _clean_regex {
    my($value) = @_;
    $value =~ s/\(([^?])/\(?:$1/g;
    return $value;
}

# _initialize() : array
#
# Initialize the regex arrays
#
sub _initialize {
    # Initialize regexs.  Make sure regexs are unique, e.g. have a
    # '::' in them.  This avoids ignoring messages which contain
    # user data, but are critical or errors.
    $_IGNORE_REGEX = join('|',
	    # Skip non-warnings
	    'Server configured -- resuming normal operations',
	    'Restart successful',
	    'httpd: caught SIGTERM, shutting down',
	    'SIGHUP received.  Attempting to restart',
	    '\[(?:info|notice|debug)\]',
	    'child process \d+ still did not exit',
	    'created shared memory segment',
	    'read request (?:line|headers) timed out for',
	    '(?:read|send) timed out for',
	    # Front-end and SSL
	    'mod_ssl: SSL handshake interrupted',
	    'mod_ssl: SSL handshake timed out',
	    'System: Connection reset by peer',
	    'System: Broken pipe',
	    '\[error\].*File does not exist:',
	    # Skip regular Bivio messages
	    'Agent::Job::Dispatcher:.*JOB_(?:START|END)',
	    'SQL::Connection::_get_connection.*reconnecting',
	    'OpenSSL: error',
	    'SSL handshake (?:failed|timed out)',
	    'SSL error on reading data',
	    '_vti_inf.html',
	    '_vti_rpc',
	    'HTTP::Cookie::.*invalid (?:volatile|persistent) cookie:',
	    'Bivio::DieCode::MISSING_COOKIES',
	    'visitor invalid, deleting from cookie',
	    'Unable to parse address',
	    'and logging as new user',
	    'UI::HTML::Common::SearchList::execute:\d+ phrase',
	    '\[error\].*client sent HTTP/1.1 request without hostname',
	    # Operational: form_errors, not found and forbidden
	    'form_errors=\{',
	    'Bivio::DieCode::NOT_FOUND',
	    'Bivio::DieCode::FORBIDDEN',
	    'Bivio::DieCode::CORRUPT_QUERY',
	    'Bivio::Biz::FormContext::_parse_error',
	    'HTTP::Query::_correct.*correcting query',
	    'Bivio::Biz::Model::F1065Form::_calculate_income',
	    'Error in hidden value\(s\), refreshing',
	    'request aborted, rolling back',
	    'attempt to delete missing entry',
	    'Premature (?:end|padding) of base64',
	    'ListFormModel Bivio::DieCode::UPDATE_COLLISION',
	    'Bivio::DieCode::TOO_MANY:.*::Biz::Model::FileTreeList',
	    "can't login as shadow user",
	    'Bivio::Data::EW::ClubImporter::_parse_tax_id.*changed to',
	    "MemberAllocationList.*report_date isn't on year-end",
	    'EW::ClubImporter::.*incorrect imported allocations',
	    "Request::warn.*couldn't adjust, difference too great,",
	    "::_create_stock_transfer_entry.*Couldn't find related stock",
	    'HTTP::Form::parse.*unknown form Content-Type: <undef>',
	    "::warn:.*income statement doesn't match schedule d",
	    '::warn:\d+ large audit, \d+ entries',
	    'Accounting::Util::.* Creat(?:ed|ing) /home/account_sync',
	    '::UPDATE_COLLISION: list_attrs=>',
	   );
    # Value is sent to the pager if error_count is exceeded
    $_ERROR_REGEX = join('|',
	    'Bivio::DieCode::DIE',
	    'Bivio::DieCode::CONFIG_ERROR',
	    'Connection refused: proxy connect to .* port .* failed',
	   );
    # Value is sent to pager
    $_CRITICAL_REGEX = join('|',
	    'Bivio::DieCode::DB_ERROR',
	   );
    return;
}

# _pager_report(self, arg, ....)
#
# Reports the error to the pager and puts at top of $fields->{res}.
#
sub _pager_report {
    my($self, @args) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($msg) = Bivio::IO::Alert->format_args(@args);
    $fields->{res} = "CRITICAL ERRORS\n".$fields->{res}
	    unless $fields->{res} =~ /^CRITICAL ERRORS/;
    my($last) = $fields->{pager_res}->[$#{$fields->{pager_res}}];
    push(@{$fields->{pager_res}}, $msg) if !$last || $last ne $msg;
    return;
}

# _parse_errors_complete(self) : string_ref
#
# Returns $fields->{res}.  Sends email to pager if pager_res and pager_email
# are non-null.
#
sub _parse_errors_complete {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{fh}->close;
    my($pr) = join('', @{$fields->{pager_res}});
    $self->email_message($_CFG->{pager_email}, 'critical http errors', \$pr)
	    if $pr && $_CFG->{pager_email};
    return \$fields->{res};
}

# _parse_errors_init(self, int interval_minutes) : array
#
# Returns its arguments, but first checks validity.  Sets up email
# and result_name.  Failure is returned as interval_minutes being 0.
#
sub _parse_errors_init {
    my($self, $interval_minutes) = @_;
    # Initializes the request (timezone)
    $self->usage('interval_minutes must be supplied')
	    if $interval_minutes <= 0;
    $self->put(email => $_CFG->{email})
	    unless defined($self->unsafe_get('email'));
    $self->put(result_subject =>
	    'Errors on '.Sys::Hostname::hostname().' at '
	    .Bivio::Type::DateTime->to_local_string(
		    Bivio::Type::DateTime->now));
    my($fields) = $self->{$_PACKAGE} = {
	res => '',
	pager_res => [],
	fh => IO::File->new,
    };
    unless ($fields->{fh}->open($_CFG->{error_file})) {
	my($err) = $_CFG->{error_file}.": $!";
	_pager_report($self, $err);
	_report($self, $err);
	return ($self, 0);
    }
    return ($self, $interval_minutes);
}

# _parse_line(hash_ref fields) : boolean
#
# Returns 0 at eof.  Fills in $fields->{line}.
#
sub _parse_line {
    my($fields) = @_;
    return 1 if defined($fields->{line});
    $fields->{line} = $fields->{fh}->getline;
    return defined($fields->{line}) ? 1 : 0;
}

# _parse_record(self, string_ref record, string_ref date) : boolean
#
# Parses a record (the entire text) from the file.  There's a lookahead
# buffer.
#
sub _parse_record {
    my($self, $record, $date) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$record = undef;
    while (_parse_line($fields)) {
	last if $$record && $fields->{line} =~ /$_RECORD_PREFIX/o;
	$$record .= $fields->{line};
	$fields->{line} = undef;
    }
    return 0 unless defined($$record);
    my($err);
    my($d1, $d2) = $$record =~ /$_RECORD_PREFIX/o;
    ($$date, $err) = Bivio::Type::DateTime->from_local_literal($d1 || $d2);
    unless ($$date) {
	_report($self, "can't parse date: ", $err, ": ", $$record);
	$$record = '';
	return 1;
    }
    return 1;
}

# _report(self, arg, ...)
#
# Adds errors (safely) to $fields->{res}
#
sub _report {
    my($self, @args) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{res} .= Bivio::IO::Alert->format_args(@args);
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
