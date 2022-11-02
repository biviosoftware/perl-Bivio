# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::ClassWrapper;
use strict;
use Bivio::Base 'Collection.Attributes';


sub call_method {
    my($self, $args) = @_;
    return
        unless my $c = $self->get('code_ref');
    return $c->(@$args);
}

sub wrap_methods {
    my($proto, $pkg, $attrs, $map) = @_;
    $attrs ||= {};
    while (my($method, $wrapper) = each(%$map)) {
        my($c) = _code_ref_for_method($pkg, $method);
        my($self) = $proto->new({
            %$attrs,
            code_ref => $c,
            method => $method,
        })->set_read_only;
        $pkg->replace_subroutine($method, sub {$wrapper->($self, \@_)});
    }
    return;
}

sub _code_ref_for_method {
    my($pkg, $method) = @_;
    return (_code_ref_for_subroutine($pkg, $method))[0]
        || (_unsafe_super_for_method($pkg, $method))[0];
}

sub _code_ref_for_subroutine {
    my($pkg, $name) = @_;
    do {
        no strict;
        local(*p) = *{$pkg->package_name . '::'};
        if (exists($p{$name})) {
            local(*n) = $p{$name};
            return *n{CODE}
                if defined(*n{CODE});
        }
    };
    return undef;
}

sub _unsafe_super_for_method {
    my($pkg, $method) = @_;
    $method ||= $pkg->my_caller;
    foreach my $ia (@{$pkg->inheritance_ancestors}) {
        if (my $sub = _code_ref_for_subroutine($ia, $method)) {
            return ($sub, $ia);
        }
    }
    return;
}

1;
