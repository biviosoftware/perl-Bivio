# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::SingletonMap;
use strict;
$Bivio::Type::SingletonMap::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::SingletonMap - maps classes to singleton objects

=head1 SYNOPSIS

    use Bivio::Type::SingletonMap;
    Bivio::Type::SingletonMap->put($classes);
    Bivio::Type::SingletonMap->get($class1, $class2, ...);

=cut

use Bivio::UNIVERSAL;
@Bivio::Type::SingletonMap::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Type::SingletonMap> maps class names to singleton objects
of those classes.  Singletons are initialized at startup with
a call to C<new>.

This class needn't be subclassed but typically is.  If it is,
the classes are stored in distinct spaces.  This would allow
instantiating singletons in different ways in different
contexts.  Subclasses of this module COULD control how the
singletons are instantiated.  Currently, there is only way
to instantiate.

=cut

#=IMPORTS
use Carp ();
use Bivio::Util;

#=VARIABLES
# Key to this is a package name ($proto).  The value is a
# map of class names to singletons.
my(%_MAP);

=head1 METHODS

=cut

=for html <a name="get"></a>

=head2 static get(string class, ...) : (UNIVERSAL, ...)

Returns the list of named instances.  I<class> is qualified by
the package which owns the map.

=cut

sub get {
    my($map) = $_MAP{shift(@_)};
    @_ || Carp::croak('must supply at least one class argument');
    return map {
	exists($map->{$_}) || Carp::croak("$_: no such class in cache");
	$map->{$_}
    } @_;
}

=for html <a name="initialize"></a>

=head2 initialize(array_ref classes) : boolean

Special form of L<put|"put">.  If the map already contains an entry for this
package, returns false and does nothing.  Otherwise, calls L<put|"put">.

Simplies implementation of C<initialize> method in subclasses.

=cut

sub initialize {
    my($pkg) = shift;
    # Use $pkg-> form to allow subclasses to override put and still
    # retain this functionality.
    return 0 if $_MAP{$pkg};
    $pkg->put(@_);
    return 1;
}

=for html <a name="put"></a>

=head2 static put(array_ref classes)

I<classes> is a list of class names which are instantiated with
C<new>.  Will C<require> the modules, so you needed C<use> them.

I<classes> is passed as an C<array_ref> to allow for expansion
of this routine in the future.

=cut

sub put {
    my($pkg, $classes) = @_;
    Bivio::Util::my_require(@$classes);
    $_MAP{$pkg} = {map {
	($_, $_->new);
    } @$classes};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
