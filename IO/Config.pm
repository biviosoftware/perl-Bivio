# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::IO::Config;
use strict;
$Bivio::IO::Config::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::IO::Config - simple configuration using perl syntax

=head1 SYNOPSIS

    b-<program> [--Module.param=value] [--TRACE=value]

    use Bivio::IO::Config;
    Bivio::IO::Config->register();
    sub configure {
	my($class, $cfg) = @_;
	$cfg->{param1} && ...;
    }

    Bivio::IO::Config->initialize();
    Bivio::IO::Config->initialize(\@argv);
    Bivio::IO::Config->initialize($file);
    Bivio::IO::Config->initialize({
	'Some::Package' => {
	    'some_param' => $some_value,
	},
	'Some::Other::Package' => {
	    'some_other_param' => $some_other_value,
	},
    });

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::Config::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::IO::Config> is a simple configuration mechanism.  A configuration file
is a hash_ref of packages and hash_refs.  Each package's hash_ref contains
configuration name/value tuples.

Modules are dynamically configured in the order they are initialized.
Each module defines a C<configure> method and
calls L<register|"register"> during initialization.
When L<initialize|"initialize"> is called, the registrants are
upcalled with their configuration.

Programs may pass I<@ARGV> to L<initialize|"initialize"> to allow
individual configuration parameters to be set from command line arguments.
See L<initialize|"initialize"> for syntax.

=cut

=head1 CONSTANTS

=cut

=for html <a name="NAMED"></a>

=head2 NAMED : string

Identifies the named configuration specification, see L<register|"register">.

=cut

sub NAMED {
    return \&NAMED;
}

=for html <a name="REQUIRED"></a>

=head2 REQUIRED : string

Returns a unique value which passed in spec (see L<get|"get">)
will indicate the configuration parameter is required.

=cut

sub REQUIRED {
    return \&REQUIRED;
}

#=VARIABLES
my($_PACKAGE, $_ACTUAL, $_INITIALIZED, @_REGISTERED, %_SPEC, %_CONFIGURED);
# Make sure we are initialized
BEGIN {
    $_PACKAGE = __PACKAGE__;
    # The configuration read off disk or passed in
    $_ACTUAL = {};
    # Was "initialized" called once?
    $_INITIALIZED = 0;
    # List of packages registered
    @_REGISTERED = ();
    # Configuration specifications for registered packages
    %_SPEC = ();
    # Has a package been configured?
    %_CONFIGURED = ();
}

#=IMPORTS
# Do not use explicitly, to ensure this module initialized first
# use Bivio::IO::Alert;
# use Bivio::IO::Trace;

=head1 METHODS

=cut

=for html <a name="get"></a>

=head2 static get(string name) : hash

Looks up configuration for the caller's package.  If name is provided, returns
the configuration hash bound to I<name> within the package's configuration
space, e.g. given the config:

    'Bivio::IPC::Server' => {
        'listen' => 35,
        'my_server' => {
            'port' => 1234,
            'timeout' => 60_000,
        },
        'my_other_server' => {
            'port' => 9999,
        },
    }

C<get('my_server')> will return the following hash:

    {
        'listen' => 35,
        'port' => 1234,
        'timeout' => 60_000,
    }

Required configuration is checked during this call.

If I<name> is passed but is undefined, then only the named configuration
parameters will be returned.

If I<name> is not passed, then the entire configuration will be returned,
including specific named sections.

NOTE: Should not be called from a package body, because
L<initialize|"initialize"> should be called by main.

=cut

sub get {
    my($proto, $name) = @_;
    my($pkg);
    my($i) = 0;
    0 while ($pkg = caller($i++)) eq __PACKAGE__;
    my($pkg_cfg) = &_get_pkg($pkg);
    int(@_) < 2 && return $pkg_cfg;
    my($spec) = $_SPEC{$pkg};
    defined($spec) && defined($spec->{&NAMED})
	    || die("$pkg: NAMED config not specified");
    if (defined($name)) {
	defined($pkg_cfg->{$name})
		|| die("$pkg.$name: named config not found");
	return $pkg_cfg->{$name};
    }
    # Retrieve the "undef" config, see _get_pkg
    my($cfg) = $pkg_cfg->{&NAMED};
    my(@bad) = grep(defined($cfg->{$_}) && $cfg->{$_} eq &REQUIRED,
	    keys(%$cfg));
    @bad || return $cfg;
    @bad = sort @bad;
    die("$pkg.(@bad): named config required");
}

