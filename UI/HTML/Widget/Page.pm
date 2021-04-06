# Copyright (c) 1999-2014 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Page;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;

# C<Bivio::UI::HTML::Widget::Page> is an HTML C<PAGE> tag surrounding
# a widget, which is usually a
# L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join>,
# but might be a
# L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.
# The widget or its children should be a
# L<Bivio::UI::HTML::Widget::FormButton|Bivio::UI::HTML::Widget::FormButton>.
#
# The link, bg, and text colors are specified by the
# L<b_use('FacadeComponent.Color')|Bivio::UI::Color> names:
# page_bg, page_text, page_link, page_vlink, and page_alink.
# page_bg must be defined, but the others may be undefined iwc
# the color defaults to the browser default.
#
#
#
# background : string
#
# Name of the icon to use for the page background.
#
# body : Bivio::UI::Widget (required)
#
# How to render the C<BODY> tag contents.  Usually a
# L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join>
# or
# L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.
#
# head : Bivio::UI::Widget (required)
#
# How to render the C<HEAD> tag contents.
# Usually a
# L<Bivio::UI::HTML::Widget::Title|Bivio::UI::HTML::Widget::Title>.
#
# page_alink_color : string
#
# Facade color for active links.
#
# page_bgcolor : string
#
# Facade color for the page background.
#
# page_link_color : string
#
# Facade color for links.
#
# page_text_color : string
#
# Facade color for text.
#
# page_vlink_color : string
#
# Facade color for visited links.
#
# script : any [Script()]
#
# Renders script code in the header.
#
# style : any [Style()]
#
# Renders an inline style in the header.
#
# want_page_print : any [0]
#
# If true, adds onLoad=window.print() to the body tag.
#
# xhtml : boolean [0]
#
# If set, the page will be generated with XHTML widgets.
#
# html_tag_attrs : any []
#
# Attributes to be applied to the html_tag used to generate the tag.  Works on
# <HTML> and <BODY> tags.
#
# Must have a leading space.
#
#
#
#
# b_use('FacadeComponent.Color').page_link : string
#
# Color of links.
#
# INCOMPLETE

my($_CL) = b_use('IO.ClassLoader');
my($_HANDLERS) = b_use('Biz.Registrar')->new;
my($_F) = b_use('UI.Facade');

sub execute {
    my($self, $req) = @_;
    # Calls L<Bivio::UI::Widget::execute_with_content_type|Bivio::UI::Widget/"execute_with_content_type">
    # as text/html.
    return $self->execute_with_content_type($req, 'text/html');
}

sub initialize {
    my($self) = shift;
    $self->initialize_attr('head');
    $self->initialize_attr('body');
    $self->unsafe_initialize_attr('background');
    $self->unsafe_initialize_attr('body_class');
    $self->unsafe_initialize_attr('html_tag_attrs');
    $self->internal_initialize_head_attrs(@_);
    return;
}

sub internal_initialize_head_attrs {
    my($self) = @_;
    $self->unsafe_initialize_attr('style');
    $self->unsafe_initialize_attr('xhtml');
    foreach my $x (qw(Style Script JavaScript)) {
	$self->initialize_attr(lc($x), sub {vs_call($x)});
    }
    $self->initialize_attr(
       _page_print_script => $self->get('script')->new('page_print'),
    ) if $self->unsafe_initialize_attr('want_page_print');
    return;
}

sub internal_new_args {
    my($proto, $head, $body, $attrs) = @_;
    # Implements positional argument parsing for L<new|"new">.
    return '"head" must be defined'
	unless defined($head);
    return '"body" must be defined'
	unless defined($body);
    return {
	head => $head,
	body => $body,
	($attrs ? %$attrs : ()),
    };
}

sub internal_render_head_attrs {
    my($self, $source) = @_;
    my($b);
    my($x) = '';
    $self->map_invoke(
	unsafe_render_attr => [
	    map(
		[$_, $source, \$b],
		'head',
		'style',
		$self->unsafe_render_attr('want_page_print', $source, \$x)
		    && $x ? '_page_print_script' : (),
		'script',
		'javascript',
	    ),
	],
	undef,
	[$source],
    );
    # IE caches too much.
    $b .= qq{<meta name="MSSmartTagsPreventParsing" content="TRUE">\n}
	.qq{<meta http-equiv="pragma" content="no-cache">\n}
	if $source->get_request->get('Type.UserAgent')->has_over_caching_bug;
    return $b;
}

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    my($xhtml) = $self->internal_setup_xhtml($req);
    my($body) = $self->render_attr('body', $source);
    $$buffer .= "<!DOCTYPE html>\n<html"
	. $self->render_simple_attr(html_tag_attrs => $source)
	. "><head>\n"
	. $self->internal_render_head_attrs($source)
	. '</head><body';
    # Always have a background color
    $$buffer .= b_use('FacadeComponent.Color')->format_html(
	$self->get_or_default('page_bgcolor', 'page_bg'), 'bgcolor', $req);
    foreach my $c ('text', 'link', 'alink', 'vlink') {
	my($n) = 'page_'.$c;
	$$buffer .= b_use('FacadeComponent.Color')->format_html(
	    $self->get_or_default($n.'_color', $n), $c, $req);
    }
    my($x) = '';
    $$buffer .= b_use('FacadeComponent.Icon')->format_html_attribute(
	$x, 'background', $req
    ) if $self->unsafe_render_attr('background', $source, \$x) && $x;
    $$buffer .= vs_html_attrs_render_one(
	$self, $source, 'body_class');
    $self->get('body')->unsafe_render_attr('html_tag_attrs', $source, $buffer)
	if Bivio::UI::Widget->is_blesser_of($self->get('body'))
	&& $self->get('body')->can('unsafe_render_attr');
    $$buffer .= ">\n$$body\n</body></html>\n";
    $_HANDLERS->do_filo(handle_page_render_end => [$source, $buffer]);
    return;
}

sub internal_setup_xhtml {
    my($self, $req) = @_;
    $req->put(font_with_style =>
        $req->get('Type.UserAgent')->is_css_compatible
	    && $self->unsafe_get('style')
	    ? 1 : 0,
    );
    $req->put(xhtml => my $xhtml = $self->render_simple_attr('xhtml', $req));
    return $xhtml;
}

sub register_handler {
    shift;
    $_HANDLERS->push_object(@_);
    return;
}

1;
