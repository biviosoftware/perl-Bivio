# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::IO::Alert;
use strict;
use base 'Bivio::UNIVERSAL';

# C<Bivio::IO::Alert> formats warnings and error messages safely.  It limits
# argument lengths, outputs stack traces based on configuration parameters, and
# formats arguments using
# L<Bivio::UNIVERSAL::as_string|Bivio::UNIVERSAL/"as_string">, dies in "warn
# loops", and inserts time/pid if configured.
#
# You should use this module's L<warn|"warn"> instead of C<CORE::warn>, because
# special case arguments (C<undef>) are handled correctly, output length is
# limited on each argument, and data structures are printed instead of
# references.
#
# If there is an C<undef> as one of the arguments to L<warn|"warn">,
# L<warn_simply|"warn_simply">, or L<info|"info">, the output doesn't
# generate a nested warning.  Rather E<lt>undefE<gt> is output.
#
# Bivio::IO::Alert intercepts C<$SIG{__WARN__}> if configured to do so.
#
# Policies: C<intercept_warn> should probably be set.  This prevents perl
# warnings (C<warn>) from going into the bit bucket.  C<stack_trace_warn> is
# useful in production systems, because undefined (scalar) value messages are
# warnings in perl and not fatal.
#
# C<max_warnings> in any given program invocation is limited to
# a (default) 1000. You can L<reset_warn_counter|"reset_warn_counter">,
# which is typically used by servers.  Use L<info|"info"> to avoid
# this warn counter behavior in I<limited cases>. reset_warn_counter is
# called by L<Bivio::Agent::Dispatcher|Bivio::Agent::Dispatcher> on
# entry.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PERL_MSG_AT_LINE, $_LOGGER, $_LOG_FILE,
    $_DEFAULT_MAX_ARG_LENGTH, $_MAX_ARG_LENGTH, $_WANT_PID, $_WANT_TIME,
    $_STACK_TRACE_WARN, $_STACK_TRACE_WARN_DEPRECATED,
    $_MAX_WARNINGS, $_WARN_COUNTER, $_MAX_ARG_DEPTH, $_DEFAULT_MAX_ARG_DEPTH,
    $_DEFAULT_MAX_ELEMENT_COUNT, $_MAX_ELEMENT_COUNT, $_STRIP_BIT8,
);
BEGIN {
    # What perl outputs on "die" or "warn" without a newline
    $_PERL_MSG_AT_LINE = ' at (\S+|\(eval \d+\)) line (\d+)\.' . "\n\$";
    $_LOGGER = \&_log_stderr;
    $_DEFAULT_MAX_ARG_LENGTH = 2048;
    $_MAX_ARG_LENGTH = $_DEFAULT_MAX_ARG_LENGTH;
    $_MAX_ARG_DEPTH = $_DEFAULT_MAX_ARG_DEPTH = 3;
    $_MAX_ELEMENT_COUNT = $_DEFAULT_MAX_ELEMENT_COUNT = 20;
    $_WANT_PID = 0;
    $_WANT_TIME = 0;
    $_STACK_TRACE_WARN = 0;
    $_STACK_TRACE_WARN_DEPRECATED = 0;
    $_MAX_WARNINGS = 1000;
    $_WARN_COUNTER = $_MAX_WARNINGS;
    $_STRIP_BIT8 = 0;
}
my($_IDI) = __PACKAGE__->instance_data_index;
my($_WARN_EXACTLY_ONCE) = {};

#=IMPORTS
# Should not important anything else.
use Bivio::IO::Config;
use Carp ();

#=VARIABLES
my($_LAST_WARNING);
my($_FIRST_CONFIG) = 1;
Bivio::IO::Config->register({
    intercept_warn => 1,
    stack_trace_warn => 0,
    stack_trace_warn_deprecated => 0,
    max_arg_length => $_DEFAULT_MAX_ARG_LENGTH,
    max_arg_depth => $_DEFAULT_MAX_ARG_DEPTH,
    max_element_count => $_DEFAULT_MAX_ELEMENT_COUNT,
    want_stderr => 0,
    want_pid => 0,
    want_time => 0,
    max_warnings => $_MAX_WARNINGS,
    strip_bit8 => 0,
});

