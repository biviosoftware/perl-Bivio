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

# Do not use explicitly, to ensure this module initialized first
# use Bivio::IO::Alert;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
# So we behave nicely before we are initialized
my($_DATA) = {};
my($_INITIALIZED) = 0;
# List of packages registered
my(@_REGISTERED) = ();

=head1 METHODS

=cut

=for html <a name="get"></a>

=head2 static get() : hash_ref

=head2 static get(string package) : hash_ref

If no package is supplied, uses caller's package.  Looks up configuration for
the package.  If none is found, returns an empty hash_ref.

NOTE: Should not be called from a package body, because
L<initialize|"initialize"> should be called by main.

=cut

sub get {
    my($proto, $package) = @_;
    defined($package) || ($package = caller);
    return ref($_DATA->{$package}) eq 'HASH' ? $_DATA->{$package} : {};
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
    # On failure, we have no configuration.
    $_DATA = {};
    my($file);
    if (defined($arg)) {
	if (ref($arg) eq 'HASH') {
	    $_DATA = $arg;
	}
	else {
	    -r $arg || die("$arg: not readable file\nusage: $0 config.pl");
	    $file = $arg;
	}
    }
    # If we are setuid or setgid, then don't initialize from environment
    # variables.
    elsif ($< == $> && $( == $) && defined($ENV{BIVIO_CONFIG})) {
	-r $ENV{BIVIO_CONFIG}
		|| die("\$BIVIO_CONFIG environment variable invalid\n");
	$file = $ENV{BIVIO_CONFIG};
    }
    if (defined($file)) {
	my($data) = do $file;
	ref($data) eq 'HASH'
		|| die("$file: config parse failed: ", $@ ? $@
			: "empty or not a hash_ref");
	$_DATA = $data;
    }
    # Call registrants in FIFO
    my($r);
    foreach $r (@_REGISTERED) {
	&_configure($r);
    }
    return;
}

=for html <a name="register"></a>

=head2 register()

Calling package will be put in the list of packages to be configured.  A
callback may happen immediately, if L<initialize|"initialize"> was called
already.

The calling package must define a C<configure> method which takes two
arguments, the class and the configuration as a hash.

=cut

sub register {
    my($proto) = @_;
    my($pkg) = caller;
    defined(&{$pkg . '::configure'}) || die("&$pkg\::configure not defined");
    push(@_REGISTERED, $pkg);
    $_INITIALIZED && &_configure($pkg);
    return;
}

#=PRIVATE METHODS

sub _configure {
    my($pkg) = @_;
    Bivio::IO::Alert->eval_or_warn(sub {
	&{\&{$pkg . '::configure'}}($pkg, &get(undef, $pkg))
    });
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
