# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Util::HTTPLog;
use strict;
$Bivio::Util::HTTPLog::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::HTTPLog::VERSION;

=head1 NAME

Bivio::Util::HTTPLog - manipulates HTTP logs

=head1 RELEASE SCOPE

bOP

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
my($_IDI) = __PACKAGE__->instance_data_index;
my($_CFG) = {
    error_file => (-r '/var/log/httpd/error_log'
       ? '/var/log/httpd/error_log' : '/var/log/httpd/error.log'),
    email => 'root',
    pager_email => '',
    error_count_for_page => 3,
    ignore_list => Bivio::IO::Config->REQUIRED,
    error_list => Bivio::IO::Config->REQUIRED,
    critical_list => Bivio::IO::Config->REQUIRED,
};
Bivio::IO::Config->register($_CFG);
my($_RECORD_PREFIX) = '^(?:\[('
    . _clean_regexp(Bivio::Type::DateTime->REGEX_CTIME)
    . ')\]|(?:\[\d+\])?('
    . _clean_regexp(Bivio::Type::DateTime->REGEX_ALERT)
    . '))';
my($_REGEXP);

=head1 METHODS

=cut

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

Make sure regexps (error_list, etc.) are unique, e.g. have a '::' in them.
This avoids misidentification of messages which contain user data, but are
critical or errors.

=over 4

=item critical_list : array_ref (required)

List of regexps which will cause the to be sent to I<pager_email>.  The
matching value will be sent to the I<pager_email>, not the entire line

=item email : string [root]

Where to send mail to.  L<Bivio::ShellUtil|Bivio::ShellUtil> -email flag
overrides this value if it is defined.

=item error_count_for_page : int [3]

How many error_list messages in an interval are required before
the message is critical?

=item error_file : string [/var/log/httpd/error.log || /var/log/httpd/error_log]

File where errors are writted by httpd.

=item error_list : array_ref (required)

List of regexps which which will be emailed always.  Also see
I<error_count_for_page>.

=item ignore_list : array_ref (required)

List of regexps which will be thrown away.

=item pager_email : string ['']

Email addresses separated by commas which get pager messages.  See
I<critical_list> and I<error_count_for_page>.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    $_REGEXP = {};
    foreach my $r (qw(ignore critical error)) {
	$_REGEXP->{$r} = qr/(@{[join('|', @{$cfg->{"${r}_list"}})]})/;
    }
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
    return _parse_errors_complete($self)
	unless $interval_minutes;
    my($fields) = $self->[$_IDI];
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
	if ($record =~ $_REGEXP->{ignore}) {
	    _trace('ignoring: ', $1) if $_TRACE;
	    next RECORD;
	}
	# Critical already avoids dups, so put before time check after.
	if ($record =~ $_REGEXP->{critical}) {
	    _pager_report($self, $1);
	    $record =~ s/^/***CRITICAL*** /;
	}
	if ($record =~ $_REGEXP->{error}) {
	    # Certain error messages don't pass the $_REGEXP->{error} on the
	    # first output.  die message comes out first and it's what we want
	    # in the email.  However, we need to count the error regexp on the
	    # second message.  This code does this correctly.  We don't recount
	    # error REGEXPs output at the same time.
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

# _clean_regexp(string regexp) : string
#
# Makes sure parethesizes regexes don't match anything
#
sub _clean_regexp {
    my($value) = @_;
    $value =~ s/\(([^?])/\(?:$1/g;
    return $value;
}

# _pager_report(self, arg, ....)
#
# Reports the error to the pager and puts at top of $fields->{res}.
#
sub _pager_report {
    my($self, @args) = @_;
    my($fields) = $self->[$_IDI];
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
    my($fields) = $self->[$_IDI];
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
    my($fields) = $self->[$_IDI] = {
	res => '',
	pager_res => [],
	fh => IO::File->new,
    };
    unless ($fields->{fh}->open($_CFG->{error_file})) {
	my($err) = "$_CFG->{error_file}: $!";
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
    my($fields) = $self->[$_IDI];
    $fields->{res} .= Bivio::IO::Alert->format_args(@args);
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
