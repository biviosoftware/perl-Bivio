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
use Bivio::IO::Config;
use IO::File ();
use Sys::Hostname ();

#=VARIABLES
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
        .')\]|(?:\[\d+\] )?('
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
 RECORD: while (_parse_record($self, \$record, \$date)) {
	unless ($in_interval) {
	    next RECORD
		    if Bivio::Type::DateTime->compare($start, $date) >= 0;
	    $in_interval = 1;
	}
	next RECORD if $record =~ /$_IGNORE_REGEX/o;
	if ($record =~ /$_CRITICAL_REGEX/o) {
	    _pager_report($self, 'CRITICAL ERROR')
		    unless $fields->{pager_res};
	    $record =~ s/^/***CRITICAL*** /;
	}
	elsif ($record =~ /$_ERROR_REGEX/) {
	    _pager_report($self, 'ERROR COUNT EXCEEDED')
		    if $error_countdown-- == 0;
	}
	if ($record =~ /(.*Use of uninitialized value)/) {
	    _report($self, $1);
	    next RECORD;
	}
	_report($self, $record);
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
    # Initialize regexs which 
    $_IGNORE_REGEX = join('|',
	    # Skip non-warnings
	    'Server configured -- resuming normal operations',
	    'Restart successful',
	    'httpd: caught SIGTERM, shutting down',
	    'SIGHUP received.  Attempting to restart',
	    '\[(?:info|notice)\]',
	    'child process \d+ still did not exit',
	    'created shared memory segment',
	    'read request (?:line|headers) timed out for',
	    '/(?:read|send) timed out for/',
	    # SSL
	    'mod_ssl: SSL handshake interrupted',
	    'System: Connection reset by peer',
	    # Skip regular Bivio messages
	    'Agent::Job::Dispatcher:.*JOB_(?:START|END)',
	    'SQL::Connection::_get_connection.*reconnecting',
	    'OpenSSL: error',
	    'SSL handshake (?:failed|timed out)',
	    'SSL error on reading data',
	    '_vti_inf.html',
	    '_vti_rpc',
	    'invalid persistent cookie',
	    'Bivio::DieCode::MISSING_COOKIES',
	    'visitor invalid, deleting from cookie',
	    'Unable to parse address',
	    'and logging as new user',
	    'UI::HTML::Common::SearchList::execute:\d+ phrase',
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
	    'Base64::http_decode.*Premature (?:end|padding) of base64',
	    'ListFormModel Bivio::DieCode::UPDATE_COLLISION',
	    'Bivio::DieCode::TOO_MANY:.*::Biz::Model::FileTreeList',
	    "can't login as shadow user",
	   );
    $_ERROR_REGEX = join('|',
	    'Bivio::Die::DIE',
	    'Bivio::Die::CONFIG_ERROR',
	    );
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
    my($msg) = Bivio::IO::Alert->format_args(@args)."\n";
    $fields->{res} = $msg.$fields->{res};
    $fields->{pager_res} .= $msg;
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
    $self->email($_CFG->{pager_email}, 'critical http errors',
	    \$fields->{pager_res})
	    if $fields->{pager_res} && $fields->{page_email};
    return \$fields->{res};
}

# _parse_errors_init(self, int interval_minutes) : array
#
# Returns its arguments, but first checks validity.  Sets up email
# and result_name.  Failure is returned as interval_minutes being 0.
#
sub _parse_errors_init {
    my($self, $interval_minutes) = @_;
    $self->usage('interval_minutes must be supplied')
	    if $interval_minutes <= 0;
    $self->put(email => $_CFG->{email})
	    unless defined($self->unsafe_get('email'));
    $self->put(result_name =>
	    'Server Errors on '.Sys::Hostname::hostname().' at '
	    .Bivio::Type::DateTime->to_local_string(
		    Bivio::Type::DateTime->now));
    my($fields) = $self->{$_PACKAGE} = {
	res => '',
	pager_res => '',
	fh => IO::File->new,
    };
    unless ($fields->{fh}->open($_CFG->{error_file})) {
	_pager_report($self, $_CFG->{error_file}, ': ', "$!");
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
    $self->{$_PACKAGE}->{res} .= Bivio::IO::Alert->format_args(@args)."\n";
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
