# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::ClassWrapper;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
	my($c) = $pkg->code_ref_for_method($method);
	my($self) = $proto->new({
	    %$attrs,
	    code_ref => $c,
	    method => $method,
	})->set_read_only;
	$pkg->replace_subroutine($method, sub {$wrapper->($self, \@_)});
    }
    return;
}

1;
