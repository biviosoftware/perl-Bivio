# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Base;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::Die;
use Bivio::IO::Alert;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub import {
    my(undef, $map_or_class) = @_;
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
	foreach my $n (qw(b_debug b_die b_info b_trace b_use b_warn)) {
	    # Special case call because $pkg has yet to initialize
	    Bivio::UNIVERSAL::replace_subroutine($pkg, $n, \&{$n});
	}
    };
    return;
}

sub b_debug {
    return Bivio::IO::Alert->debug(Bivio::IO::Alert->calling_context, @_);
}

sub b_die {
    return Bivio::Die->throw_or_die(Bivio::IO::Alert->calling_context, @_);
}

sub b_info {
    return Bivio::IO::Alert->info(Bivio::IO::Alert->calling_context, @_);
}

sub b_trace {
    return Bivio::IO::Trace->set_named_filters(@_);
}

sub b_use {
    return Bivio::IO::ClassLoader->map_require(@_);
}

sub b_warn {
    return Bivio::IO::Alert->warn(Bivio::IO::Alert->calling_context, @_);
}

1;
