# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Collection::SingletonMap;
use strict;
$Bivio::Collection::SingletonMap::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Collection::SingletonMap - maps classes to singleton objects

=head1 SYNOPSIS

    use Bivio::Collection::SingletonMap;
    Bivio::Collection::SingletonMap->put($classes);
    Bivio::Collection::SingletonMap->get($class1, $class2, ...);

=cut

use Bivio::UNIVERSAL;
@Bivio::Collection::SingletonMap::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Collection::SingletonMap> maps class names to singleton objects of
those classes.  Singletons are initialized with a call to C<get_instance> or
C<new> depending on which exists.

This class needn't be subclassed but typically is.  If it is,
the classes are stored in distinct spaces.  This would allow
instantiating singletons in different ways in different
contexts.  Subclasses of this module I<could> control how the
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

If the singleton doesn't exist, tries to "put" it.

=cut

sub get {
    my($proto) = shift;
    my($class) = ref($proto) || $proto;
    $_MAP{$class} = {} unless $_MAP{$class};
    my($map) = $_MAP{$class};
    @_ || Carp::croak('must supply at least one class argument');
    my(@res) = map {
	$proto->put($_) unless exists($map->{$_});
	$map->{$_};
    } @_;
    return @res if wantarray;
    die('get not called in array context and more than one return result')
	    unless int(@res) == 1;
    return $res[0];
}

=for html <a name="put"></a>

=head2 static put(string class1, ...)

I<classes> is a list of class names which are instantiated with C<get_instance>
or C<new>.  Will C<require> the modules, so you needn't C<use> them.  If class
is already instantiated, won't re-instantiate.

=cut

sub put {
    my($proto) = shift;
    my($class) = ref($proto) || $proto;
    $_MAP{$class} = {} unless $_MAP{$class};
    my($map) = $_MAP{$class};
    my($c);
    foreach $c (@_) {
	next if $map->{$c};
	Bivio::Util::my_require($c);
	$map->{$c} = $c->can('get_instance') ? $c->get_instance : $c->new;
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