=for html <a name="initialize"></a>

=head2 initialize(string file)
=head2 initialize(string file, array argv)

=head2 initialize(hash config, array argv)

=head2 initialize(array argv)

=head2 initialize()

Initializes the configuration from I<config> hash or I<file> which contains
a hash.

Without an argument or with just I<argv>, looks for the name of a configuration
file as follows:

=over 4

=item 1.

If running setuid, setgid, or as root, skip to step 4.

=item 2.

If the environment variable I<$BIVIO_CONF> is defined,
identifies the name of the configuration file which
must contain a hash.

=item 3.

If the file F<bivio.conf> exists (in the current directory),
it must contain a hash.

=item 4.

The file F</etc/bivio.conf> must exist and contain a hash.

=back

If none of the files are found or they do not contain a hash, throws an
exception.

If I<argv> is supplied and not running setuid or setgid (but may be
running as root), extracts (i.e. deletes) arguments from the
I<argv> of the form:

    --Module.param=value

and sets configuration of the form:

    Module->{param} = value;

I<param> may be of the form I<idx1.idx2.idx3> which translates to:

    Module->{idx1}->{idx2}->{idx3} = value;

An error during evaluation causes program termination.  To set a
value to undef, use the word C<undef>.

HACK: Since it is fairly common, the option I<--TRACE> is translated
to I<--Bivio::IO::Trace.package_filter> for brevity.

NOTE: I<Module> and I<param> must contain only word characters (except
for C<::> and C<.> separators) for this syntax to work.

If a valid configuration is found, calls packages which have
called L<register|"register">.

=cut