sub bootstrap_die {
    # (proto, string, ...) : undef
    # (proto, any, hash_ref, string, string, int) : undef
    # You should use L<Bivio::Die::die|Bivio::Die/"die">, not this method.
    #
    # Called by I<low level classes> in bOP which are used by
    # L<Bivio::Die|Bivio::Die>.
    #
    # This method tries to call L<Bivio::Die::die|Bivio::Die/"die"> if
    # it is defined and loaded.  Bivio::Die does not call this method.
    my($proto) = shift;
    Bivio::Die->throw_or_die(
	$proto->calling_context,
	@_,
    ) if UNIVERSAL::isa('Bivio::Die', 'Bivio::UNIVERSAL')
	&& UNIVERSAL::can('Bivio::Die', 'throw_or_die');
    CORE::die(_call_format($proto, \@_, 0));
    # DOES NOT RETURN
}

sub calling_context {
    my($proto, $calling_package) = @_;
    my($frame) = 1;
    if ($calling_package) {
	$frame++
	    while caller($frame) eq $calling_package;
    }
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = [
	map(+{
	    package => (caller($_))[0] || undef,
	    file => (caller($_))[1] || undef,
	    line => (caller($_))[2] || undef,
	    sub => (caller($_ + 1))[3] || undef,
	}, $frame, $frame + 1),
    ];
    return $self;
}

sub calling_context_get {
    my($self) = shift;
    my($fields) = $self->[$_IDI]->[0];
    return $self->return_scalar_or_array(
	map(exists($fields->{$_}) ? $fields->{$_}
	    : $self->bootstrap_die($_, ': not a calling_context field'),
	    @_),
    );
}

sub debug {
    # (proto, ...) : any
    # Calls L<info|"info">, and then returns its arguments (or first argument if !wantarray)
    #
    # B<Not meant for production code.>
    shift->info(@_);
    shift(@_)
	if _has_calling_context(\@_);
    return wantarray ? @_ : $_[0];
}

sub format {
    # (proto, string, string, int, string, array) : string
    # Formats I<pkg>, I<file>, I<line>, I<sub>, and I<msg> into a pretty printed
    # string.  Care is taken to truncate long arguments to
    # L<get_max_arg_length|"get_max_arg_length">.  No more than I<max_element_count>
    # will be printed per hash or array_ref.  I<max_arg_depth> limits depth of
    # recursion.  If an element of I<msg> is an object which supports
    # <Bivio::UNIVERSAL::as_string|Bivio::UNIVERSAL/"as_string">, C<as_string> will
    # be called to convert the object to a string.
    return _format(@_);
}

sub format_args {
    # (proto, any, ...) : string
    # Formats I<arg>s as a string.  Truncation, C<undef>, etc. handled properly.
    # Appends a newline.
    shift;
    my($res) = '';
    foreach my $o (@_) {
	# Only go three levels deep on structures
	$res .= _format_string($o, $_MAX_ARG_DEPTH);
    }
    $res .= "\n" unless substr($res, -1) eq "\n";
    return $res;
}

sub get_last_warning {
    # (proto) : string
    # Returns the last warning output.
    return $_LAST_WARNING;
}

sub get_max_arg_length {
    # (self) : int
    # Maximum length of an argument to any of the printing methods.
    return $_MAX_ARG_LENGTH;
}

sub get_top_package_file_line {
    return @{shift->[$_IDI]->[0]}{qw(package file line)};
}

