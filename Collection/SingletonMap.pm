# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Collection::SingletonMap;
use strict;
$Bivio::Collection::SingletonMap::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Collection::SingletonMap::VERSION;

=head1 NAME

Bivio::Collection::SingletonMap - maps classes to singleton objects

=head1 RELEASE SCOPE

bOP

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
use Bivio::IO::ClassLoader;

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
    my($proto, @classes) = @_;
    my($class) = ref($proto) || $proto;
    $_MAP{$class} = {} unless $_MAP{$class};
    my($map) = $_MAP{$class};
    @classes || Carp::croak('must supply at least one class argument');
    my(@res);
    foreach my $x (@classes) {
	$proto->put($x) unless exists($map->{$x});
	push(@res, $map->{$x});
    }
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
    my($proto, @classes) = @_;
    my($class) = ref($proto) || $proto;
    $_MAP{$class} = {} unless $_MAP{$class};
    my($map) = $_MAP{$class};
    my($c);
    foreach $c (@classes) {
	next if $map->{$c};
	my($res) = Bivio::IO::ClassLoader->map_require($c);
#TODO: Remove caching?
	$map->{$c} = ref($res) ? $res
		: $res->can('get_instance') ? $res->get_instance : $res->new;
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
