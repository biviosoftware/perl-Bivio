# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Replicator;
use strict;
use Bivio::Base 'Bivio::UI::Widget::ControlBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_ATTRS) = [qw(count value)];

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($c) = $self->render_simple_attr('count', $source);
    $self->die($source, $c, ': count did not render as an integer')
	unless $c =~ /^-?\d*$/s;
    $self->die($source, "$c: count too large")
	unless $c + 0 < 1_000_000;
    $$buffer .= $self->render_simple_attr('value', $source) x $c
	if $c > 0;
    return;
}

sub initialize {
    my($self) = @_;
    $self->map_invoke(initialize_attr => $_ATTRS);
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    return shift->unsafe_get(@$_ATTRS);
}

sub internal_new_args {
    shift;
    return {
	map({
	    my($x) = shift(@_);
	    return qq{"$_" must be defined}
		unless defined($x);
	    ($_ => $x);
	} @{$_ATTRS}),
	%{shift(@_) || {}},
    };
}

1;
