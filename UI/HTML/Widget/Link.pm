# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Link;
use strict;
use Bivio::Base 'HTMLWidget.ControlBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

# HTMLWidget.Link implements an HTML A tag with an HREF attribute.
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
# See UIWidget.ControlBase.
#
# event_handler : Bivio::UI::Widget []
#
# If set, this widget will be initialized as a child and must
# support a method get_html_field_attributes() which returns a
# string to be inserted in this fields declaration.
# event_handler will be rendered before this field.
#
# href : any (required)
#
# Value to use for HREF attribute of A tag.  If href renders to a valid
# enum name or is Agent.TaskId, href will be passed passed
# using Agent.Request->format_stateless_uri().
# If href renders as a hash_ref, it will passed to Agent.Request->format().
# Otherwise, href will be treated as a literal uri.
#
# link_target : any [] (inherited)
#
# The value to be passed to the TARGET attribute of A tag.
#
# name : any []
#
# Anchor name.
#
# tooltip : any []
#
# Value shown when hovering over the link text.
#
# value : any (required)
#
# The value between the A tags aka the label.  May be any
# renderable value (see UIWidget->render_value().
# If not a widget, will be wrapped in a Widget.String.

my($_HTML) = b_use('Bivio.HTML');
my($_TI) = b_use('Agent.TaskId');

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $$buffer .= '<a' . vs_link_target_as_html($self, $source);
    $self->SUPER::control_on_render($source, $buffer);
    $self->unsafe_render_attr('attributes', $source, $buffer);

    foreach my $attr ([qw(name name)], [qw(tooltip title)]) {
        my($n) = '';
        $$buffer .= ' ' . $attr->[1] . '="'
            . $_HTML->escape_attr_value($n) . '"'
                if $self->unsafe_render_attr($attr->[0], $source, \$n);
    }
    my($href) = _render_href($self, $source);
    $$buffer .= qq{ href="@{[_escape($href)]}"}
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
    $self->put(value => String($v))
        unless UNIVERSAL::isa($v, 'Bivio::UI::Widget');
    $self->map_invoke('initialize_attr', [qw(value href)]);
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    # Returns this widget's config for UIWidget->as_string.
    return shift->unsafe_get('value', 'href');
}

sub internal_new_args {
    # Implements positional argument parsing for new.
    return shift->internal_compute_new_args([qw(value href ?class)], \@_);
}

sub _escape {
    my($href) = @_;
    return $href
        if $href =~ /^javascript:/i;
    return $_HTML->escape_attr_value($href);
}

sub _render_href {
    my($self, $source) = @_;
    # Returns a string.  May format it using format_uri or format_stateless_uri
    my($href) = $self->unsafe_resolve_widget_value(
        $self->get('href'), $source);
    if (Bivio::UI::Widget->is_blesser_of($href)) {
        my($v) = $href;
        $href = undef;
        $self->unsafe_render_value('href', $v, $source, \$href);
    }
    return undef
        unless defined($href) && length($href);
    return $href
        unless ref($href) || $_TI->is_valid_name($href);
    return $source->req->format_stateless_uri($href)
        if !ref($href) || UNIVERSAL::isa($href, $_TI);
    return $source->req->format_uri($href)
        if ref($href) eq 'HASH';
    $self->die(
        'href', $source,
        $href, ': unknown type for href (must be scalar, hash, or TaskId)'
    );
    # DOES NOT RETURN
}

1;
