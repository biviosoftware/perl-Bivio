# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::IO::Alert;
use strict;
$Bivio::IO::Alert::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::IO::Alert - error messages for servers and programs

=head1 SYNOPSIS

    use Bivio::IO::Alert;
    Bivio::IO::Alert->die("my message", $my_long_var);
    Bivio::IO::Alert->warn("my message");

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

=cut

use Bivio::IO::Config;

#=VARIABLES
# What perl outputs on "die" or "warn" without a newline
my($_PERL_MSG_AT_LINE) = ' at (\S+|\(eval \d+\)) line \d+\.' . "\n\$";
my($_PACKAGE) = __PACKAGE__;
my($_LOGGER) = \&_log_stderr;
my($_DEFAULT_MAX_ARG_LENGTH) = 128;
my($_MAX_ARG_LENGTH) = $_DEFAULT_MAX_ARG_LENGTH;
my($_WANT_PID) = 0;

#=INITIALIZATION
# Normalize error messages
$SIG{__DIE__} = \&_initial_die_handler;
$SIG{__WARN__} = \&_warn_handler;
Bivio::IO::Config->register();

=head1 METHODS

=cut

=for html <a name="configure"></a>

=head2 static configure(string class, hash cfg)

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

=item max_arg_length : int [128]

Maximum length of warning message components, i.e. arguments to
L<die|"die"> and L<warn|"warn">.

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

=back

=cut

sub configure {
    my(undef, $cfg) = @_;
    if ($cfg->{max_arg_length} && $cfg->{max_arg_length} > 0) {
	$_MAX_ARG_LENGTH = $cfg->{max_arg_length};
    }
    else {
	$_MAX_ARG_LENGTH = $_DEFAULT_MAX_ARG_LENGTH;
    }
    if ($cfg->{intercept_warn} || !exists($cfg->{intercept_warn})) {
	$SIG{__WARN__} = \&_warn_handler;
    }
    else {
	$SIG{__WARN__} eq \&_warn_handler
		&& ($SIG{__WARN__} = '');
    }
    if ($cfg->{intercept_die}) {
	$SIG{__DIE__} = \&_die_handler;
    }
    else {
	$SIG{__DIE__} eq \&_die_handler
		&& ($SIG{__DIE__} = '');
    }
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
	&Sys::Syslog::setlogsock($cfg->{syslog_socket} || 'unix');
	&Sys::Syslog::openlog($cfg->{log_name} || $0, 'pid',
		$cfg->{log_facility} || 'daemon');
	$_LOGGER = \&_log_syslog;
    }
    $_WANT_PID = $cfg->{want_pid};
    return;
}

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
    $msg =~ s/$_PERL_MSG_AT_LINE//o;
    Bivio::IO::Alert->warn($msg);
    return undef;
}

=for html <a name="format"></a>

=head2 static format(string package, string file, int line, string sub, array msg) : string

Formats I<pkg>, I<file>, I<line>, I<sub>, and I<msg> into a pretty printed
string.  Care is taken to truncate long arguments to C<max_arg_length>.  If an
element of I<msg> is an object which supports
<Bivio::UNIVERSAL::to_string|Bivio::UNIVERSAL/"to_string">, C<to_string> will
be called to convert the object to a string.

=cut

sub format {
    return &_format(@_);
}

=for html <a name="max_arg_length"></a>

=head2 max_arg_length() : int

Maximum length of an argument to any of the printing methods.

=cut

sub max_arg_length {
    return $_MAX_ARG_LENGTH;
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

=for html <a name="warn"></a>

=head2 static warn(string arg1, ...)

Sends warning message to the alert log.

Note: If the message consists of a single newline, nothing is output.

=cut

sub warn {
    shift(@_);
    int(@_) == 1 && $_[0] eq "\n" && return;
    &$_LOGGER('err', &_call_format(\@_));
}

#=PRIVATE METHODS

sub _call_format {
    my($msg) = @_;
    my($i) = 1;
    $i++ while caller($i) eq __PACKAGE__;
    return &_format(undef,
	    ((caller($i))[0,1,2], (caller($i+1))[$[+3] || undef),
	    $msg);
}

sub _die_handler {
    &_warn_handler(@_);
    CORE::die("\n");
}

sub _format {
    my(undef, $pkg, $file, $line, $sub, $msg) = @_;
    # depends heavily on perl's "die" syntax
    my($text) = $_WANT_PID ? "($$) " : '';
    $text .= defined($file) && $file =~ /^\(eval (\d+)\)$/
	    ? ((defined($pkg) ? ($pkg . '::') : '') . 'eval' . $1)
		    : defined($sub) ? $sub
			    : defined($pkg) ? $pkg
				    : defined($file) ? $file : 'line';
    defined($line) && ($text .= "[$line]");
    $text .= ' ';
    my($o);
    foreach $o (@$msg) {
	# Don't let to_string calls crash;
	defined($o) || ($text .= '<undef>', next);
	my($s);
	$s = &UNIVERSAL::can($o, 'to_string') ?
		(eval {$o->to_string} || $o) : $o;
	$text .= length($s) > $_MAX_ARG_LENGTH
		? (substr($s, 0, $_MAX_ARG_LENGTH) . '<...>')
			: $s;
    }
    substr($text, -1) eq "\n" || ($text .= "\n");
    return $text;
}

sub _initial_die_handler {
    my($msg) = @_;
    $msg =~ s/$_PERL_MSG_AT_LINE//o;
    CORE::die(&_call_format([$msg]));
}

sub _initial_warn_handler {
    my($msg) = @_;
    $msg =~ s/$_PERL_MSG_AT_LINE//o;
    print STDERR &_call_format([$msg]);
}

sub _log_apache {
    my($severity, $msg) =@_;
#RJN: How to log a "notice" from mod_perl?
    Apache->request->log_error($msg);
}

sub _log_syslog {
    my($severity, $msg) = @_;
    &Sys::Syslog::syslog($severity, $msg);
}

sub _log_stderr {
    my($severity, $msg) = @_;
    print STDERR $msg;
}

sub _warn_handler {
    my($msg) = @_;
    # Trim perl's message format (not enough info)
    $msg =~ s/$_PERL_MSG_AT_LINE//o;
    Bivio::IO::Alert->warn($msg);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