sub handle_config {
    # (proto, string, hash) : undef
    # intercept_warn : boolean [true]
    #
    # If true, installs a C<$SIG{__WARN__}> handler which writes alerts on all
    # warnings.
    #
    # max_arg_length : int [2048]
    #
    # Maximum length of warning message components, i.e. arguments to
    # L<die|"die"> and L<warn|"warn">.
    #
    # max_arg_depth : int [3]
    #
    # Maximum nesting of formatted output, i.e., will only recurse to
    # I<max_arg_depth> in tree.
    #
    # max_element_count : int [20]
    #
    # Maximum number of elements to display in array_ref and hash_ref
    # of formatted output.
    #
    # max_warnings : int [1000]
    #
    # Maximum number of warnings between L<reset_warn_counter|"reset_warn_counter">
    # calls.  By default, L<reset_warn_counter|"reset_warn_counter"> is not
    # called, so this is the maximum per program invocation.
    #
    # stack_trace_warn_deprecated : boolean [false]
    #
    # Print a stack trace when L<warn_deprecated|"warn_deprecated"> is called.
    #
    # stack_trace_warn : boolean [false]
    #
    # If true, implies B<intercept_warn> is true and will print a stack trace on
    # C<CORE::warn>.  Only works on perl's warn, not on calls to L<warn|"warn">.
    #
    # stack_bit8 : boolean [false]
    #
    # If true, strips all chars 0x80 and above.
    #
    # want_stderr : boolean [false]
    #
    # If true, always writes to C<STDERR>.  Otherwise, determines where to write as
    # follows:
    #
    #
    # *
    #
    # If running under mod_perl, writes to apache error log
    #
    # *
    #
    # Otherwise, writes to stderr.
    #
    #
    # want_pid : boolean [false]
    #
    # Includes the pid in the log messages.
    #
    # want_time : boolean [false]
    #
    # Includes the time in the log messages.
    my(undef, $cfg) = @_;
    $Carp::MaxArgLen = $Carp::MaxEvalLen = $_MAX_ARG_LENGTH
	    = $cfg->{max_arg_length} + 0;
    $_MAX_ARG_DEPTH = $cfg->{max_arg_depth} + 0;
    $_MAX_ELEMENT_COUNT = $cfg->{max_element_count} + 0;

    # Must reset warn counter.  We don't call this except at config
    # time, so probably ok.  The low level code shouldn't loop. :-(
    $_WARN_COUNTER = $_MAX_WARNINGS = $cfg->{max_warnings};

    $_STACK_TRACE_WARN = $cfg->{stack_trace_warn};
    $_STACK_TRACE_WARN_DEPRECATED = $cfg->{stack_trace_warn_deprecated};
    $SIG{__WARN__} = \&_warn_handler
	    if $cfg->{intercept_warn} || $cfg->{stack_trace_warn};
    $_WANT_PID = $cfg->{want_pid};
    $_WANT_TIME = $cfg->{want_time};

    if ($_FIRST_CONFIG) {
	if ($cfg->{want_stderr}) {
	    $_LOGGER = \&_log_stderr;
	}
	elsif (exists($ENV{MOD_PERL})) {
	    $_LOGGER = \&_log_apache;
	}
	else {
	    # Default logger is stderr
	    $_LOGGER = \&_log_stderr;
	}
	$_FIRST_CONFIG = 0;
    }
    return;
}

sub info {
    my($proto, @args) = @_;
    $_LOGGER->(_call_format($proto, \@args))
	unless @args == 1 && ($args[0] || '') eq "\n";
    return;
}

sub internal_as_string {
    my($self) = @_;
    return [$self->calling_context_get(qw(file line))];
}

sub is_calling_context {
    my(undef, $value) = @_;
    return __PACKAGE__->is_blessed($value);
}

sub print_literally {
    # (proto, string, ...) : undef
    # Prints the values without doing argument interpretation.
    #
    # B<Use sparingly.>  Much better to us L<warn|"warn"> and L<info|"info">.
    shift;
    $_LOGGER->(join('', map(defined($_) ? $_ : '<undef>', @_)));
    return;
}

