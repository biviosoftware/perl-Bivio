# Copyright (c) 2005-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::ControlBase;
use strict;
use Bivio::Base 'HTMLWidget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $$buffer .= $_VS->vs_html_attrs_render(
	$self, $source, $self->unsafe_get('html_attrs'));
    return;
}

sub initialize {
    my($self) = @_;
    unless ($self->unsafe_get('html_attrs')) {
	my($a) = $self->map_each(sub {
            my(undef, $k) = @_;
	    return $k =~ /^[A-Z]+[0-9]?$/ ? $k : ();
	});
	$self->put(html_attrs => $_VS->vs_html_attrs_merge([sort(@$a)]))
	    if @$a;
    }
    $_VS->vs_html_attrs_initialize($self, $self->unsafe_get('html_attrs'));
    return shift->SUPER::initialize(@_);
}

sub internal_compute_new_args {
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
    Bivio::IO::Alert->warn_deprecated('call internal_compute_new_args');
    return shift->internal_compute_new_args(@_);
}

1;
