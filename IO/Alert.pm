# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::IO::Alert;
use strict;
$Bivio::IO::Alert::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::IO::Alert - error messages for servers and programs

=head1 SYNOPSIS

    use Bivio::IO::Alert;

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::Alert::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::IO::Alert> outputs error messages for programs and servers.  It also
intercepts C<$SIG{__DIE__}> and C<$SIG{__WARN__}> if configured to
do so.

Policies: C<intercept_warn> should probably be set.  This prevents warnings
from going into the bit bucket.  C<intercept_die> should probably not be set.
Instead L<eval_or_warn|"eval_or_warn"> should be used.  This allows for
exceptions to be ignored when they are part of the normal part of operations.
It is probably best to use C<CORE::warn> and C<CORE::die> instead of the
redefinitions here.

C<max_warnings> in any given program invocation is limited to
a (default) 1000. You can L<reset_warn_counter|"reset_warn_counter">,
which is typically used by servers.

=cut

#=VARIABLES
my($_PERL_MSG_AT_LINE, $_PACKAGE, $_LOGGER,
	$_DEFAULT_MAX_ARG_LENGTH, $_MAX_ARG_LENGTH, $_WANT_PID, $_WANT_TIME,
        $_STACK_TRACE_DIE, $_STACK_TRACE_WARN, $_MAX_WARNINGS, $_WARN_COUNTER);
BEGIN {
    # What perl outputs on "die" or "warn" without a newline
    $_PERL_MSG_AT_LINE = ' at (\S+|\(eval \d+\)) line (\d+)\.' . "\n\$";
    $_PACKAGE = __PACKAGE__;
    $_LOGGER = \&_log_stderr;
    $_DEFAULT_MAX_ARG_LENGTH = 2048;
    $_MAX_ARG_LENGTH = $_DEFAULT_MAX_ARG_LENGTH;
    $_WANT_PID = 0;
    $_WANT_TIME = 0;
    $_STACK_TRACE_DIE = 0;
    $_STACK_TRACE_WARN = 0;
    $_MAX_WARNINGS = 1000;
    $_WARN_COUNTER = $_MAX_WARNINGS;
}

#=IMPORTS
use Bivio::IO::Config;
use Carp ();
# TODO: Commented out because it's causing an ugly warning message
#       Might be ok in a future version of Perl libraries
#use Sys::Syslog ();

#=VARIABLES
# Normalize error messages
# $SIG{__DIE__} = \&_initial_die_handler;
# $SIG{__WARN__} = \&_warn_handler;
my($_LAST_WARNING);
Bivio::IO::Config->register({
    intercept_die => 0,
    stack_trace_die => 0,
    intercept_warn => 1,
    stack_trace_warn => 0,
    log_facility => 'daemon',
    log_name => $0,
    max_arg_length => $_DEFAULT_MAX_ARG_LENGTH,
    want_stderr => 0,
    syslog_socket => 'unix',
    want_pid => 0,
    want_time => 0,
    max_warnings => $_MAX_WARNINGS,
});

=head1 METHODS

=cut

=for html <a name="die"></a>

=head2 static die(string arg1, ...)

Sends a warning message to the alert log and then calls C<CORE::die>
with "\n".

=cut

sub die {
    &warn(@_);
    CORE::die("\n");
}

=for html <a name="eval_or_warn"></a>

=head2 eval_or_warn(code sub) : result

Calls I<sub> and if it throws an exception, prints a warning.
Returns the result of the subroutine or undef.

=cut

sub eval_or_warn {
    my(undef, $sub) = @_;
    my($result);
    eval {
	$result = &$sub;
	1;
    } && return $result;
    # If the warning was already output, the following operation has
    # no effect.
    my($msg) = $@;
    $msg =~ s/$_PERL_MSG_AT_LINE//os && ($msg = "$1:$2 $msg");
    Bivio::IO::Alert->warn($msg);
    return undef;
}

=for html <a name="format"></a>

=head2 static format(string package, string file, int line, string sub, array msg) : string

Formats I<pkg>, I<file>, I<line>, I<sub>, and I<msg> into a pretty printed
string.  Care is taken to truncate long arguments to
L<get_max_arg_length|"get_max_arg_length">.  If an element of I<msg> is an
object which supports
<Bivio::UNIVERSAL::as_string|Bivio::UNIVERSAL/"as_string">, C<as_string> will
be called to convert the object to a string.

=cut

sub format {
    return &_format(@_);
}

=for html <a name="get_last_warning"></a>

=head2 static get_last_warning() : string

Returns the last warning output.

=cut

sub get_last_warning {
    return $_LAST_WARNING;
}

=for html <a name="get_max_arg_length"></a>

=head2 get_max_arg_length() : int

Maximum length of an argument to any of the printing methods.

=cut

