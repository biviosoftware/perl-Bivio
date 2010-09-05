# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Collection::SingletonMap;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::IO::ClassLoader;
use Carp ();

# C<Bivio::Collection::SingletonMap> maps class names to singleton objects of
# those classes.  Singletons are initialized with a call to C<get_instance> or
# C<new> depending on which exists.
#
# This class needn't be subclassed but typically is.  If it is,
# the classes are stored in distinct spaces.  This would allow
# instantiating singletons in different ways in different
# contexts.  Subclasses of this module I<could> control how the
# singletons are instantiated.  Currently, there is only way
# to instantiate.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
# Key to this is a package name ($proto).  The value is a
# map of class names to singletons.
my(%_MAP);

sub get {
    # (proto, string, ...) : (UNIVERSAL, ...)
    # Returns the list of named instances.  I<class> is qualified by
    # the package which owns the map.
    #
    # If the singleton doesn't exist, tries to "put" it.
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

sub put {
    # (proto, string, ...) : undef
    # I<classes> is a list of class names which are instantiated with C<get_instance>
    # or C<new>.  Will C<require> the modules, so you needn't C<use> them.  If class
    # is already instantiated, won't re-instantiate.
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

1;
