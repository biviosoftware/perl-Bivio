# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::ControlBase;
use strict;
use Bivio::Base 'Bivio::UI::Widget::ControlBase';

# C<Bivio::UI::HTML::Widget::ControlBase> renders common html attributes.
#
#
#
# class : string []
#
# HTML class attribute.
#
# id : string []
#
# HTML id attribute.
#
# html_attrs : array_ref [[class id]]
#
# List of attributes to render.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

sub control_on_render {
    # (self, any, string_ref) : undef
    # Render class and id.
    my($self, $source, $buffer) = @_;
    $$buffer .= $_VS->vs_html_attrs_render(
	$self, $source, $self->unsafe_get('html_attrs'));
    return;
}

sub initialize {
    # (self) : undef
    # Initializes class attribute.
    my($self) = @_;
    $_VS->vs_html_attrs_initialize($self, $self->unsafe_get('html_attrs'));
    return shift->SUPER::initialize(@_);
}

sub internal_compute_new_args {
    # (proto, array_ref, array_ref) : hash_ref
    my($proto, $required, $args) = @_;
    return {
	map({
	    my($a) = shift(@$args);
	    return qq{"$_" must be defined}
		unless defined($a);
	    ($_ => $a);
	} @$required),
	!@$args ? ()
	    : @$args > 2 ? return "too many parameters"
	    : (ref($args->[0]) ne 'HASH'
		   ? (class => shift(@$args))
		   : @$args == 2 ? return qq{"attributes" must be last} : (),
	       %{shift(@$args) || {}}),
    };
}

sub internal_new_args {
    # (proto, array_ref, array_ref) : hash_ref
    Bivio::IO::Alert->warn_deprecated('call internal_compute_new_args');
    return shift->internal_compute_new_args(@_);
}

1;
