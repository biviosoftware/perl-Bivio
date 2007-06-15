# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Page;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::IO::Config;
use Bivio::IO::Trace;

# C<Bivio::UI::HTML::Widget::Page> is an HTML C<PAGE> tag surrounding
# a widget, which is usually a
# L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join>,
# but might be a
# L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.
# The widget or its children should be a
# L<Bivio::UI::HTML::Widget::FormButton|Bivio::UI::HTML::Widget::FormButton>.
#
# The link, bg, and text colors are specified by the
# L<Bivio::UI::Color|Bivio::UI::Color> names:
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
# If set, the page will be generated with the following XHTML doctype
#
#     <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
#     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
#
#
#
#
# html_tag_attrs : any []
#
# Attributes to be applied to the html_tag used to generate the component.
# Only currently works for I<body> components.
#
# Must have a leading space.
#
#
#
#
# Bivio::UI::Color.page_link : string
#
# Color of links.
#
# INCOMPLETE

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SHOW_TIME) = 0;
my($_VS) = __PACKAGE__->use('Bivio::UI::HTML::ViewShortcuts');
Bivio::IO::Config->register({
    'show_time' => $_SHOW_TIME,
});

sub execute {
    my($self, $req) = @_;
    # Calls L<Bivio::UI::Widget::execute_with_content_type|Bivio::UI::Widget/"execute_with_content_type">
    # as text/html.
    return $self->execute_with_content_type($req, 'text/html');
}

sub handle_config {
    my(undef, $cfg) = @_;
    # show_time : boolean [false] (inherited)
    #
    # Show the elapsed time in page trailer.
    $_SHOW_TIME = $cfg->{show_time};
    return;
}

sub initialize {
    my($self) = @_;
    # Initializes child widgets.
    $self->initialize_attr('head');
    $self->initialize_attr('body');
    $self->unsafe_initialize_attr('style');
    $self->unsafe_initialize_attr('xhtml');
    $self->unsafe_initialize_attr('background');
    foreach my $x (qw(style script)) {
	$self->get_if_exists_else_put($x,
	    sub {$_VS->vs_new(ucfirst($x))});
	$self->unsafe_initialize_attr($x);
    }
    $self->get_if_exists_else_put('javascript',
        sub {$_VS->vs_new('JavaScript')});
    $self->unsafe_initialize_attr('javascript');
    if ($self->unsafe_initialize_attr('want_page_print')) {
	$self->put(
	    _page_print_script => $self->get('script')->new('page_print'),
	);
	$self->initialize_attr('_page_print_script');
    }
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

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    $req->put(font_with_style =>
        $req->get('Type.UserAgent')->is_css_compatible
	    && $self->unsafe_get('style')
	    ? 1 : 0,
    );
    my($body) = $self->render_attr('body', $source);
    $req->put(xhtml => my $xhtml = $self->render_simple_attr('xhtml', 0));
    $$buffer .= ($xhtml
#	? '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
	? '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
        : '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">')
	."\n<html><head>\n";
    my($x) = '';
    $self->map_invoke(
	unsafe_render_attr => [
	    map(
		[$_, $source, $buffer],
		'head',
		'style',
		$self->unsafe_render_attr('want_page_print', $source, \$x)
		    && $x ? '_page_print_script' : (),
		'script',
		'javascript',
	    ),
	],
    );
    # IE caches too much.
    $$buffer .= qq{<meta name="MSSmartTagsPreventParsing" content="TRUE">\n}
	.qq{<meta http-equiv="pragma" content="no-cache">\n}
	if $req->get('Type.UserAgent')->has_over_caching_bug;
    $$buffer .= '</head><body';
    # Always have a background color
    $$buffer .= Bivio::UI::Color->format_html(
	$self->get_or_default('page_bgcolor', 'page_bg'), 'bgcolor', $req);
    foreach my $c ('text', 'link', 'alink', 'vlink') {
	my($n) = 'page_'.$c;
	$$buffer .= Bivio::UI::Color->format_html(
	    $self->get_or_default($n.'_color', $n), $c, $req);
    }
    $x = '';
    $$buffer .= Bivio::UI::Icon->format_html_attribute(
	$x, 'background', $req
    ) if $self->unsafe_render_attr('background', $source, \$x) && $x;
    $self->get('body')->unsafe_render_attr('html_tag_attrs', $source, $buffer)
	if UNIVERSAL::can($self->get('body'), 'unsafe_render_attr');
    $$buffer .= ">\n$$body\n"
	. $self->show_time_as_html($req)
	. "</body></html>\n";
    return;
}

sub show_time_as_html {
    my($proto, $req) = @_;
    # Returns page times as an html comment, no spaces or newlines.
    # Resets counters.  Returns empty string if I<show_time> not configured.
    return '' unless $_SHOW_TIME || $_TRACE;
    # Output timing info
    my($times) = sprintf('total=%.3fs; db=%.3fs',
	    $req->get_current->elapsed_time,
	    Bivio::SQL::Connection->get_db_time);
    _trace($times) if $_TRACE;
    return $_SHOW_TIME ? "<!-- " . $times . " -->\n" : '';
}

1;
