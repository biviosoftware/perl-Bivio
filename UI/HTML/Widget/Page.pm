# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Page;
use strict;
$Bivio::UI::HTML::Widget::Page::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Page::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Page - renders an HTML page

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Page;
    Bivio::UI::HTML::Widget::Page->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::Page::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Page> is an HTML C<PAGE> tag surrounding
a widget, which is usually a
L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join>,
but might be a
L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.
The widget or its children should be a
L<Bivio::UI::HTML::Widget::FormButton|Bivio::UI::HTML::Widget::FormButton>.

The link, bg, and text colors are specified by the
L<Bivio::UI::Color|Bivio::UI::Color> names:
page_bg, page_text, page_link, page_vlink, and page_alink.
page_bg must be defined, but the others may be undefined iwc
the color defaults to the browser default.

=head1 ATTRIBUTES

=over 4

=item background : string

Name of the icon to use for the page background.

=item body : Bivio::UI::Widget (required)

How to render the C<BODY> tag contents.  Usually a
L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join>
or
L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.

=item head : Bivio::UI::Widget (required)

How to render the C<HEAD> tag contents.
Usually a
L<Bivio::UI::HTML::Widget::Title|Bivio::UI::HTML::Widget::Title>.

=item page_alink_color : string

Facade color for active links.

=item page_bgcolor : string

Facade color for the page background.

=item page_link_color : string

Facade color for links.

=item page_text_color : string

Facade color for text.

=item page_vlink_color : string

Facade color for visited links.

=item script : any [Script()]

Renders script code in the header.

=item style : any [Style()]

Renders an inline style in the header.

=item want_page_print : any [0]

If true, adds onLoad=window.print() to the body tag.

=item xhtml : boolean [0]

If set, the page will be generated with the following XHTML doctype

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

=back

=head1 COMPONENT ATTRIBUTES

=over 4

=item html_tag_attrs : any []

Attributes to be applied to the html_tag used to generate the component.
Only currently works for I<body> components.

Must have a leading space.

=back

=head1 FACADE ATTRIBUTES

=over 4

=item Bivio::UI::Color.page_link : string

Color of links.

=item INCOMPLETE

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::IO::Config;

#=VARIABLES

my($_SHOW_TIME) = 0;
my($_VS) = __PACKAGE__->use('Bivio::UI::HTML::ViewShortcuts');
Bivio::IO::Config->register({
    'show_time' => $_SHOW_TIME,
});

=head1 FACTORIES

=cut

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Calls L<Bivio::UI::Widget::execute_with_content_type|Bivio::UI::Widget/"execute_with_content_type">
as text/html.

=cut

sub execute {
    my($self, $req) = @_;
    return $self->execute_with_content_type($req, 'text/html');
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item show_time : boolean [false] (inherited)

Show the elapsed time in page trailer.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_SHOW_TIME = $cfg->{show_time};
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes child widgets.

=cut

sub initialize {
    my($self) = @_;
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

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args() :  hash_ref

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my($proto, $head, $body, $attrs) = @_;
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

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

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

=for html <a name="show_time_as_html"></a>

=head2 static show_time_as_html(Bivio::Agent::Request req) : string

Returns page times as an html comment, no spaces or newlines.
Resets counters.  Returns empty string if I<show_time> not configured.

=cut

sub show_time_as_html {
    my($proto, $req) = @_;
    return '' unless $_SHOW_TIME || $_TRACE;
    # Output timing info
    my($times) = sprintf('total=%.3fs; db=%.3fs',
	    $req->get_current->elapsed_time,
	    Bivio::SQL::Connection->get_db_time);
    _trace($times) if $_TRACE;
    return $_SHOW_TIME ? "<!-- " . $times . " -->\n" : '';
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
