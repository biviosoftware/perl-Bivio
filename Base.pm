# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Base;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::IO::ClassLoader;
use Bivio::Die;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = __PACKAGE__->use('IO.Alert');
my($_D) = __PACKAGE__->use('Bivio.Die');
my($_T) = __PACKAGE__->use('IO.Trace');

sub import {
    my($first, $map_or_class) = @_;
    Bivio::Die->die('must specify class or map on "use Bivio::Base" line')
        unless $map_or_class;
    my($pkg) = (caller(0))[0];
    Bivio::Die->eval_or_die(
        "package $pkg; use base '"
	. Bivio::IO::ClassLoader->map_require(
	    $map_or_class =~ /\W/ ? $map_or_class
	        :  Bivio::IO::ClassLoader->after_in_map($map_or_class, $pkg)
	) . "';1",
    );
    {
	no strict 'refs';
	*{$pkg . '::b_info'} = \&b_info;
	*{$pkg . '::b_warn'} = \&b_info;
	*{$pkg . '::b_die'} = \&b_die;
	*{$pkg . '::b_trace'} = \&b_trace;
    };
    return;
}

sub b_die {
    return $_D->throw_or_die($_A->calling_context, @_);
}

sub b_info {
    return $_A->info($_A->calling_context, @_);
}

sub b_trace {
    return $_T->set_named_filters(@_);
}

sub b_warn {
    return $_A->warn($_A->calling_context, @_);
}

1;
