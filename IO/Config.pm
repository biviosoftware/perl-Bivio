# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::IO::Config;
use strict;
$Bivio::IO::Config::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::IO::Config - simple configuration using perl syntax

=head1 SYNOPSIS

    use Bivio::IO::Config;
    my($cfg) = Bivio::IO::Config->get();
    my($cfg) = Bivio::IO::Config->get("Some::Package");

=cut

use Bivio::IO::Config;
@Bivio::IO::Config::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::IO::Config> is a simple configuration mechanism.  A configuration file
is a hash_ref of packages and hash_refs.  Each package's hash_ref contains
configuration name/value tuples.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_DATA);
my($_INITIALIZED) = 0;

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
    $_INITIALIZED || Bivio::IO::Config->initialize();
    defined($package) || ($package = caller);
    return ref($_DATA->{$package}) eq 'HASH' ? $_DATA->{$package} : {};
}

=for html <a name="initialize"></a>

=head2 initialize(array argv)

Initializes the configuration from the command line arguments or from the
environment variable C<$BIVIO_CONFIG>.  Will be called automatically if not
called by main.

=cut

sub initialize {
    $_INITIALIZED && return;
    # On failure, we have no configuration.  The caller is free to
    # continue.
    $_DATA = {};
    $_INITIALIZED = 1;
    shift(@_);
    my($file);
    if (@_) {
	-r $_[0] || die("usage: $0 config.pl\n");
	$file = $_[0];
    }
    elsif (defined($ENV{BIVIO_CONFIG})) {
	-r $ENV{BIVIO_CONFIG}
		|| die("\$BIVIO_CONFIG environment variable invalid\n");
	$file = $ENV{BIVIO_CONFIG};
    }
    else {
	return;
    }
    my($data) = do $file;
    unless (ref($data) eq 'HASH') {
	$@ && die("$file: config parse failed: $@");
	die("$file: not a config file");
    }
    $_DATA = $data;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
