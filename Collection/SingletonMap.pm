# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Collection::SingletonMap;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

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

my(%_MAP);

sub get {
    my($proto, @classes) = @_;
    my($class) = ref($proto) || $proto;
    $_MAP{$class} = {} unless $_MAP{$class};
    my($map) = $_MAP{$class};
    b_die('must supply at least one class argument')
    unless @classes;
    my(@res);
    foreach my $x (@classes) {
	$proto->put($x)
	    unless exists($map->{$x});
	push(@res, $map->{$x});
    }
    return @res
	if wantarray;
    b_die('get not called in array context and more than one return result')
	unless int(@res) == 1;
    return $res[0];
}

sub put {
    my($proto, @classes) = @_;
    my($class) = ref($proto) || $proto;
    $_MAP{$class} = {}
	unless $_MAP{$class};
    my($map) = $_MAP{$class};
    my($c);
    foreach $c (@classes) {
	next if $map->{$c};
	my($res) = b_use($c);
#TODO: Remove caching?
	$map->{$c} = ref($res) ? $res
	    : $res->can('get_instance') ? $res->get_instance : $res->new;
    }
    return;
}

1;
