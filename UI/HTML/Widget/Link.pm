# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Link;
use strict;
use Bivio::Base 'HTMLWidget.ControlBase';
use Bivio::Die;
use Bivio::HTML;
use Bivio::UI::HTML::ViewShortcuts;

# C<Bivio::UI::HTML::Widget::Link> implements an HTML C<A> tag with
# an C<HREF> attribute.
#
#
#
# attributes : string []
#
# Arbitrary HTML attributes to be applied to the begin tag.  Must begin
# with leading space.
#
# class : string []
#
# Class attribute.
#
# control : any
#
# See L<Bivio::UI::Widget::ControlBase|Bivio::UI::Widget::ControlBase>.
#
# event_handler : Bivio::UI::Widget []
#
# If set, this widget will be initialized as a child and must
# support a method C<get_html_field_attributes> which returns a
# string to be inserted in this fields declaration.
# I<event_handler> will be rendered before this field.
#
# href : any (required)
#
# Value to use for C<HREF> attribute of C<A> tag.  If I<href> renders to a valid
# enum name or is an L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>,
# I<href> will be passed passed
# using L<Bivio::Agent::Request::format_stateless_uri|Bivio::Agent::Request/"format_stateless_uri">
# If I<href> renders as a hash_ref, it will passed to
# L<Bivio::Agent::Request::format_uri|Bivio::Agent::Request/"format_uri">.
# Otherwise, I<href> will be treated as a literal uri.
#
# link_target : any [] (inherited)
#
# The value to be passed to the C<TARGET> attribute of C<A> tag.
#
# name : any []
#
# Anchor name.
#
# value : any (required)
#
# The value between the C<A> tags aka the label.  May be any
# renderable value
# (see L<Bivio::UI::Widget::render_value|Bivio::UI::Widget/"render_value">).
# If not a widget, will be wrapped in a I<Widget.String>.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';
my($_IDI) = __PACKAGE__->instance_data_index;

sub control_on_render {
    my($self, $source, $buffer) = @_;
    # Render the link.
    $$buffer .= '<a' . $_VS->vs_link_target_as_html($self, $source);
    $self->SUPER::control_on_render($source, $buffer);
    $self->unsafe_render_attr('attributes', $source, $buffer);
    my($n) = '';
    $$buffer .= ' name="' . Bivio::HTML->escape_attr_value($n) . '"'
	if $self->unsafe_render_attr('name', $source, \$n);
    my($href) = _render_href($self, $source);
    $$buffer .= qq{ href="$href"}
        if defined($href);
    my($handler) = $self->unsafe_resolve_widget_value(
	$self->unsafe_get('event_handler'), $source);
    $$buffer .= $handler->get_html_field_attributes(undef, $source)
	if $handler;
    $$buffer .= '>';
    $self->render_attr('value', $source, $buffer);
    $$buffer .= '</a>';
    $handler->render($source, $buffer)
	if $handler;
    return;
}

sub initialize {
    my($self) = @_;
    # Partially initializes by copying attributes to fields.
    # It is fully initialized after first render.
    $self->map_invoke(
	'unsafe_initialize_attr',
	[qw(attributes event_handler name link_target)],
    );
    my($v) = $self->get('value');
    $self->put(value => $_VS->vs_new('String', $v))
	unless UNIVERSAL::isa($v, 'Bivio::UI::Widget');
    $self->map_invoke('initialize_attr', [qw(value href)]);
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    # Returns this widget's config for
    # L<Bivio::UI::Widget::as_string|Bivio::UI::Widget/"as_string">.
    return shift->unsafe_get('value', 'href');
}

sub internal_new_args {
    # Implements positional argument parsing for L<new|"new">.
    return shift->internal_compute_new_args([qw(value href)], \@_);
}

sub _render_href {
    my($self, $source) = @_;
    # Returns a string.  May format it using format_uri or format_stateless_uri
    my($href) = $self->unsafe_resolve_widget_value(
        $self->get('href'), $source);
    if (Bivio::UI::Widget->is_blessed($href)) {
	my($v) = $href;
	$href = undef;
	$self->unsafe_render_value('href', $v, $source, \$href);
    }
    return undef
	unless defined($href) && length($href);
    return $href
	unless ref($href) || Bivio::Agent::TaskId->is_valid_name($href);
    my($req) = $source->get_request;
    return $req->format_stateless_uri($href)
	if !ref($href) || UNIVERSAL::isa($href, 'Bivio::Agent::TaskId');
    return $req->format_uri($href)
	if ref($href) eq 'HASH';
    $self->die(
	'href', $source,
	$href, ': unknown type for href (must be scalar, hash, or TaskId)'
    );
    # DOES NOT RETURN
}

1;