sub initialize {
    my(undef, $arg) = @_;
    my($argv) = $_[$#_];
    $_INITIALIZED = 1;
    %_CONFIGURED = ();
    # On failure, we have no configuration.
    $_ACTUAL = {};
    my($file);
    my($not_setuid) = $< == $> && $( == $);
    # If $arg is an ARRAY, then it is $argv
    if (defined($arg) && ref($arg) ne 'ARRAY') {
	if (ref($arg) eq 'HASH') {
	    $_ACTUAL = $arg;
	}
	else {
	    $file = $arg;
	}
    }
    else {
	# If we are setuid or setgid or as root, then don't initialize from
	# environment variables or files in the current directory.
	# /etc/bivio.conf is last resort if the file doesn't exist.
	$file = $ENV{BIVIO_CONF} || 'bivio.conf';
	unless (-f $file && $< != 0 && $not_setuid) {
	    $file = '/etc/bivio.conf';
	}
    }
    if (defined($file)) {
	my($actual) = do $file;
	ref($actual) eq 'HASH' || Bivio::IO::Alert->die(
		"$file: config parse failed: ",
		$@ ? $@ : "empty or not a hash_ref");
	$_ACTUAL = $actual;
    }
    $not_setuid && ref($argv) eq 'ARRAY' && &_process_argv($_ACTUAL, $argv);
    # Call registrants in FIFO
    my($pkg);
    foreach $pkg (@_REGISTERED) {
	&{\&{$pkg . '::configure'}}($pkg, &_get_pkg($pkg));
    }
    return;
}

=for html <a name="register"></a>

=head2 register(hash spec)

Calling package will be put in the list of packages to be configured.  A
callback may happen immediately, if L<initialize|"initialize"> was called
already.

The calling package must define a C<configure> method which takes two
arguments, the class and the configuration as a hash.

If I<spec> is supplied, the values will be filled in when
L<get|"get"> is called or the values are upcalled to I<configure>.

A configuration I<spec> looks like:

    {
	'my_optional_param' => 35,
        'my_required_param' => Bivio::IO::Config->REQUIRED,
        Bivio::IO::Config->NAMED => {
            'my_named_optional_param' => 'hello',
            'my_named_required_param' => Bivio::IO::Config->REQUIRED,
        }
    }

Named configuration allows the package's configuration to be separately
named.  For example, you might have several named databases you want
to configure.  Named configuration is initialized from three locations:

=over 4

=item *

A specifically named configuration section, e.g. C<my_server>.

=item *

The parameters found in the (unnamed) common part of the configuration
using the names found in the L<NAMED|"NAMED"> part of the specification.

=item *

Lastly, the default values specified in the L<NAMED|"NAMED"> specification.

=back

All configuration names must be fully specified.

=cut

sub register {
    my($proto, $spec) = @_;
    my($pkg) = caller;
    defined(&{$pkg . '::configure'}) || Bivio::IO::Alert->die(
	    "&$pkg\::configure not defined");
    push(@_REGISTERED, $pkg);
    $_SPEC{$pkg} = $spec;
    $_INITIALIZED && &_configure($pkg);
    return;
}

#=PRIVATE METHODS

sub _get_pkg {
    my($pkg) = @_;
    $_CONFIGURED{$pkg} && return $_ACTUAL->{$pkg};
    my($actual) = ref($_ACTUAL->{$pkg}) ? $_ACTUAL->{$pkg} : {};
    if ($_SPEC{$pkg}) {
	# Set the defaults for the common configuration
	my($spec) = $_SPEC{$pkg};
	while (my($k, $v) = each(%$spec)) {
	    # If it is required, then it is an error
	    if (defined($v) && $v eq &REQUIRED) {
		defined($actual->{$k}) && next;
		die("$pkg.$k: config parameter not defined");
	    }
	    # Have an actual value for specified config?
	    exists($actual->{$k}) && next;
	    # Is the named spec?
	    $k eq &NAMED && next;
	    # Assign the default value
	    $actual->{$k} = $v;
	}
	# Set the defaults for all named configuration
	if (defined($spec->{&NAMED})) {
	    my($named_spec) = $spec->{&NAMED};
	    # Fill in the actual for the "undef" case of &get
	    my($undef_cfg) = {%$named_spec};
	    while (my($k, $v) = each(%$actual)) {
		# Does a spec exist for this param?
		exists($spec->{$k}) && next;
		# Does a named spec exist for this param?
		if (exists($named_spec->{$k})) {
		    # Override named default with actual config
		    $undef_cfg->{$k} = $v;
		    next;
		}
		# Must be a named configuration section
		my($named_actual) = $v;
		ref($named_actual) || die("$pkg.$k: invalid config parameter");
		while (my($nk, $nv) = each(%$named_spec)) {
		    # If it is required, then must be defined (not just exists)
		    if (defined($nv) && $nv eq &REQUIRED) {
			# Defined in named section?
			defined($named_actual->{$nk}) && next;
			# Defined in common section?
			if (defined($actual->{$nk})) {
			    $named_actual->{$nk} = $actual->{$nk};
			    next;
			}
			die("$pkg.$nk: named config parameter not defined");
		    }
		    else {
			# Have an actual value for specified named config?
			exists($named_actual->{$nk}) && next;
		    }
		    # Have an actual value in the common area?
		    if (exists($actual->{$nk})) {
			$named_actual->{$nk} = $actual->{$nk};
			next;
		    }
		    # Assign the default value (not found in either section)
		    $named_actual->{$nk} = $nv;
		}
	    }
	    # Overload the use of "NAMED" to mean undef named cfg
	    # in actual configuration.
	    $actual->{&NAMED} = $undef_cfg;
	}
    }
    $_CONFIGURED{$pkg} = 1;
    return $_ACTUAL->{$pkg} = $actual;
}

sub _process_argv {
    my($actual, $argv) = @_;
    for (my($i) = 0; $i < int(@$argv); $i++) {
	my($a) = $argv->[$i];
	# HACK: Probably want to generalize(?)
	$a =~ s/^--TRACE=/--Bivio::IO::Trace.package_filter=/s;
	# Matches our form?
	(my($m, $p, $v) = $a =~ /^--([\w:]+)\.([.\w]+)=(.*)$/s) || next;
	$v eq 'undef' && ($v = undef);
	# Ensure the hashes exist down the chain, starting at the module ($m)
	# perl in Lispish
	my($ref, $car, $cdr) = ($actual, $m, $p);
	while (length($cdr)) {
	    exists($ref->{$car}) || ($ref->{$car} = {});
            $ref = $ref->{$car};
	    ($car, $cdr) = split(/\./, $cdr, 2);
	}
	$ref->{$car} = $v;
	# Get rid of processed parameter
	splice(@$argv, $i--, 1);
    }
}

=head1 ENVIRONMENT

=over 4

=item $BIVIO_CONF

Name of configuration file if L<initialize|"initialize"> is not passed
arguments and the program is not running setuid, setgid, or as root.

=back

=head1 FILES

=over 4

=item bivio.conf

Default value for environment variable I<$BIVIO_CONF>.

=item /etc/bivio.conf

Name of configuration used if L<initialize|"initialize"> is not passed
arguments and the programming is running setuid, setgid, or as root, or the
file identified by C<$BIVIO_CONF> (or its default) is not found.

=back

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