sub print_stack {
    # () : undef
    # Calls &$_LOGGER with stack trace as returned by Carp::longmess.
#TODO: reaching inside Carp isn't great.  Also copying code from &warn
#     is not pretty either.
    # Doesn't trim stack trace, so may be really long.  Have an
    # absolute limit?
    &$_LOGGER(Carp::longmess(''));
    return;
}

sub reset_warn_counter {
    # (self) : undef
    # Resets the internal warn counter to max_warnings.
    $_WARN_COUNTER = $_MAX_WARNINGS;
    return;
}

sub set_printer {
    # (self, string) : undef
    # (self, code_ref) : undef
    # (self, string, string) : undef
    # Overwrites logger set in handle_config with specified logger.  Logger options
    # are currently 'STDERR' and 'FILE'.  If 'FILE' is specified, the argument
    # I<log_file> is required as there is no default.
    #
    # If I<logger> is a code_ref, it will be called as follows:
    #
    #     &$logger($msg);
    #
    # This is a low level module in bOP.  This interface shouldn't be used in
    # general.  It's good for test handling.
    my($proto, $logger, $log_file) = @_;
    if ($logger eq 'STDERR' && $logger eq 'STDERR') {
	$_LOGGER = \&_log_stderr;
    }
    elsif ($logger eq 'FILE') {
	$proto->bootstrap_die('Must specify log file with FILE as printer')
		    unless defined($log_file);
	$_LOG_FILE = $log_file;
	$_LOGGER = \&_log_file;
    }
    elsif (ref($logger) eq 'CODE') {
	$_LOGGER = $logger;
    }
    else {
	$proto->bootstrap_die('Unknown logger type ', $logger);
    }
    return;
}

sub warn {
    # (proto, string, ...) : undef
    # Sends warning message to the alert log.
    #
    # Note: If the message consists of a single newline, nothing is output.
    my($proto, @msg) = @_;
    _do_warn($proto, \@msg, 0);
    return;
}

sub warn_deprecated {
    # (proto, string) : undef
    # Puts out a message warning of a deprecated usage.
    my($proto, @message) = @_;
    my($pkg) = caller(0);
    my($i) = 0;
    $i++
	while caller($i) eq $pkg;
    $proto->warn(
	'DEPRECATED: ',
	(caller($i-1))[3],
	': ',
	$proto->format_args(@message),
	'; called from ',
	(caller($i))[0],
	':',
	(caller($i))[2],
    );
    $proto->print_stack() if $_STACK_TRACE_WARN;
    return;
}

sub warn_exactly_once {
    my($proto) = shift;
    my($e) = $proto->format_args(@_);
    $proto->warn($e)
	unless $_WARN_EXACTLY_ONCE->{$e}++;
    return;
}

sub warn_simply {
    # (proto, string, ...) : undef
    # Sends warning message to the alert log.
    #
    # Note: If the message consists of a single newline, nothing is output.
    #
    # Does not output any info (pid, time, etc.)
    my($proto, @msg) = @_;
    _do_warn($proto, \@msg, 1);
    return;
}

sub _call_format {
    my($proto, $msg, $simply) = @_;
    return $simply ? $proto->format_args(@$msg)
	: _format(
	    $proto,
	    @{(_has_calling_context($msg) ? shift(@$msg)
		  : $proto->calling_context(__PACKAGE__)
	    )->[$_IDI]->[0]}{qw(package file line sub)},
	    $msg,
	);
}

sub _do_warn {
    # (proto, array_ref, boolean) : undef
    # Does the work of warn and warn_simply.
    my($proto, $args, $simply) = @_;
    int(@$args) == 1 && defined($args->[0]) && $args->[0] eq "\n" && return;
    $_LOGGER->($_LAST_WARNING = _call_format($proto, $args, $simply));
    return unless --$_WARN_COUNTER < 0;

    # This code is careful to avoid infinite loops.  Don't change it
    # unless you understand all the relationships.  5 is a slop on
    # warnings in the handle_die calls during Bivio::Die.
    $_WARN_COUNTER += 5;
    $_LOGGER->($_LAST_WARNING
	= "Bivio::IO::Alert TOO MANY WARNINGS (max=$_MAX_WARNINGS.)\n");
    CORE::die("\n");
    # DOES NOT RETURN
}

