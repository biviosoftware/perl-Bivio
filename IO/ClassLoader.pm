# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::IO::ClassLoader;
use strict;
$Bivio::IO::ClassLoader::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::IO::ClassLoader - implements dynamic class loading

=head1 SYNOPSIS

    use Bivio::IO::ClassLoader;
    Bivio::IO::ClassLoader->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::ClassLoader::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::IO::ClassLoader> implements dynamic class loading.  There
are two forms: fully qualified (L<simple_require|"simple_require">)
and configurable.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my(%_PACKAGES);

=head1 METHODS

=cut

=for html <a name="simple_require"></a>

=head2 static simple_require(string package, ...)

Loads the packages and throws an exception if any one couldn't be loaded.
I<package> must be a fully-qualified perl package name.

=cut

sub simple_require {
    my(undef, @pkg) = @_;
    my($pkg);
    foreach $pkg (@pkg) {
	die('undefined package') unless $pkg;
	no strict 'refs';

	# We use our own symbol table, because there is a weird case
	# with enums which define the package symbol table in advance
	# of loading. In other words, this doesn't work:
	#    next if defined(%{*{"$pkg\::"}});
	next if defined($_PACKAGES{$pkg});

	# Must be a "bareword" for it to do '::' substitution
	eval("require $pkg") || die($@);

	# Only define if loads properly.
	$_PACKAGES{$pkg} = 1;
    }
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
