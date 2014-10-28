# Copyright (c) 2000-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Style;
use strict;
use Bivio::Base 'UI.Widget';

# C<Bivio::UI::HTML::Widget::Style> generates an inline style sheet.
# Appropriate for use with
# L<Bivio::UI::HTML::Widget::Page|Bivio::UI::HTML::Widget::Page>
# I<style> attribute.
#
#
#
# other_styles : array_ref ['']
#
# Returns a string for styles.
#
#
#
#
# b_use('FacadeComponent.Font').default : hash_ref (required)
#
# The default font information.
#
# b_use('FacadeComponent.Color').page_link_hover : string (required)
#
# If non-empty, will render a style for C<a:hover>.
#
#
#
#
# font_with_style : boolean (set)
#
# If rendering an inline style sheet, will set this attribute to true
# on the request.
#
# Bivio::Type::UserAgent : Bivio::Type::UserAgent (required)
#
# If the agent supports css, will render a full style sheet.
# Otherwise will render a partial style sheet.

my($_NO_HTML_KEY) = __PACKAGE__ . 'no_html';
my($_TAGS) = join(',', qw(
    address
    blockquote
    body
    button
    center
    div
    dl
    input
    ins
    kbd
    label
    legend
    menu
    multicol
    ol
    p
    pre
    select
    th
    td
    textarea
    ul
));

sub execute {
    # (proto, Agent.Request) : boolean
    # Renders the table.
    #
    # Calls
    # L<Bivio::UI::Widget::execute_with_content_type|Bivio::UI::Widget/"execute_with_content_type">
    # as text/css
    my($self, $req) = @_;
    return $self->execute_with_content_type($req->put(
        font_with_style => 1,
        $_NO_HTML_KEY => 1,
    ), 'text/css');
}

sub render {
    # (self, string_ref) : undef
    # Renders the appropriate style sheet.
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;

    # Only real browsers get style sheets, sorry.
    return unless $req->unsafe_get('font_with_style');

    # Begin
    $$buffer .= qq{<style type="text/css">\n<!--\n}
        unless $req->unsafe_get($_NO_HTML_KEY);

    # Font
    my($font) = b_use('FacadeComponent.Font')->get_attrs('default', $req);
    if ($font) {
	$$buffer .= $_TAGS . " {\n";
	# If the value isn't set or is zero, then don't render.
	$$buffer .= ' font-family : '.$font->{family}.';' if $font->{family};
	$$buffer .= ' font-size : '.$font->{size}.';'
		if $font->{size};
	$$buffer .= " }\n";
    }

    # Hover (overrides font)
    my($hover) = b_use('FacadeComponent.Color')->format_html('page_link_hover', 'color:',
	    $req);
    $$buffer .= 'a:hover { '.$hover." }\n" if $hover;
    $self->unsafe_render_attr('other_styles', $source, $buffer);

    # End
    $$buffer .= "\n-->\n</style>\n"
        unless $req->unsafe_get($_NO_HTML_KEY);
    return;
}

1;