sub get_max_arg_length {
    return $_MAX_ARG_LENGTH;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(string class, hash cfg)

=over 4

=item intercept_die : boolean [false]

If true, installs a C<$SIG{__DIE__}> handler which writes alerts on all
calls to die.

=item intercept_warn : boolean [true]

If true, installs a C<$SIG{__WARN__}> handler which writes alerts on all
warnings.

=item log_facility : string [daemon]

If writing to C<Sys::Syslog>, the facility to use.

=item log_name : string [$0]

If writing to C<Sys::Syslog>, the name of the server.

=item max_arg_length : int [2048]

Maximum length of warning message components, i.e. arguments to
L<die|"die"> and L<warn|"warn">.

=item max_warnings : int [1000]

Maximum number of warnings between L<reset_warn_counter|"reset_warn_counter">
calls.  By default, L<reset_warn_counter|"reset_warn_counter"> is not
called, so this is the maximum per program invocation.

=item stack_trace_die : boolean [false]

If true, implies B<intercept_die> is true and will print a stack trace
on L<die|"die">.

=item stack_trace_warn : boolean [false]

If true, implies B<intercept_warn> is true and will print a stack trace
on L<warn|"warn">.

=item want_stderr : boolean [false]

If true, always writes to C<STDERR>.  Otherwise, determines where to write as
follows:

=over 4

=item *

If running under mod_perl, writes to apache error log

=item *

If C<STDERR> is a tty, writes to stderr.

=item *

Otherwise, writes to Sys::Syslog

=back

=item syslog_socket : 'unix' or 'inet' [unix]

If writing to C<Sys::Syslog>, the type of socket to open.

=item want_pid : boolean [false]

If not writing to C<Sys::Syslog>, include the pid in the log messages.

=item want_time : boolean [false]

If not writing to C<Sys::Syslog>, include the time in the log messages.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_MAX_ARG_LENGTH = $cfg->{max_arg_length};

    # Must reset warn counter.  We don't call this except at config
    # time, so probably ok.  The low level code shouldn't loop. :-(
    $_WARN_COUNTER = $_MAX_WARNINGS = $cfg->{max_warnings};

    $_STACK_TRACE_DIE = $cfg->{stack_trace_die};
    $_STACK_TRACE_WARN = $cfg->{stack_trace_warn};
#TODO: This isn't correct.  Want to set back to "old" configuration
    $SIG{__DIE__} = $cfg->{intercept_die} || $cfg->{stack_trace_die}
	    ? \&_die_handler : $SIG{__DIE__};
    $SIG{__WARN__} = $cfg->{intercept_warn} || $cfg->{stack_trace_warn}
	    ? \&_warn_handler : $SIG{__WARN__};
    if ($cfg->{want_stderr}) {
	$_LOGGER = \&_log_stderr;
    }
    elsif (exists $ENV{MOD_PERL}) {
	$_LOGGER = \&_log_apache;
    }
    elsif (-t STDERR) {
	# Apache overrides default stderr, so gets reason
	$_LOGGER = \&_log_stderr;
    }
    else {
	&Sys::Syslog::setlogsock($cfg->{syslog_socket});
	&Sys::Syslog::openlog($cfg->{log_name}, 'pid', $cfg->{log_facility});
	$_LOGGER = \&_log_syslog;
    }
    $_WANT_PID = $cfg->{want_pid};
    $_WANT_TIME = $cfg->{want_time};
    return;
}

=for html <a name="print"></a>

=head2 static print(string severity, string msg)

Writes an already formatted alert at a particular severity level.  The severity
levels supported are C<debug> and C<err>.

=cut

sub print {
    my(undef, $severity, $msg) = @_;
    &$_LOGGER($severity, $msg);
}

=for html <a name="reset_warn_counter"></a>

=head2 reset_warn_counter()

Resets the internal warn counter to max_warnings.

=cut

sub reset_warn_counter {
    $_WARN_COUNTER = $_MAX_WARNINGS;
    return;
}

=for html <a name="warn"></a>

=head2 static warn(string arg1, ...)

Sends warning message to the alert log.

Note: If the message consists of a single newline, nothing is output.

=cut

sub warn {
    my($proto) = shift(@_);
    int(@_) == 1 && $_[0] eq "\n" && return;
    $_LAST_WARNING = _call_format(\@_);
    &$_LOGGER('err', $_LAST_WARNING);
    return unless --$_WARN_COUNTER < 0;

    # This code is careful to avoid infinite loops.  Don't change it
    # unless you understand all the relationships.
    $_LAST_WARNING = 'Bivio::IO::Alert TOO MANY WARNINGS (max='
	    .$_MAX_WARNINGS.")\n";
    &$_LOGGER('err', $_LAST_WARNING);
    CORE::die("\n");
}

#=PRIVATE METHODS