sub _format {
    # (proto, string, string, string, string, array_ref, boolean) : string
    # Formats the message with prefixes unless simply is true, iwc. it just
    # formats $msg.
    my($proto, $pkg, $file, $line, $sub, $msg) = @_;
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
    # Usually called in an initialization body
    else {
	$text .= defined($pkg) ? $pkg : defined($file) ? $file : '';
    }
    defined($line) && ($text .= ":$line");
    $text .= ' '.$proto->format_args(@$msg);
    return $text;
}

sub _format_string {
    # (any, int) : string
    # Returns $o formatted as a string.  If $depth <= 0, don't go uwrap
    # structures.
    my($o, $depth) = @_;
    # Avoid deep nesting
    if (--$depth > 0) {
	# Don't let as_string calls crash;  Only call as_string on refs.
	if (ref($o) eq 'ARRAY') {
	    my($s, $v) = '[';
	    my($i) = $_MAX_ELEMENT_COUNT;
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
	    my($i) = $_MAX_ELEMENT_COUNT;
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
    # (any) : string
    # Formats a single object, which may be undef.
    my($o) = @_;
    return '<undef>'
	unless defined($o);
    # Don't output any errors if there is an error evaluating $o
    local($SIG{__WARN__});
    eval {$o = $o->as_string}
	if ref($o) && UNIVERSAL::can($o, 'as_string');
    $o =~ s/[\200-\377]//g
	if $_STRIP_BIT8;
    return length($o) > $_MAX_ARG_LENGTH
	? (substr($o, 0, $_MAX_ARG_LENGTH) . '<...>')
	: _format_string_with_type($o);
}

sub _format_string_with_type {
    my($value) = @_;
#TODO: DateTime should be an object
    return $Bivio::Type::DateTime::VERSION
	&& Bivio::Type::DateTime->is_valid_specified($value)
	? Bivio::Type::DateTime->to_string($value)
        : $value;
}

sub _has_calling_context {
    my($msg) = @_;
    return __PACKAGE__->is_blessed($msg->[0]);
}

sub _log_apache {
    # (string) : undef
    # Logs to apache directly or stderr if it doesn't have a request.
    my($msg) = @_;
#TODO: How to log a "notice" from mod_perl?
    if (Apache->request) {
	Apache->request->log_error($msg);
    }
    else {
	# something has gone wrong at httpd startup, pick
	# another output medium. (DO NOT CALL die, because
	# will recurse if someone is intercepting __DIE__).
	_log_stderr(@_);
    }
    return;
}

sub _log_file {
    # (string) : undef
    # Logs to a file.  Opens the file for each message.
    my($msg) = @_;
    open(FILE, ">>$_LOG_FILE");
    print(FILE $msg);
    close(FILE);
    return;
}

sub _log_stderr {
    # (string) : undef
    # Writes to STDERR.
    my($msg) = @_;
    print STDERR $msg;
    return;
}

sub _timestamp {
    # () : string
    # Returns local time in a format suitable for logging.
    my($sec, $min, $hour, $mday, $mon, $year) = localtime(time);
    return sprintf('%d/%02d/%02d %02d:%02d:%02d ', 1900+$year, $mon+1, $mday,
           $hour, $min, $sec);
}

sub _warn_handler {
    # (string) : undef
    # Handler for $SIG{__WARN__}.  Reformats message.  May output stack trace
    # if $_STACK_TRACE_WARN.
    my($msg) = @_;
    # Trim perl's message format (not enough info)
    $msg =~ s/$_PERL_MSG_AT_LINE//os && ($msg = "$1:$2 $msg");
    __PACKAGE__->warn($msg);
    __PACKAGE__->print_stack() if $_STACK_TRACE_WARN;
    return;
}

1;
