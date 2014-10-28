# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Base;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::Die;
use Bivio::IO::Alert;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;


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
	foreach my $n (qw(b_catch b_debug b_die b_info b_print b_trace b_use b_warn)) {
	    # Special case call because $pkg has yet to initialize
	    Bivio::UNIVERSAL::replace_subroutine($pkg, $n, \&{$n});
	}
    };
    return;
}

sub b_catch {
    return Bivio::Die->catch(@_);
}

sub b_debug {
    return Bivio::IO::Alert->debug(_cc(), @_);
}

sub b_die {
    return Bivio::Die->throw_or_die(_cc(), @_);
}

sub b_info {
    return Bivio::IO::Alert->info(_cc(), @_);
}

sub b_print {
    Bivio::IO::ClassLoader->use('IO.Ref')->print_string(@_);
}

sub b_trace {
    return Bivio::IO::Trace->set_named_filters(@_);
}

sub b_use {
    my($cache);
    # COUPLING: Bivio::IO::ClassLoader->unsafe_map_require
    {
	no strict 'refs';
	$cache = ${(caller(0))[0] . '::'}{HASH}->{'Bivio::Base::b_use'} ||= {};
    };
    return $cache->{join($;, @_)} ||= Bivio::IO::ClassLoader->map_require(@_);
}

sub b_warn {
    return Bivio::IO::Alert->warn(_cc(), @_);
}

sub _cc {
    return Bivio::IO::Alert->calling_context([__PACKAGE__]);
}

1;