sub _call_format {
    my($msg) = @_;
    my($i) = 0;
    $i++ while caller($i) eq __PACKAGE__;
    return &_format(undef,
	    ((caller($i))[0,1,2], (caller($i+1))[$[+3] || undef),
	    $msg);
}

sub _die_handler {
    &_warn_handler(@_);
    $_STACK_TRACE_DIE && &_trace_stack();
    CORE::die("\n");
}

sub _format {
    my(undef, $pkg, $file, $line, $sub, $msg) = @_;
    # depends heavily on perl's "die" syntax
    my($text) = $_WANT_PID ? "[$$]" : '';
    $text .= $_WANT_TIME ? _timestamp() : '';
    my($is_eval) = $file && $file =~ s/^\(eval (\d+)\)$/eval$1/s;
    if (defined($pkg) && $pkg eq 'main') {
	# main doesn't give us much info, so use the file instead
	$pkg = defined($file) ? $file : 'main';
    }
    if ($is_eval) {
	# prefix the pkg if available
	defined($pkg) && ($text .= $pkg . '::');
	$text .= $file;
    }
    # (eval) is set as the sub if the eval is in the initialization code
    # and is a block ({}) eval and not an expr ('') eval.
    elsif (defined($sub) && $sub ne '(eval)') {
	$text .= $sub;
    }
    # Ususally called in an initialization body
    else {
	$text .= defined($pkg) ? $pkg : defined($file) ? $file : '';
    }
    defined($line) && ($text .= ":$line");
    $text .= ' ';
    my($o);
    foreach $o (@$msg) {
	# Only go three levels deep on structures
	$text .= _format_string($o, 3);
    }
    substr($text, -1) eq "\n" || ($text .= "\n");
    return $text;
}

# _format_string(any o, int depth) : string
#
# Returns $o formatted as a string.  If $depth <= 0, don't go uwrap
# structures.
#
sub _format_string {
    my($o, $depth) = @_;

    # Avoid deep nesting
    if (--$depth > 0) {
	# Don't let as_string calls crash;  Only call as_string on refs.
	if (ref($o) eq 'ARRAY') {
	    my($s, $v) = '[';
	    my($i) = 20;
	    foreach $v (@$o) {
		$s .= _format_string($v, $depth) .',';
		if (--$i <= 0) {
		    $s .= '<...>,';
		    last;
		}
	    }
	    return chop($s) eq '[' ? '[]' : $s.']';
	}

	if (ref($o) eq 'HASH') {
	    my($s, $v) = '{';
	    my($i) = 20;
	    foreach $v (sort(keys(%$o))) {
		$s .= _format_string($v, $depth)
			.'=>'._format_string($o->{$v}, $depth).',';
		if (--$i <= 0) {
		    $s .= '<...>,';
		    last;
		}
	    }
	    return chop($s) eq '{' ? '{}' : $s.'}';
	}
	if (ref($o) eq 'SCALAR') {
	    return '\\${'._format_string($$o, $depth).'}';
	}
    }
    return _format_string_simple($o);
}

sub _format_string_simple {
    my($o) = @_;
    return '<undef>' unless defined($o);
    my($s) = ref($o) && &UNIVERSAL::can($o, 'as_string')
	    ? (eval {$o->as_string} || $o) : $o;
    return length($s) > $_MAX_ARG_LENGTH
		? (substr($s, 0, $_MAX_ARG_LENGTH) . '<...>')
			: $s;
}

sub _initial_die_handler {
    my($msg) = @_;
    $msg =~ s/$_PERL_MSG_AT_LINE//os && ($msg = "$1:$2 $msg");
    CORE::die(&_call_format([$msg]));
}

sub _initial_warn_handler {
    my($msg) = @_;
    $msg =~ s/$_PERL_MSG_AT_LINE//os && ($msg = "$1:$2 $msg");
    print STDERR &_call_format([$msg]);
}

sub _log_apache {
    my($severity, $msg) = @_;
#TODO: How to log a "notice" from mod_perl?
    if (Apache->request) {
	Apache->request->log_error($msg);
    }
    else {
	# something has gone wrong at httpd startup, pick
	# another output medium. (DO NOT CALL die, because
	# will recurse if intercept_die is true.
	&_log_stderr(@_);
    }
}

sub _log_syslog {
    my($severity, $msg) = @_;
    &Sys::Syslog::syslog($severity, $msg);
}

sub _log_stderr {
    my($severity, $msg) = @_;
    print STDERR $msg;
}

sub _timestamp {
    my($sec, $min, $hour, $mday, $mon, $year) = localtime(time);
    return sprintf('%d/%02d/%02d %02d:%02d:%02d ', 1900+$year, $mon+1, $mday,
           $hour, $min, $sec);
}

sub _trace_stack {
#TODO: reaching inside Carp isn't great.  Also copying code from &warn
#     is not pretty either.
    # Doesn't trim stack trace, so may be really long.  Have an
    # absolute limit?
    &$_LOGGER('err', Carp::longmess(''));
}

sub _warn_handler {
    my($msg) = @_;
    # Trim perl's message format (not enough info)
    $msg =~ s/$_PERL_MSG_AT_LINE//os && ($msg = "$1:$2 $msg");
    Bivio::IO::Alert->warn($msg);
    $_STACK_TRACE_WARN && &_trace_stack();
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
