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

@Bivio::IO::Alert::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::IO::Alert> outputs error messages for programs and servers.  It also
intercepts $SIG{__DIE__} and $SIG{__WARN__} based on its
configuration parameters.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_INITIALIZED);
my($_LOGGER);
my($_MAX_ARG_LENGTH);

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

=for html <a name="format"></a>

=head2 static format(string package, string file, int line, string sub, array msg) : string

Formats I<pkg>, I<file>, I<line>, I<sub>, and I<msg> into a pretty printed
string.  Care is taken to truncate long arguments to C<max_arg_length>.  If an
element of I<msg> is an object which supports
<Bivio::UNIVERSAL::to_string|Bivio::UNIVERSAL/"to_string">, C<to_string> will
be called to convert the object to a string.

=cut

sub format {
    $_INITIALIZED || &_initialize();
    return &_format(@_);
}

=for html <a name="max_arg_length"></a>

=head2 max_arg_length() : int

Maximum length of an argument to any of the printing methods.

=cut

sub max_arg_length {
    $_INITIALIZED || &_initialize();
    return $_MAX_ARG_LENGTH;
}

=for html <a name="print"></a>

=head2 static print(string severity, string msg)

Writes an already formatted alert at a particular severity level.  The severity
levels supported are C<debug> and C<err>.

=cut

sub print {
    $_INITIALIZED || &_initialize();
    my($proto, $severity, $msg) = @_;
    &$_LOGGER($severity, $msg);
}

=for html <a name="warn"></a>

=head2 static warn(string arg1, ...)

Sends warning message to the alert log.

=cut

sub warn {
    $_INITIALIZED || &_initialize();
    shift(@_);
    my($i) = 2;
    $i++ while caller($i) eq __PACKAGE__;
    &$_LOGGER('err', &_format(undef,
	    ((caller($i))[0,1,2], (caller($i+1))[$[+3] || undef),
	    \@_));
}

#=PRIVATE METHODS

sub _die_handler {
    my($msg) = @_;
    $msg eq "\n" || Bivio::IO::Alert->warn($msg);
    CORE::die("\n");
}

sub _format {
    my($proto, $pkg, $file, $line, $sub, $msg) = @_;
#RJN: This is actually incorrect.  Dynamic evals are don't have line numbers.
    my($text) = defined($sub) ? $sub : defined($pkg) ? $pkg :
	    defined($file) ? $file : 'eval';
    defined($line) && ($text .= "[$line]");
    $text .= ' ';
    my($o);
    foreach $o (@$msg) {
	# Don't let to_string calls crash;
	defined($o) || ($text .= '<undef>', next);
	my($s);
	$s = &UNIVERSAL::can($o, 'to_string') ?
		(eval {$o->to_string} || $o) : $o;
	$text .= substr($s, 0, $_MAX_ARG_LENGTH) . '<...>';
    }
    substr($text, -1) eq "\n" || ($text .= "\n");
    return $text;
}

sub _initialize {
    $_INITIALIZED && return;
    my($cfg) = Bivio::IO::Config->get();
    $_MAX_ARG_LENGTH = $cfg->{max_arg_length} || 128;
    $cfg->{intercept_warn} && ($SIG{__WARN__} = \&_warn_handler);
    $cfg->{intercept_die} && ($SIG{__DIE__} = \&_die_handler);
    if ($cfg->{print_to_stderr}) {
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
    Bivio::IO::Alert->warn(@_);
}

=head1 CONFIGURATION

=over 4

=item intercept_die : boolean [false]

If true, installs a C<$SIG{__DIE__}> handler which writes alerts on all
calls to die.

=item intercept_warn : boolean [false]

If true, installs a C<$SIG{__WARN__}> handler which writes alerts on all
warnings.

=item log_facility : string [daemon]

If writing to C<Sys::Syslog>, the facility to use.

=item log_name : string [$0]

If writing to C<Sys::Syslog>, the name of the server.

=item print_to_stderr : boolean [false]

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

=back

=cut

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
