# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::IO::Config;
use strict;
$Bivio::IO::Config::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::IO::Config - simple configuration using perl syntax

=head1 SYNOPSIS

    use Bivio::IO::Config;
    Bivio::IO::Config->register();
    sub configure {
	my($class, $cfg) = @_;
	$cfg->{param1} && ...;
    }

    Bivio::IO::Config->initialize(@ARGV);
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

#=IMPORTS
# Do not use explicitly, to ensure this module initialized first
# use Bivio::IO::Alert;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
# The configuration read off disk or passed in
my($_ACTUAL) = {};
# Was "initialized" called once?
my($_INITIALIZED) = 0;
# List of packages registered
my(@_REGISTERED) = ();
# Configuration specifications for registered packages
my(%_SPEC) = ();
# Has a package been configured?
my(%_CONFIGURED) = ();

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
	    || die("$pkg: named config not specified");
    if (defined($name)) {
	defined($pkg_cfg->{$name})
		|| die("$pkg $name: named config not found");
	return $pkg_cfg->{$name};
    }
    # Retrieve the "undef" config, see _get_pkg
    my($cfg) = $pkg_cfg->{&NAMED};
    my(@bad) = grep(defined($cfg->{$_}) && $cfg->{$_} eq &REQUIRED,
	    keys(%$cfg));
    @bad || return;
    @bad = sort @bad;
    die("$pkg @bad: named config required");
}

=for html <a name="initialize"></a>

=head2 initialize(string arg1, ...)

=head2 initialize(hash config)

Initializes the configuration from the command line arguments, from an explicit
hash, or from the environment variable C<$BIVIO_CONFIG> (only if not running
setuid).

Calls registrants if configuration is valid.

=cut

sub initialize {
    my(undef, $arg) = @_;
    $_INITIALIZED = 1;
    %_CONFIGURED = ();
    # On failure, we have no configuration.
    $_ACTUAL = {};
    my($file);
    if (defined($arg)) {
	if (ref($arg) eq 'HASH') {
	    $_ACTUAL = $arg;
	}
	else {
	    -r $arg || Bivio::IO::Alert->die(
		    "$arg: not readable file\nusage: $0 config.pl");
	    $file = $arg;
	}
    }
    # If we are setuid or setgid, then don't initialize from environment
    # variables.
    elsif ($< == $> && $( == $) && defined($ENV{BIVIO_CONFIG})) {
	-r $ENV{BIVIO_CONFIG} || Bivio::IO::Alert->die(
		"\$BIVIO_CONFIG environment variable invalid\n");
	$file = $ENV{BIVIO_CONFIG};
    }
    if (defined($file)) {
	my($data) = do $file;
	ref($data) eq 'HASH' || Bivio::IO::Alert->die(
		"$file: config parse failed: ",
		$@ ? $@ : "empty or not a hash_ref");
	$_ACTUAL = $data;
    }
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
    my($cfg) = ref($_ACTUAL->{$pkg}) ? $_ACTUAL->{$pkg} : {};
    if ($_SPEC{$pkg}) {
	# Set the defaults for the common configuration
	my($spec) = $_SPEC{$pkg};
	while (my($k, $v) = each(%$spec)) {
	    # Have an actual value for specified config?
	    exists($cfg->{$k}) && next;
	    # Is the named spec?
	    $k eq &NAMED && next;
	    # If it is required, then it is an error
	    $v eq &REQUIRED
		    && die("$pkg $k: config parameter required");
	    # Assign the default value
	    $cfg->{$k} = $v;
	    # Set the defaults for all named configuration
	    if (defined($spec->{&NAMED})) {
		my($named_spec) = $spec->{&NAMED};
		# Fill in the cfg for the "undef" case of &get
		my($undef_cfg) = {%$named_spec};
		while (my($k, $v) = each(%$cfg)) {
		    # Does a spec exist for this param?
		    exists($spec->{$k}) && next;
		    # Does a named spec exist?
		    if (exists($named_spec->{$k})) {
			# Override named default with actual config
			$undef_cfg->{$k} = $v;
			next;
		    }
		    # Must be a named configuration section
		    ref($v) || die("$pkg $k: invalid config parameter");
		    while (my($nk, $nv) = each(%$named_spec)) {
			# Have an actual value for specified named config?
			exists($v->{$nk}) && next;
			# If it is required, then it is an error
			$nv eq &REQUIRED && die(
				"$pkg $nk: named config parameter required");
			# Assign the default value
			$v->{$nk} = $nv;
		    }
		}
		# Overload the use of "NAMED" to mean undef named cfg
		# in actual configuration.
		$cfg->{&NAMED} = $undef_cfg;
	    }
	}
    }
    $_CONFIGURED{$pkg} = 1;
    return $_ACTUAL->{$pkg} = $cfg;
}

=head1 ENVIRONMENT

=over 4

=item $BIVIO_CONFIG

Name of configuration file if not passed command-line arguments.

=back

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
